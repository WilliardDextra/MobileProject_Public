import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:project_1/register_page.dart';
import 'package:provider/provider.dart';
import 'colorPallette.dart';
import 'search.dart';
import 'cart.dart';
import 'providers/cart_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,

          canvasColor: Colors.white,
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),

        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const Center(child: Text("Status Page")),
      const SearchPage(),
      _buildLandingPage(),
      CartPage(),
      const Center(child: Text("Account Page")),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.stormyTeal,
        elevation: 6,
        centerTitle: true,
        shadowColor: Colors.black,
        leading: IconButton(
          icon: CircleAvatar(
            radius: 17,
            backgroundColor: Colors.white,
            child: FaIcon(
              FontAwesomeIcons.cartShopping,
              color: AppColors.stormyTeal,
              size: 16,
            ),
          ),
          onPressed: () {
            _onItemTapped(3);
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("images/FoodSaver_Orange_Main.png", height: 30),
            const SizedBox(width: 6),
            const Text(
              "FoodSaver",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.tigerFlame,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white,
              child: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                color: AppColors.stormyTeal,
                size: 16,
              ),
            ),
            onPressed: () {
              _onItemTapped(1);
            },
          ),
        ],
      ),

      body: IndexedStack(index: _selectedIndex, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 0, 96, 96),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Status',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildLandingPage() {
    return Stack(
      children: [
        Positioned.fill(
          child: Lottie.asset(
            'animation/BackgroundMain2.2.json',
            fit: BoxFit.cover,
            repeat: true,
          ),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.white.withAlpha(125)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Discover Your Taste With Low Price",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 96, 96),
                  ),
                ),

                Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(height: 120),
                          _foodCard("Pastry", "images/pastry.png"),
                          _foodCard("Tacos", "images/tacos.png"),
                          _foodCard("Sushi", "images/sushi.png"),
                          _foodCard("Steak", "images/steak.png"),
                          _foodCard("Breakfast", "images/englishBreakfast.png"),
                          _foodCard("Pancake", "images/pancake.png"),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 24,
                      right: 2,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),

                        child: Lottie.asset(
                          'animation/ScrollAnimation.json',
                          width: 44,
                        ),
                      ),
                    ),
                  ],
                ),
                _userCard(),
                _buildDescriptionBox(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _userCard() {
    return SlideInUp(
      duration: const Duration(milliseconds: 800),
      from: 200,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withAlpha(100),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(3, 3),
            ),
          ],
        ),

        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 24),
                    Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Image.asset(
                        "images/FoodSaver_Green.png",
                        fit: BoxFit.cover,
                        height: 80,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                            "Welcome Back User",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.stormyTeal,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "You Saved 35 Portion",
                            style: TextStyle(
                              color: AppColors.stormyTeal,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(
              color: AppColors.stormyTeal,
              thickness: 1.5,
              indent: 20,
              endIndent: 20,
            ),

            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    Container(
                      height: 60,
                      width: 140,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "images/Voucher_Icon.png",
                            width: 25,
                            height: 22,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Vouchers",
                                style: TextStyle(
                                  color: AppColors.stormyTeal,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                "99+",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.stormyTeal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 6),
                    Container(
                      height: 60,
                      width: 140,
                      padding: const EdgeInsets.symmetric(horizontal: 12),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "images/Coins_Icon.png",
                            width: 25,
                            height: 22,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FoodCoins",
                                style: TextStyle(
                                  color: AppColors.stormyTeal,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                "3.560",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.stormyTeal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foodCard(String title, String imagePath) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              height: 70,
              width: 70,
              margin: const EdgeInsets.only(left: 8, right: 8),
              decoration: BoxDecoration(
                color: AppColors.stormyTeal.withAlpha(255),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),

              child: Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  height: 70,
                  width: 70,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(19, 0, 0, 0),
      ),
      child: const Column(
        children: [
          Text(
            "Together, we turn surplus into opportunity - one meal at a time.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromARGB(255, 0, 96, 96),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Our app connects people with restaurants that offer flash sale deals on surplus food before closing time. By rescuing perfectly good meals, we help reduce food waste, support local businesses, and make quality food more affordable for everyone.",
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
