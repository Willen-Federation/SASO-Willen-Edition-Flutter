import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/common/loading_widget.dart';

class CategoryBrowserPage extends ConsumerWidget {
  const CategoryBrowserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリ')),
      body: categoriesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplayWidget(
          error: e,
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (cats) => ListView.builder(
          itemCount: cats.length,
          itemBuilder: (_, i) => _CategoryTile(category: cats[i]),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, this.depth = 0});

  final Category category;
  final int depth;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ListTile(
        contentPadding: EdgeInsets.only(left: 16.0 + depth * 16, right: 16),
        leading: Icon(
          category.hasChildren ? Icons.folder_outlined : Icons.label_outline,
        ),
        title: Text(category.name),
        onTap: () => context.push('/items/search?categoryId=${category.id}'),
      ),
      if (category.hasChildren)
        ...category.children.map(
          (c) => _CategoryTile(category: c, depth: depth + 1),
        ),
      if (depth == 0) const Divider(height: 1),
    ],
  );
}
