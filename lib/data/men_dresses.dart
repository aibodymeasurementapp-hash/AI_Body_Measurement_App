import '../models/dress.dart';

// 8 dress styles × 4 sizes = 32 entries
// Categories: Pant Shirt & Shalwar Qameez only

const List<Dress> menDresses = [

  // ══════════════════════════════════════════════════════════════════
  // PANT SHIRT
  // ══════════════════════════════════════════════════════════════════

  // Formal White Shirt
  Dress(id: 'ps_1_s',  title: 'Formal White Dress Shirt', description: 'Classic white formal shirt, perfect for office and formal events.', price: 1800, imageUrl: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.s),
  Dress(id: 'ps_1_m',  title: 'Formal White Dress Shirt', description: 'Classic white formal shirt, perfect for office and formal events.', price: 1800, imageUrl: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.m),
  Dress(id: 'ps_1_l',  title: 'Formal White Dress Shirt', description: 'Classic white formal shirt, perfect for office and formal events.', price: 1800, imageUrl: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.l),
  Dress(id: 'ps_1_xl', title: 'Formal White Dress Shirt', description: 'Classic white formal shirt, perfect for office and formal events.', price: 1800, imageUrl: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.xl),

  // Casual Checkered Shirt
  Dress(id: 'ps_2_s',  title: 'Casual Checkered Shirt', description: 'Stylish checkered casual shirt for everyday smart casual look.', price: 1400, imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.s),
  Dress(id: 'ps_2_m',  title: 'Casual Checkered Shirt', description: 'Stylish checkered casual shirt for everyday smart casual look.', price: 1400, imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.m),
  Dress(id: 'ps_2_l',  title: 'Casual Checkered Shirt', description: 'Stylish checkered casual shirt for everyday smart casual look.', price: 1400, imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.l),
  Dress(id: 'ps_2_xl', title: 'Casual Checkered Shirt', description: 'Stylish checkered casual shirt for everyday smart casual look.', price: 1400, imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.xl),

  // Navy Blue Polo
  Dress(id: 'ps_3_s',  title: 'Navy Blue Polo Shirt', description: 'Comfortable navy blue polo shirt with khaki chinos for a smart casual look.', price: 1200, imageUrl: 'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.s),
  Dress(id: 'ps_3_m',  title: 'Navy Blue Polo Shirt', description: 'Comfortable navy blue polo shirt with khaki chinos for a smart casual look.', price: 1200, imageUrl: 'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.m),
  Dress(id: 'ps_3_l',  title: 'Navy Blue Polo Shirt', description: 'Comfortable navy blue polo shirt with khaki chinos for a smart casual look.', price: 1200, imageUrl: 'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.l),
  Dress(id: 'ps_3_xl', title: 'Navy Blue Polo Shirt', description: 'Comfortable navy blue polo shirt with khaki chinos for a smart casual look.', price: 1200, imageUrl: 'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.xl),

  // Slim Fit Black Trousers
  Dress(id: 'ps_4_s',  title: 'Slim Fit Black Trousers', description: 'Classic slim fit black trousers, pairs well with any formal or casual shirt.', price: 2200, imageUrl: 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.s),
  Dress(id: 'ps_4_m',  title: 'Slim Fit Black Trousers', description: 'Classic slim fit black trousers, pairs well with any formal or casual shirt.', price: 2200, imageUrl: 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.m),
  Dress(id: 'ps_4_l',  title: 'Slim Fit Black Trousers', description: 'Classic slim fit black trousers, pairs well with any formal or casual shirt.', price: 2200, imageUrl: 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.l),
  Dress(id: 'ps_4_xl', title: 'Slim Fit Black Trousers', description: 'Classic slim fit black trousers, pairs well with any formal or casual shirt.', price: 2200, imageUrl: 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.pantShirt, size: DressSize.xl),

  // ══════════════════════════════════════════════════════════════════
  // SHALWAR QAMEEZ
  // ══════════════════════════════════════════════════════════════════

  // Classic White
  Dress(id: 'sq_1_s',  title: 'Classic White Shalwar Qameez', description: 'Traditional white cotton shalwar qameez, perfect for casual and formal wear.', price: 2500, imageUrl: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.s),
  Dress(id: 'sq_1_m',  title: 'Classic White Shalwar Qameez', description: 'Traditional white cotton shalwar qameez, perfect for casual and formal wear.', price: 2500, imageUrl: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.m),
  Dress(id: 'sq_1_l',  title: 'Classic White Shalwar Qameez', description: 'Traditional white cotton shalwar qameez, perfect for casual and formal wear.', price: 2500, imageUrl: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.l),
  Dress(id: 'sq_1_xl', title: 'Classic White Shalwar Qameez', description: 'Traditional white cotton shalwar qameez, perfect for casual and formal wear.', price: 2500, imageUrl: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.xl),

  // Embroidered Blue
  Dress(id: 'sq_2_s',  title: 'Embroidered Blue Shalwar Qameez', description: 'Premium embroidered blue qameez with matching shalwar, ideal for Eid and weddings.', price: 4200, imageUrl: 'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.s),
  Dress(id: 'sq_2_m',  title: 'Embroidered Blue Shalwar Qameez', description: 'Premium embroidered blue qameez with matching shalwar, ideal for Eid and weddings.', price: 4200, imageUrl: 'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.m),
  Dress(id: 'sq_2_l',  title: 'Embroidered Blue Shalwar Qameez', description: 'Premium embroidered blue qameez with matching shalwar, ideal for Eid and weddings.', price: 4200, imageUrl: 'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.l),
  Dress(id: 'sq_2_xl', title: 'Embroidered Blue Shalwar Qameez', description: 'Premium embroidered blue qameez with matching shalwar, ideal for Eid and weddings.', price: 4200, imageUrl: 'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.xl),

  // Grey Linen
  Dress(id: 'sq_3_s',  title: 'Grey Linen Shalwar Qameez', description: 'Lightweight grey linen shalwar qameez, breathable and comfortable for summer.', price: 3200, imageUrl: 'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.s),
  Dress(id: 'sq_3_m',  title: 'Grey Linen Shalwar Qameez', description: 'Lightweight grey linen shalwar qameez, breathable and comfortable for summer.', price: 3200, imageUrl: 'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.m),
  Dress(id: 'sq_3_l',  title: 'Grey Linen Shalwar Qameez', description: 'Lightweight grey linen shalwar qameez, breathable and comfortable for summer.', price: 3200, imageUrl: 'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.l),
  Dress(id: 'sq_3_xl', title: 'Grey Linen Shalwar Qameez', description: 'Lightweight grey linen shalwar qameez, breathable and comfortable for summer.', price: 3200, imageUrl: 'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.xl),

  // Black Luxury
  Dress(id: 'sq_4_s',  title: 'Black Luxury Shalwar Qameez', description: 'Rich black fabric with subtle thread work, ideal for formal events and dinners.', price: 5500, imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.s),
  Dress(id: 'sq_4_m',  title: 'Black Luxury Shalwar Qameez', description: 'Rich black fabric with subtle thread work, ideal for formal events and dinners.', price: 5500, imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.m),
  Dress(id: 'sq_4_l',  title: 'Black Luxury Shalwar Qameez', description: 'Rich black fabric with subtle thread work, ideal for formal events and dinners.', price: 5500, imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.l),
  Dress(id: 'sq_4_xl', title: 'Black Luxury Shalwar Qameez', description: 'Rich black fabric with subtle thread work, ideal for formal events and dinners.', price: 5500, imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&h=500&fit=crop', category: DressCategory.men, type: DressType.shalwarQameez, size: DressSize.xl),
];