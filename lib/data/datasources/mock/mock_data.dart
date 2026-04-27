import '../../models/category_model.dart';
import '../../models/item_model.dart';
import '../../models/shelf_model.dart';

abstract final class MockData {
  static final List<CategoryModel> categories = [
    const CategoryModel(
      id: 'cat-001',
      name: '電子部品',
      children: [
        CategoryModel(
          id: 'cat-001-1',
          name: '抵抗器',
          parentId: 'cat-001',
          depth: 1,
        ),
        CategoryModel(
          id: 'cat-001-2',
          name: 'コンデンサ',
          parentId: 'cat-001',
          depth: 1,
        ),
        CategoryModel(
          id: 'cat-001-3',
          name: 'IC',
          parentId: 'cat-001',
          depth: 1,
        ),
      ],
    ),
    const CategoryModel(
      id: 'cat-002',
      name: '機械部品',
      children: [
        CategoryModel(
          id: 'cat-002-1',
          name: 'ネジ',
          parentId: 'cat-002',
          depth: 1,
        ),
        CategoryModel(
          id: 'cat-002-2',
          name: 'ボルト',
          parentId: 'cat-002',
          depth: 1,
        ),
      ],
    ),
    const CategoryModel(id: 'cat-003', name: '梱包材'),
  ];

  static final List<ShelfModel> shelves = [
    const ShelfModel(
      id: 'A-01',
      label: 'A棚 01',
      location: '倉庫1F-A',
      itemIds: ['26040001', '26040002'],
    ),
    const ShelfModel(
      id: 'A-02',
      label: 'A棚 02',
      location: '倉庫1F-A',
      itemIds: ['26040003'],
    ),
    const ShelfModel(
      id: 'B-01',
      label: 'B棚 01',
      location: '倉庫1F-B',
      itemIds: ['26040004', '26040005'],
    ),
  ];

  static final List<ItemModel> items = [
    const ItemModel(
      id: '26040001',
      name: '抵抗器 100Ω',
      description: '1/4W カーボン抵抗器',
      categoryId: 'cat-001-1',
      categoryName: '抵抗器',
      features: [
        FeatureModel(
          code: '260400010101',
          colorCode: '01',
          sizeCode: '01',
          colorLabel: 'ベージュ',
          sizeLabel: '1/4W',
          stockCount: 500,
          shelfId: 'A-01',
        ),
      ],
      registeredAt: '2026-04-01T09:00:00.000Z',
    ),
    const ItemModel(
      id: '26040002',
      name: '抵抗器 1kΩ',
      description: '1/4W カーボン抵抗器',
      categoryId: 'cat-001-1',
      categoryName: '抵抗器',
      features: [
        FeatureModel(
          code: '260400020101',
          colorCode: '01',
          sizeCode: '01',
          colorLabel: 'ベージュ',
          sizeLabel: '1/4W',
          stockCount: 300,
          shelfId: 'A-01',
        ),
      ],
      registeredAt: '2026-04-01T09:05:00.000Z',
    ),
    const ItemModel(
      id: '26040003',
      name: 'コンデンサ 100µF',
      description: 'アルミ電解コンデンサ 25V',
      categoryId: 'cat-001-2',
      categoryName: 'コンデンサ',
      features: [
        FeatureModel(
          code: '260400030101',
          colorCode: '01',
          sizeCode: '01',
          colorLabel: 'ブラック',
          sizeLabel: '25V',
          stockCount: 200,
          shelfId: 'A-02',
        ),
      ],
      registeredAt: '2026-04-02T10:00:00.000Z',
    ),
    const ItemModel(
      id: '26040004',
      name: 'M3ネジ 10mm',
      categoryId: 'cat-002-1',
      categoryName: 'ネジ',
      features: [
        FeatureModel(
          code: '260400040101',
          colorCode: '01',
          sizeCode: '01',
          colorLabel: 'シルバー',
          sizeLabel: '10mm',
          stockCount: 1000,
          shelfId: 'B-01',
        ),
        FeatureModel(
          code: '260400040102',
          colorCode: '01',
          sizeCode: '02',
          colorLabel: 'シルバー',
          sizeLabel: '20mm',
          stockCount: 800,
          shelfId: 'B-01',
        ),
      ],
      registeredAt: '2026-04-03T11:00:00.000Z',
    ),
    const ItemModel(
      id: '26040005',
      name: 'M3ボルト',
      categoryId: 'cat-002-2',
      categoryName: 'ボルト',
      features: [
        FeatureModel(
          code: '260400050101',
          colorCode: '01',
          sizeCode: '01',
          colorLabel: 'シルバー',
          sizeLabel: 'M3',
          stockCount: 500,
          shelfId: 'B-01',
        ),
      ],
      registeredAt: '2026-04-03T11:30:00.000Z',
    ),
    const ItemModel(
      id: '26040006',
      name: 'プチプチ 300mm×10m',
      categoryId: 'cat-003',
      categoryName: '梱包材',
      features: [
        FeatureModel(
          code: '260400060101',
          colorCode: '01',
          sizeCode: '01',
          colorLabel: 'クリア',
          sizeLabel: '300mm',
          stockCount: 50,
        ),
      ],
      registeredAt: '2026-04-04T08:00:00.000Z',
    ),
    const ItemModel(
      id: '26040007',
      name: 'NPN トランジスタ 2SC1815',
      categoryId: 'cat-001-3',
      categoryName: 'IC',
      features: [
        FeatureModel(
          code: '260400070101',
          colorCode: '01',
          sizeCode: '01',
          colorLabel: 'ブラック',
          sizeLabel: 'TO-92',
          stockCount: 150,
        ),
      ],
      registeredAt: '2026-04-05T09:00:00.000Z',
    ),
    const ItemModel(
      id: '26040008',
      name: 'PNP トランジスタ 2SA1015',
      categoryId: 'cat-001-3',
      categoryName: 'IC',
      features: [
        FeatureModel(
          code: '260400080101',
          colorCode: '01',
          sizeCode: '01',
          colorLabel: 'ブラック',
          sizeLabel: 'TO-92',
          stockCount: 120,
        ),
      ],
      registeredAt: '2026-04-05T09:30:00.000Z',
    ),
    const ItemModel(
      id: '26040009',
      name: 'M4ネジ 15mm',
      categoryId: 'cat-002-1',
      categoryName: 'ネジ',
      features: [
        FeatureModel(
          code: '260400090101',
          colorCode: '01',
          sizeCode: '01',
          colorLabel: 'シルバー',
          sizeLabel: '15mm',
          stockCount: 600,
        ),
      ],
      registeredAt: '2026-04-06T10:00:00.000Z',
    ),
    const ItemModel(
      id: '26040010',
      name: 'コンデンサ 10µF',
      categoryId: 'cat-001-2',
      categoryName: 'コンデンサ',
      features: [
        FeatureModel(
          code: '260400100101',
          colorCode: '01',
          sizeCode: '01',
          colorLabel: 'ブラック',
          sizeLabel: '50V',
          stockCount: 400,
        ),
      ],
      registeredAt: '2026-04-07T09:00:00.000Z',
    ),
  ];
}
