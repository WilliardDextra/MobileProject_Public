import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project_1/colorPallette.dart';
import 'package:project_1/models/bakery_model.dart';
import 'package:project_1/productDetails.dart';
import 'package:project_1/services/api_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ApiService _bakeryService = ApiService();
  late Future<List<Bakery>> _bakeryFuture;

  @override
  void initState() {
    super.initState();

    _bakeryFuture = _bakeryService.fetchBakeries();

    _bakeryFuture.then((data) {
      setState(() {
        _allFoods = data;
        _foundFoods = _allFoods;
      });
    });
  }

  List<Bakery> _allFoods = [];
  List<Bakery> _foundFoods = [];

  void _runFilter(String enteredKeyword) {
    List<Bakery> results = [];

    if (enteredKeyword.isEmpty) {
      results = _allFoods;
    } else {
      results = _allFoods
          .where(
            (food) =>
                food.name.toLowerCase().contains(enteredKeyword.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      _foundFoods = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchButton(_runFilter),
            const SizedBox(height: 12),
            _buildSpecialOfferBox(),
            const SizedBox(height: 10),

            FutureBuilder<List<Bakery>>(
              future: _bakeryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(50),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Database Kosong"));
                }

                if (_foundFoods.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Food not found...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Wrap(
                  spacing: -12,
                  runSpacing: -10,
                  children: _foundFoods.map((food) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          print("Move To: ${food.name} with ID: ${food.id}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(productDetail: food),
                            ),
                          );
                        },
                        child: _buildFoodSearchCard(
                          food.name,
                          food.image,
                          food.rating,
                          food.distance,
                          food.duration,
                          food.stock,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton(Function(String) onSearch) {
    return Column(
      children: [
        const SizedBox(height: 12),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                Positioned(
                  top: -10,
                  bottom: -10,
                  left: -5,
                  right: -5,
                  child: Lottie.asset(
                    'animation/SearchBarAnimation.json',
                    fit: BoxFit.fitWidth,
                    repeat: true,
                  ),
                ),

                Positioned.fill(
                  child: Container(color: Colors.white.withValues(alpha: 0.5)),
                ),

                Positioned.fill(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    color: Colors.transparent,
                    child: Center(
                      child: TextField(
                        onChanged: (value) => onSearch(value),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: "Search Food...",
                          hintStyle: TextStyle(color: Colors.black54),

                          prefixIcon: Icon(
                            Icons.search,
                            color: Color.fromARGB(255, 0, 96, 96),
                            size: 20,
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 30,
                            minHeight: 20,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodSearchCard(
    String name,
    String imagePath,
    double rating,
    double distance,
    String duration,
    int stock,
  ) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          height: 214,
          width: 150,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 96, 96),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withAlpha(120),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 116),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  "$distance Km ● $duration min",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 44, bottom: 8),
                child: Text(
                  "Stock: $stock │ ★$rating",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          height: 115,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withAlpha(100),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialOfferBox() {
    return Container(
      height: 276,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.cream),
      child: ClipRRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: const Color.fromARGB(130, 255, 255, 255)),
            ),

            Column(
              children: [
                SizedBox(height: 12),
                Text(
                  "Quality Food, Affordable Budget",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                SizedBox(height: 4),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      direction: Axis.vertical,
                      children: [
                        _buildHorizontalCard(
                          "Honey Pastry Bakery",
                          "images/bakery_background.png",
                          20,
                          4.6,
                        ),
                        _buildHorizontalCard(
                          "Locos Tacos Nacos",
                          "images/tacos_background.jpg",
                          4,
                          4.8,
                        ),
                        _buildHorizontalCard(
                          "Honey Pastry Bakery",
                          "images/bakery_background.png",
                          20,
                          4.4,
                        ),
                        _buildHorizontalCard(
                          "Honey Pastry Bakery",
                          "images/bakery_background.png",
                          20,
                          4.4,
                        ),
                        _buildHorizontalCard(
                          "Honey Pastry Bakery",
                          "images/bakery_background.png",
                          20,
                          4.6,
                        ),
                        _buildHorizontalCard(
                          "Locos Tacos Nacos",
                          "images/tacos_background.jpg",
                          4,
                          4.8,
                        ),
                        _buildHorizontalCard(
                          "Honey Pastry Bakery",
                          "images/bakery_background.png",
                          20,
                          4.4,
                        ),
                        _buildHorizontalCard(
                          "Honey Pastry Bakery",
                          "images/bakery_background.png",
                          20,
                          4.4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(
    String name,
    String imagePath,
    int stock,
    double rating,
  ) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          height: 100,
          width: 250,
          decoration: BoxDecoration(
            color: AppColors.stormyTeal,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withAlpha(120),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 105, top: 8),
                child: Text(
                  name,
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 58, top: 2),
                child: Text(
                  "Stock: $stock │ ★$rating",
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 90, top: 6),
                height: 16,
                width: 130,
                decoration: BoxDecoration(
                  color: AppColors.tigerFlame,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Text(
                  "Last Offer!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 96, 96),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withAlpha(80),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(3, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}
