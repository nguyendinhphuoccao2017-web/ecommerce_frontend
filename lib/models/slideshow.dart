class Slideshow {
  final String id;
  final String? title;
  final String? destinationUrl;
  final String image;
  final String? placeholder;
  final String? description;
  final String? bmLabel;
  final int displayOrder;
  final bool published;
  final int clicks;

  Slideshow({
    required this.id,
    this.title,
    this.destinationUrl,
    required this.image,
    this.placeholder,
    this.description,
    this.bmLabel,
    required this.displayOrder,
    required this.published,
    required this.clicks,
  });

  factory Slideshow.fromJson(Map<String, dynamic> json) {
    return Slideshow(
      id: json['id'] ?? '',
      title: json['title'],
      destinationUrl: json['destinationUrl'],
      image: json['image'] ?? '',
      placeholder: json['placeholder'],
      description: json['description'],
      bmLabel: json['bmLabel'],
      displayOrder: json['displayOrder'] ?? 0,
      published: json['published'] ?? false,
      clicks: json['clicks'] ?? 0,
    );
  }
}
