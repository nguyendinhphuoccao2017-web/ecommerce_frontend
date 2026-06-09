class Category {
  final String id;
  final String categoryName;
  final String? categoryDescription;
  final String? icon;
  final String? image;

  Category({
    required this.id,
    required this.categoryName,
    this.categoryDescription,
    this.icon,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryDescription: json['categoryDescription'],
      icon: json['icon'],
      image: json['image'],
    );
  }
}
