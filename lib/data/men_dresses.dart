import '../models/dress.dart';

// 7 pant-shirt pairs × 4 sizes = 28 entries
// 7 shalwar qameez styles × 4 sizes = 28 entries
// Total clothes only: 56 entries
//
// Important:
// This file uses local asset images.
// Make sure the image files exist in the exact paths used below.

const List<DressSize> _sizes = [
  DressSize.s,
  DressSize.m,
  DressSize.l,
  DressSize.xl,
];

String _sizeCode(DressSize size) {
  switch (size) {
    case DressSize.s:
      return 's';
    case DressSize.m:
      return 'm';
    case DressSize.l:
      return 'l';
    case DressSize.xl:
      return 'xl';
  }
}

List<Dress> _buildSizedDresses({
  required String idPrefix,
  required String title,
  required String description,
  required double price,
  required String imageUrl,
  required DressType type,
}) {
  return _sizes.map((size) {
    return Dress(
      id: '${idPrefix}_${_sizeCode(size)}',
      title: title,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: DressCategory.men,
      type: type,
      size: size,
    );
  }).toList(growable: false);
}

final List<Dress> menDresses = [
  ..._buildSizedDresses(
    idPrefix: 'ps_1',
    title: 'Formal White Shirt & Black Pant Pair',
    description:
    'Complete formal pant-shirt pair with a classic white dress shirt and slim-fit black pant. Perfect for office, interviews and formal events.',
    price: 3800.0,
    imageUrl: 'assets/images/men/pant_shirt/ps_1.png',
    type: DressType.pantShirt,
  ),

  ..._buildSizedDresses(
    idPrefix: 'ps_2',
    title: 'Checkered Shirt & Navy Pant Pair',
    description:
    'Stylish casual pair with red and navy checkered shirt and matching navy pant. Best for smart-casual daily wear.',
    price: 3400.0,
    imageUrl: 'assets/images/men/pant_shirt/ps_2.png',
    type: DressType.pantShirt,
  ),

  ..._buildSizedDresses(
    idPrefix: 'ps_3',
    title: 'Navy Polo Shirt & Khaki Pant Pair',
    description:
    'Comfortable pant-shirt pair with navy blue polo shirt and khaki pant. Good choice for casual outings and summer wear.',
    price: 3200.0,
    imageUrl: 'assets/images/men/pant_shirt/ps_3.png',
    type: DressType.pantShirt,
  ),

  ..._buildSizedDresses(
    idPrefix: 'ps_4',
    title: 'Sky Blue Shirt & Charcoal Pant Pair',
    description:
    'Elegant pair with sky blue Oxford shirt and charcoal pant. Suitable for meetings, office use and semi-formal events.',
    price: 3600.0,
    imageUrl: 'assets/images/men/pant_shirt/ps_4.png',
    type: DressType.pantShirt,
  ),

  ..._buildSizedDresses(
    idPrefix: 'ps_5',
    title: 'Olive Shirt & Beige Chino Pair',
    description:
    'Modern casual pair with olive green shirt and beige chino pant. Light, breathable and ideal for daily wear.',
    price: 3350.0,
    imageUrl: 'assets/images/men/pant_shirt/ps_5.png',
    type: DressType.pantShirt,
  ),

  ..._buildSizedDresses(
    idPrefix: 'ps_6',
    title: 'Black Shirt & Grey Trouser Pair',
    description:
    'Premium pair with black shirt and grey trouser. A sharp outfit for dinners, functions and formal gatherings.',
    price: 3900.0,
    imageUrl: 'assets/images/men/pant_shirt/ps_6.png',
    type: DressType.pantShirt,
  ),

  ..._buildSizedDresses(
    idPrefix: 'ps_7',
    title: 'Denim Shirt & Black Jeans Pair',
    description:
    'Trendy casual pair with denim shirt and black jeans. Best for college, outings and everyday fashion.',
    price: 4100.0,
    imageUrl: 'assets/images/men/pant_shirt/ps_7.png',
    type: DressType.pantShirt,
  ),

  ..._buildSizedDresses(
    idPrefix: 'sq_1',
    title: 'Classic White Shalwar Qameez',
    description:
    'Traditional white cotton shalwar qameez, perfect for casual and formal wear. A wardrobe staple.',
    price: 2500.0,
    imageUrl: 'assets/images/men/shalwar_qameez/sq_1.png',
    type: DressType.shalwarQameez,
  ),

  ..._buildSizedDresses(
    idPrefix: 'sq_2',
    title: 'Embroidered Blue Shalwar Qameez',
    description:
    'Premium embroidered royal-blue qameez with matching shalwar. Ideal for Eid celebrations and weddings.',
    price: 4200.0,
    imageUrl: 'assets/images/men/shalwar_qameez/sq_2.png',
    type: DressType.shalwarQameez,
  ),

  ..._buildSizedDresses(
    idPrefix: 'sq_3',
    title: 'Grey Linen Shalwar Qameez',
    description:
    'Lightweight grey linen shalwar qameez — breathable and comfortable, perfect for hot Pakistani summers.',
    price: 3200.0,
    imageUrl: 'assets/images/men/shalwar_qameez/sq_3.png',
    type: DressType.shalwarQameez,
  ),

  ..._buildSizedDresses(
    idPrefix: 'sq_4',
    title: 'Black Luxury Shalwar Qameez',
    description:
    'Rich black fabric with subtle silver thread work. Ideal for formal dinners, engagements and evening events.',
    price: 5500.0,
    imageUrl: 'assets/images/men/shalwar_qameez/sq_4.png',
    type: DressType.shalwarQameez,
  ),

  ..._buildSizedDresses(
    idPrefix: 'sq_5',
    title: 'Mint Green Lawn Shalwar Qameez',
    description:
    'Fresh mint-green lawn fabric shalwar qameez. Light, airy and perfect for casual daytime outings.',
    price: 2800.0,
    imageUrl: 'assets/images/men/shalwar_qameez/sq_5.png',
    type: DressType.shalwarQameez,
  ),

  ..._buildSizedDresses(
    idPrefix: 'sq_6',
    title: 'Maroon Khaddar Shalwar Qameez',
    description:
    'Warm maroon khaddar shalwar qameez — thick, cozy fabric ideal for winter months and chilly evenings.',
    price: 3800.0,
    imageUrl: 'assets/images/men/shalwar_qameez/sq_6.png',
    type: DressType.shalwarQameez,
  ),

  ..._buildSizedDresses(
    idPrefix: 'sq_7',
    title: 'Beige Printed Shalwar Qameez',
    description:
    'Elegant beige shalwar qameez with subtle geometric print. Great for semi-formal family gatherings.',
    price: 3500.0,
    imageUrl: 'assets/images/men/shalwar_qameez/sq_7.png',
    type: DressType.shalwarQameez,
  ),
];

const Set<DressType> _allowedMenClothingTypes = {
  DressType.pantShirt,
  DressType.shalwarQameez,
};

bool _isMenClothing(Dress dress) {
  return dress.category == DressCategory.men &&
      _allowedMenClothingTypes.contains(dress.type);
}

final List<Dress> menClothesOnly = menDresses.where(_isMenClothing).toList(
  growable: false,
);