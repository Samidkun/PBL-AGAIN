class CategoryModel {
  final int id;
  final String code;
  final String name;
  final String type;
  final int price;
  final String? image;

  CategoryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.price,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      type: json['type'],
      price: json['price'],
      image: json['image'],
    );
  }
}
