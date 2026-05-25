import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/storage/database_helper.dart';
import '../../../data/datasources/local/pending_registration_dao.dart';
import '../../../data/datasources/remote/v1/rest_api_client.dart';
import '../../../data/models/pending_registration.dart';
import '../../providers/server_config_provider.dart';

/// Displays the upload confirmation banner after a successful draft creation.
class _UploadSuccessView extends StatelessWidget {
  const _UploadSuccessView({required this.draftId, required this.onAnother});

  final String draftId;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('商品撮影')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 72,
                color: scheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'アップロード完了',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'ドラフトID: $draftId',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                '商品画像をサーバーに送信しました。\nサーバー側でAI解析が行われます。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: onAnother,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('続けて撮影'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('ホームへ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-mode page for barcode + product-image capture.
///
/// Mode 1 (barcode): opens [BarcodeScannerPage] in `register` mode to populate
/// the JAN/ISBN field, which is kept as an optional hint to associate the photo
/// with a specific product.
///
/// Mode 2 (photo): captures a JPEG/PNG with [ImagePicker] and uploads it via
/// `POST /api/v1/items/drafts` (multipart). In offline mode the image path is
/// stored in the local outbox via [PendingRegistrationDao].
class ProductPhotoCapturePage extends ConsumerStatefulWidget {
  const ProductPhotoCapturePage({super.key, this.prefillJanCode});

  final String? prefillJanCode;

  @override
  ConsumerState<ProductPhotoCapturePage> createState() =>
      _ProductPhotoCapturePageState();
}

class _ProductPhotoCapturePageState
    extends ConsumerState<ProductPhotoCapturePage> {
  final _janController = TextEditingController();
  XFile? _capturedImage;
  bool _uploading = false;
  String? _errorMessage;
  String? _uploadedDraftId;

  @override
  void initState() {
    super.initState();
    if (widget.prefillJanCode != null) {
      _janController.text = widget.prefillJanCode!;
    }
  }

  @override
  void dispose() {
    _janController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      // Limit dimensions so multipart upload stays under server size limits.
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 88,
    );
    if (file != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _capturedImage = file;
        _errorMessage = null;
      });
    }
  }

  Future<void> _upload() async {
    final image = _capturedImage;
    if (image == null) return;

    setState(() {
      _uploading = true;
      _errorMessage = null;
    });

    final janCode = _janController.text.trim().isEmpty
        ? null
        : _janController.text.trim();
    final config = ref.read(serverConfigNotifierProvider);

    // Always persist to local outbox first so nothing is lost on network error.
    final db = await ref.read(databaseHelperProvider.future);
    final dao = PendingRegistrationDao(db.db);
    final localId = await dao.insert(
      PendingRegistration(
        name: janCode != null ? 'photo:$janCode' : 'photo',
        categoryId: 0,
        price: 0,
        stock: 0,
        janCode: janCode,
        imagePath: image.path,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );

    // Offline or mock mode: queue only.
    if (config.offlineMode || config.apiMode == ApiMode.mock) {
      if (mounted) {
        setState(() {
          _uploading = false;
          _uploadedDraftId = 'local-$localId';
        });
      }
      return;
    }

    // REST upload.
    if (config.apiMode != ApiMode.rest || config.jwtToken == null) {
      await dao.updateStatus(
        localId,
        'failed',
        errorMessage: 'RESTモードが有効でないか、JWTトークンがありません',
      );
      if (mounted) {
        setState(() {
          _uploading = false;
          _errorMessage = 'RESTモードが有効でないか、JWTトークンがありません';
        });
      }
      return;
    }

    try {
      await dao.updateStatus(localId, 'syncing');
      final restClient = RestV1ApiClient(
        serverUrl: config.baseUrl,
        jwtToken: config.jwtToken!,
      );
      final draft = await restClient.createItemDraftWithAi(
        janCode: janCode,
        barcodeHint: janCode,
        image: image,
      );
      await dao.updateStatus(localId, 'completed', syncedAt: DateTime.now());
      if (mounted) {
        setState(() => _uploadedDraftId = '${draft.draftId}');
      }
    } catch (e) {
      await dao.updateStatus(localId, 'failed', errorMessage: '$e');
      if (mounted) {
        setState(() => _errorMessage = 'アップロード失敗: $e');
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _reset() {
    setState(() {
      _capturedImage = null;
      _errorMessage = null;
      _uploadedDraftId = null;
      _janController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadedDraftId != null) {
      return _UploadSuccessView(
        draftId: _uploadedDraftId!,
        onAnother: _reset,
      );
    }

    final config = ref.watch(serverConfigNotifierProvider);
    final isOffline = config.offlineMode || config.apiMode == ApiMode.mock;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('商品撮影')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Step 1: barcode ─────────────────────────────────────────────
          const _SectionHeader(label: 'STEP 1  JAN / ISBNコードをスキャン（任意）'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _janController,
            decoration: InputDecoration(
              labelText: 'JAN / ISBN（任意）',
              hintText: '例: 9784101092058',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.tag),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'バーコードをスキャン',
                onPressed: () => context.push('/scanner/jan').then((code) {
                  if (code is String && mounted) {
                    setState(() => _janController.text = code);
                  }
                }),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 24),

          // ── Step 2: photo capture ────────────────────────────────────────
          const _SectionHeader(label: 'STEP 2  商品写真を撮影'),
          const SizedBox(height: 8),
          _ImagePreview(image: _capturedImage),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _uploading
                      ? null
                      : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('撮影する'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _uploading
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('ライブラリ'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Step 3: upload ───────────────────────────────────────────────
          const _SectionHeader(label: 'STEP 3  関連画像としてアップロード'),
          const SizedBox(height: 8),

          if (isOffline)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'オフラインモード: 画像はローカルに保存され、後で同期されます',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: scheme.error),
              ),
            ),

          FilledButton.icon(
            onPressed: (_capturedImage == null || _uploading) ? null : _upload,
            icon: _uploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_outlined),
            label: Text(
              _uploading
                  ? 'アップロード中...'
                  : _capturedImage == null
                  ? '撮影してからアップロード'
                  : '関連画像をアップロード',
            ),
          ),

          if (_capturedImage != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _uploading ? null : _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('リセット'),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image});
  final XFile? image;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(image!.path),
          height: 240,
          width: double.infinity,
          fit: BoxFit.cover,
          semanticLabel: '撮影した商品画像',
        ),
      );
    }
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 56,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'カメラで撮影するか\nライブラリから選択してください',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
