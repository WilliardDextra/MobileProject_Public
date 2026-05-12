class Bakery {
  final int id;
  final String name;
  final String image;
  final double rating;
  final double distance;
  final String duration;
  final int stock;
  final String closing_time;

  Bakery({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.distance,
    required this.duration,
    required this.stock,
    required this.closing_time,
  });

  factory Bakery.fromJson(Map<String, dynamic> json) {
    return Bakery(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      rating: double.parse(json['rating'].toString()),
      distance: double.parse(json['distance'].toString()),
      duration: json['duration'],
      stock: int.parse(json['stock'].toString()),
      closing_time: json['closing_time']?.toString() ?? "-",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'distance': distance,
      'duration': duration,
      'stock': stock,
      'closing_time': closing_time,
    };
  }
}
