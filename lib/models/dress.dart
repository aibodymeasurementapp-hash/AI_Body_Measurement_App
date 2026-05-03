enum DressCategory { men, women, kids }

// Matches naming used in DressTypeScreen exactly
enum DressType { pantShirt, shalwarQameez }

enum DressSize { s, m, l, xl }

class Dress {
  final String        id;
  final String        title;
  final String        description;
  final double        price;
  final String        imageUrl;
  final DressCategory category;
  final DressType     type;
  final DressSize     size;

  const Dress({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.type,
    required this.size,
  });

  // ── Display helpers ──────────────────────────────────────────────

  String get sizeLabel {
    switch (size) {
      case DressSize.s:  return 'S';
      case DressSize.m:  return 'M';
      case DressSize.l:  return 'L';
      case DressSize.xl: return 'XL';
    }
  }

  String get typeLabel {
    switch (type) {
      case DressType.pantShirt:     return 'Pant Shirt';
      case DressType.shalwarQameez: return 'Shalwar Qameez';
    }
  }

  String get categoryLabel {
    switch (category) {
      case DressCategory.men:   return 'Men';
      case DressCategory.women: return 'Women';
      case DressCategory.kids:  return 'Kids';
    }
  }

  String get priceLabel => 'PKR ${price.toStringAsFixed(0)}';

  // ── Serialization (ready for Firebase later) ─────────────────────

  Map<String, dynamic> toJson() => {
    'id':          id,
    'title':       title,
    'description': description,
    'price':       price,
    'imageUrl':    imageUrl,
    'category':    category.name,
    'type':        type.name,
    'size':        size.name,
  };

  factory Dress.fromJson(Map<String, dynamic> json) => Dress(
    id:          json['id'],
    title:       json['title'],
    description: json['description'],
    price:       (json['price'] as num).toDouble(),
    imageUrl:    json['imageUrl'],
    category:    DressCategory.values.byName(json['category']),
    type:        DressType.values.byName(json['type']),
    size:        DressSize.values.byName(json['size']),
  );
}