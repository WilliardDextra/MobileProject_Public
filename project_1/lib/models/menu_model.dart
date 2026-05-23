class Menu {
  final int id;
  final int bakeryId;
  final String fName;
  final String fImage;
  final String fDescription;
  final double fPrice;
  final double fRating;
  final int fSold;
  final int fStock;
  final int? isActive;

  Menu({
    required this.id,
    required this.bakeryId,
    required this.fName,
    required this.fImage,
    required this.fDescription,
    required this.fPrice,
    required this.fRating,
    required this.fSold,
    required this.fStock,
    required this.isActive,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      bakeryId: json['bakery_id'], // Sesuai dengan kolom di database
      fName: json['f_name'] ?? "No Name",
      fImage: json['f_image'] ?? "",
      fDescription: json['f_description'] ?? "",
      fPrice: double.parse(json['f_price'].toString()),
      fRating: double.parse((json['f_rating'] ?? 0.0).toString()),
      fSold: json['f_sold'] ?? 0,
      fStock: json['f_stock'] ?? 0,
      isActive: json['is_active'] ?? 1,
    );
  }
}
