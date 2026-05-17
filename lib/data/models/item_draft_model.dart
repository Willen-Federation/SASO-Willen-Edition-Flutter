/// Response body of `POST /api/v1/items/drafts`.
///
/// The server stores the upload as an `item_draft` row and enqueues a
/// background enrichment job (barcode lookup → AI vision → merge). The
/// HTTP response carries only the draft id and the initial status so the
/// mobile app can return immediately; the user re-checks status via the
/// items list once enrichment finishes.
class ItemDraftModel {
  const ItemDraftModel({required this.draftId, required this.status});

  factory ItemDraftModel.fromJson(Map<String, dynamic> json) => ItemDraftModel(
    draftId: json['draft_id'] as int,
    status: json['status'] as String? ?? 'queued',
  );

  final int draftId;

  /// One of: `queued`, `processing`, `ready`, `failed`.
  final String status;
}
