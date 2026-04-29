class Bakery {
  final int id;
  final String name;
  final String image;
  final double rating;
  final double distance;
  final String duration;
  final int stock;

  Bakery({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.distance,
    required this.duration,
    required this.stock,
  });

  // Fungsi Factory untuk mengubah JSON (dari Node.js) menjadi Object Bakery
  factory Bakery.fromJson(Map<String, dynamic> json) {
    return Bakery(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      // Kita gunakan .toDouble() dan .toString() untuk mencegah error
      // jika tipe data di MySQL sedikit berbeda (misal: String vs Double)
      rating: double.parse(json['rating'].toString()),
      distance: double.parse(json['distance'].toString()),
      duration: json['duration'],
      stock: int.parse(json['stock'].toString()),
    );
  }

  // (Opsional) Fungsi untuk mengubah Object kembali ke JSON jika ingin mengirim data ke BE
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'distance': distance,
      'duration': duration,
      'stock': stock,
    };
  }
}
