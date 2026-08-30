import 'package:flutter/foundation.dart';

@immutable
class ShopItem {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final double price;
  /// 可选 i18n key:非空时显示用 context.t(nameKey),用于内置默认商品双语。
  /// 用户自建商品为 null,直接用 name 文本。
  final String? nameKey;
  final String? descKey;

  const ShopItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.price,
    this.nameKey,
    this.descKey,
  });

  ShopItem copyWith({
    String? name,
    String? emoji,
    String? description,
    double? price,
    String? nameKey,
    String? descKey,
  }) =>
      ShopItem(
        id: id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        description: description ?? this.description,
        price: price ?? this.price,
        nameKey: nameKey ?? this.nameKey,
        descKey: descKey ?? this.descKey,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'description': description,
        'price': price,
        if (nameKey != null) 'nameKey': nameKey,
        if (descKey != null) 'descKey': descKey,
      };

  factory ShopItem.fromJson(Map<String, dynamic> j) => ShopItem(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        emoji: j['emoji'] as String? ?? '🎁',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        nameKey: j['nameKey'] as String?,
        descKey: j['descKey'] as String?,
      );
}

@immutable
class Purchase {
  final String id;
  final String itemName;
  final String emoji;
  final double price;
  final DateTime at;

  const Purchase({
    required this.id,
    required this.itemName,
    required this.emoji,
    required this.price,
    required this.at,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemName': itemName,
        'emoji': emoji,
        'price': price,
        'at': at.toIso8601String(),
      };

  factory Purchase.fromJson(Map<String, dynamic> j) => Purchase(
        id: j['id'] as String? ?? '',
        itemName: j['itemName'] as String? ?? '',
        emoji: j['emoji'] as String? ?? '🎁',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        at: j['at'] != null
            ? DateTime.tryParse(j['at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
