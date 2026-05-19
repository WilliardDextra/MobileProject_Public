import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:project_1/register_page.dart';
import 'package:project_1/models/payment_history.dart';
import 'package:project_1/providers/app_state_provider.dart';
import 'package:project_1/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'colorPallette.dart';
import 'search.dart';
import 'cart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,

          canvasColor: Colors.white,
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),

        debugShowCheckedModeBanner: false,
        home: const RegisterPage(),
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
  void _onItemTapped(int index) {
    context.read<AppStateProvider>().selectedIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final selectedIndex = appState.selectedIndex;
    final userName = appState.userName;
    final cartProvider = context.watch<CartProvider>();

    final List<Widget> pages = [
      _buildStatusPage(cartProvider.history),
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

      body: IndexedStack(index: selectedIndex, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
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

  Widget _buildStatusPage(List<PaymentHistoryEntry> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'No payment history yet.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = history[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.restaurantName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(entry.date),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text('Service: ${entry.serviceType}'),
              const SizedBox(height: 4),
              Text('Payment: ${entry.paymentMethod}'),
              const SizedBox(height: 4),
              Text('Items: ${entry.itemCount}'),
              const SizedBox(height: 4),
              Text('Voucher: ${entry.voucher}'),
              const SizedBox(height: 4),
              Text('Coins used: Rp${entry.coinsUsed.toStringAsFixed(0)}'),
              const Divider(height: 20),
              Text(
                'Total: Rp${entry.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
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
                            "Welcome Back ${context.watch<AppStateProvider>().userName.isEmpty ? 'Guest' : context.watch<AppStateProvider>().userName}",
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
                                "20.000",
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
