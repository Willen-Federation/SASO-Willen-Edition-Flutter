import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/value_objects/item_id.dart';
import '../../../presentation/providers/item_provider.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/item/item_list_tile.dart';

class ItemSearchPage extends ConsumerStatefulWidget {
  const ItemSearchPage({super.key});

  @override
  ConsumerState<ItemSearchPage> createState() => _ItemSearchPageState();
}

class _ItemSearchPageState extends ConsumerState<ItemSearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    setState(() => _query = value.trim());

    // If exact 8-digit ID, jump directly to detail
    final id = ItemId.tryParse(value.trim());
    if (id != null) {
      context.push('/items/${id.value}');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: TextField(
        key: const Key('search_field'),
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'アイテムIDまたは名前',
          border: InputBorder.none,
        ),
        onSubmitted: _onSearch,
        textInputAction: TextInputAction.search,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _onSearch(_controller.text),
        ),
      ],
    ),
    body:
        _query.isEmpty
            ? const Center(child: Text('キーワードを入力してください'))
            : _SearchResults(query: _query),
  );
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(itemSearchProvider(query: query));

    return results.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorDisplayWidget(error: e),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('結果が見つかりません'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder:
              (_, i) => ItemListTile(
                item: items[i],
                onTap: () => context.push('/items/${items[i].id.value}'),
              ),
        );
      },
    );
  }
}
