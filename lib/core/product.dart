class Product {
  final String name;
  final String unit;
  final double price;
  final String category;

  const Product({
    required this.name,
    required this.unit,
    required this.price,
    required this.category,
  });
}

const List<Product> products = [
  // Meat, Poultry & Seafood
  Product(name: "القطاع لحوم كتل مميز حسب الوزن", unit: "KG", price: 275, category: "لحوم"),
  Product(name: "القطاع لحم كتل بالوزن", unit: "KG", price: 271, category: "لحوم"),
  Product(name: "القطاع لحم مجمد 1ك", unit: "PC", price: 259, category: "لحوم"),
  Product(name: "القطاع لحم مفروم 800جم", unit: "PC", price: 206, category: "لحوم"),
  Product(name: "القطاع لحم مفروم 500جم", unit: "PC", price: 128, category: "لحوم"),
  Product(name: "القطاع لحم قطع مميز 1كيلو", unit: "PC", price: 280, category: "لحوم"),
  Product(name: "بانيه 1 كيلو خدمات بيطرية", unit: "PC", price: 230, category: "دواجن"),
  Product(name: "دواجن لوجيستيك 1000-1100", unit: "PC", price: 120, category: "دواجن"),
  Product(name: "دواجن تحت الوزن خدمات بيطرية", unit: "PC", price: 115, category: "دواجن"),
  Product(name: "دواجن لوجيستيك 1200/1300", unit: "PC", price: 163, category: "دواجن"),
  Product(name: "شيش 1ك خدمات بيطرية", unit: "PC", price: 196, category: "دواجن"),
  Product(name: "شيش 1ك خدمات بيطرية مزرعة سمكية", unit: "PC", price: 210, category: "دواجن"),
  Product(name: "وراك 1ك خدمات بيطرية مزرعة سمكية", unit: "PC", price: 114, category: "دواجن"),
  Product(name: "كبد وقوانص 500جم", unit: "PC", price: 45, category: "دواجن"),
  Product(name: "جمبري غليون الفيروز 40/50 كامل", unit: "PC", price: 465, category: "أسماك"),
  Product(name: "جمبري غليون 50/60 (500جم)", unit: "PC", price: 230, category: "أسماك"),
  Product(name: "جمبري غليون 40/50 (500جم)", unit: "PC", price: 240, category: "أسماك"),
  Product(name: "جمبري سكاي فيش كبير 400جم", unit: "KG", price: 360, category: "أسماك"),
  Product(name: "جمبري الفيروز 50/60 1ك", unit: "PC", price: 375, category: "أسماك"),
  Product(name: "سمك بوري بالوزن", unit: "PC", price: 175, category: "أسماك"),
  Product(name: "سمك بلطي منزوع 1ك غليون", unit: "PC", price: 125, category: "أسماك"),
  Product(name: "سمك بلطي منزوع المعدية", unit: "PC", price: 120, category: "أسماك"),
  Product(name: "شوربة سي فود 800جم", unit: "PC", price: 115, category: "أسماك"),
  Product(name: "سي فود 500جم", unit: "PC", price: 85, category: "أسماك"),
  Product(name: "غليون فليه بلطي 500جم", unit: "PC", price: 139, category: "أسماك"),
  Product(name: "اصابع كابوريا 250جم", unit: "PC", price: 40, category: "أسماك"),
  Product(name: "الوطنية بيف برجر 1ك", unit: "PC", price: 165, category: "مجمدات"),
  Product(name: "الوطنية سجق 400جم", unit: "PC", price: 85, category: "مجمدات"),
  Product(name: "استربس 1ك", unit: "PC", price: 195, category: "مجمدات"),

  // Vegetables & Dairy
  Product(name: "بامية ممتاز اجا 400جم", unit: "PC", price: 26, category: "خضروات"),
  Product(name: "بامية مجمدة قطوف 400جم", unit: "PC", price: 40, category: "خضروات"),
  Product(name: "موزاريلا زيزونا 200جم", unit: "PC", price: 40, category: "جبن"),
  Product(name: "سمبوسك جبن 400جم", unit: "PC", price: 60, category: "مجمدات"),
  Product(name: "زبدة جاموسي 1ك", unit: "PC", price: 120, category: "ألبان"),
  Product(name: "سمن جاموسي 1ك", unit: "PC", price: 135, category: "ألبان"),
  Product(name: "سمن بقري 1ك", unit: "PC", price: 135, category: "ألبان"),
  Product(name: "ملوخية مجمدة سيزونز 400جم", unit: "PC", price: 18, category: "خضروات"),
  Product(name: "ملوخية مجمدة اجا 400جم", unit: "PC", price: 17, category: "خضروات"),
  Product(name: "موزاريلا زيزونا طبيعي 500جم", unit: "PC", price: 95, category: "جبن"),

  // Grocery & Oils
  Product(name: "زيت عباد تحيا مصر 1 لتر", unit: "PC", price: 85, category: "زيوت"),
  Product(name: "زيت وطنية عباد 1 لتر", unit: "PC", price: 85, category: "زيوت"),
  Product(name: "زيت تحيا مصر خليط 700مل", unit: "PC", price: 50, category: "زيوت"),
  Product(name: "زيت شقاوة خليط 700مل", unit: "PC", price: 47, category: "زيوت"),
  Product(name: "زيت زيتون بكر 500مل", unit: "PC", price: 185, category: "زيوت"),
  Product(name: "زيت زيتون بكر 250مل", unit: "PC", price: 115, category: "زيوت"),
  Product(name: "صافي زيت زيتون 250مل", unit: "PC", price: 185, category: "زيوت"),
  Product(name: "زيت زيتون بكر 1 لتر", unit: "PC", price: 345, category: "زيوت"),
  Product(name: "ملح صافي 300جم", unit: "PC", price: 2, category: "بقالة"),
  Product(name: "ملح صافي 700جم", unit: "PC", price: 4, category: "بقالة"),
  Product(name: "أرز سوليتير عريض 1ك", unit: "PC", price: 30, category: "بقالة"),
  Product(name: "أرز الملكي 5ك", unit: "PC", price: 162, category: "بقالة"),
  Product(name: "أرز سوليتير 10ك", unit: "PC", price: 320, category: "بقالة"),
  Product(name: "قها صلصة 300جم", unit: "PC", price: 19, category: "بقالة"),
  Product(name: "قها صلصة 750جم", unit: "PC", price: 52, category: "بقالة"),
  Product(name: "قها صلصة ظرف 300جم", unit: "PC", price: 13, category: "بقالة"),
];