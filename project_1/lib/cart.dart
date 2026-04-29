import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCartBox(
              "Morning Stack Pancake",
              "images/pancake_background.jpg",
              4.4,
              DateTime(2026, 04, 25),
              "Completed",
              "Butter Seared Pancake With extra Caramel Sauce and Whip Cream with utensils",
              20000,
              1,
            ),
            _buildCartBox(
              "Nisemono Tokyo Ramen",
              "images/noodle_background.png",
              4.6,
              DateTime(2026, 05, 26),
              "Completed",
              "Ramen with rich autentic chicken broth, and a hand made noodle",
              96000,
              3,
            ),
            _buildCartBox(
              "Morning Stack Pancake",
              "images/pancake_background.jpg",
              4.4,
              DateTime(2026, 04, 25),
              "Completed",
              "Butter Seared Pancake With extra Caramel Sauce and Whip Cream with utensils",
              20000,
              1,
            ),
            _buildCartBox(
              "Nisemono Tokyo Ramen",
              "images/noodle_background.png",
              4.6,
              DateTime(2026, 05, 26),
              "Completed",
              "Ramen with rich autentic chicken broth, and a hand made noodle",
              96000,
              3,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCartBox(
  String name,
  String imagePath,
  double rating,
  DateTime purchaseDate,
  String status,
  String menuPurchased,
  int price,
  int quantity,
) {
  return Stack(
    children: [
      Container(
        margin: EdgeInsets.only(top: 28, bottom: 12),
        width: double.infinity,
        height: 270,
        padding: EdgeInsets.only(top: 100),
        decoration: BoxDecoration(
          color: const Color.fromARGB(130, 0, 96, 96),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Lottie.asset(
                'animation/BackgroundMain.json',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, top: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rp$price,00",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "$quantity Items",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(right: 30),
                          width: 90,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(width: 2, color: Colors.black),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Reorder",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  width: 320,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(width: 3, color: Colors.black),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Rate Your Food: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 60),
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      Icon(Icons.star, color: Colors.orange, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      Container(
        margin: EdgeInsets.only(top: 28, bottom: 12),
        width: double.infinity,
        height: 118,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 247, 174, 110),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            SizedBox(width: 12),
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 110,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black, width: 2),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Positioned(
                  bottom: -12,
                  child: Container(
                    width: 60,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 2, color: Colors.black),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "★$rating",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6),
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(purchaseDate)} ● $status',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      menuPurchased,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
