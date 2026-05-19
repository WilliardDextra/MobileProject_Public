import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:project_1/register_page.dart';
import 'package:project_1/models/payment_history.dart';
import 'package:project_1/providers/app_state_provider.dart';
import 'package:project_1/providers/cart_provider.dart';
import 'package:project_1/services/api_service.dart';
import 'package:project_1/account_page.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentHistory();
    });
  }

  Future<void> _loadPaymentHistory() async {
    final userId = context.read<AppStateProvider>().userId;
    if (userId == null) return;
    try {
      final history = await ApiService().fetchPaymentHistory(userId);
      context.read<CartProvider>().setHistory(history);
    } catch (e) {
      debugPrint('Failed to load payment history: $e');
    }
  }

  void _onItemTapped(int index) {
    context.read<AppStateProvider>().selectedIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final selectedIndex = appState.selectedIndex;
    final cartProvider = context.watch<CartProvider>();

    final List<Widget> pages = [
      _buildStatusPage(cartProvider.history),
      const SearchPage(),
      _buildLandingPage(),
      CartPage(),
      const AccountPage(),
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
                _buildDescriptionBox(context, _onItemTapped),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _userCard() {
    final coins = context.watch<AppStateProvider>().coins;
    final purchasedCount = context.watch<CartProvider>().history.fold<int>(
      0,
      (sum, e) => sum + e.itemCount,
    );
    return SlideInUp(
      duration: const Duration(milliseconds: 800),
      from: 200,
      child: GestureDetector(
        onTap: () => _onItemTapped(4),
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
                            SizedBox(height: 8),
                            Text(
                              "You Saved ${purchasedCount.toString()} Portion${purchasedCount == 1 ? '' : 's'}",
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
                                  "Coins:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.stormyTeal,
                                  ),
                                ),
                                Text(
                                  "$coins",
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

  int _selectedFeatureIndex = 0;

  Widget _buildDescriptionBox(
    BuildContext context,
    Function(int) onNavigateToPage,
  ) {
    final List<Map<String, dynamic>> features = [
      {
        'title': 'Affordable Pricing',
        'icon': Icons.gavel_rounded,
        'color': AppColors.tigerFlame,
        'desc':
            'Enjoy high-quality, delicious surplus meals from your favorite local restaurants at a fraction of the regular price before closing time.',
        'actionText': 'Start Exploring',
        'action': () => onNavigateToPage(1),
      },
      {
        'title': 'Gamified Rewards',
        'icon': Icons.monetization_on_rounded,
        'color': Colors.amber.shade700,
        'desc':
            'Earn FoodCoins with every purchase! Collect coins and use them as real currency to pay for your next sustainable dining experience.',
        'actionText': 'Check My Coins',
        'action': () => onNavigateToPage(4),
      },
      {
        'title': 'Flexible Logistics',
        'icon': Icons.local_shipping_rounded,
        'color': AppColors.stormyTeal,
        'desc':
            'Choose your convenience. Save food your way by scheduling a quick self-pickup at the store or sitting back with our fast delivery options.',
        'actionText': 'View Order Status',
        'action': () => onNavigateToPage(0),
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.stormyTeal, Color(0xFF004D4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.stormyTeal.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: AppColors.cream,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "FoodSaver".toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  "\"Together, we turn surplus into opportunity, one meal at a time.\"",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.cream,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "FoodSaver is a real-time mobile platform combating food waste in urban areas. We connect local restaurants with everyday consumers to redistribute high-quality surplus food before closing time.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.cream.withAlpha(200),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "Why Choose FoodSaver?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.stormyTeal,
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(features.length, (index) {
              final isSelected = _selectedFeatureIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    _selectedFeatureIndex = index;
                    (context as Element).markNeedsBuild();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cream : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.tigerFlame
                            : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.tigerFlame.withAlpha(40),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          features[index]['icon'] as IconData,
                          color: isSelected
                              ? AppColors.tigerFlame
                              : Colors.grey.shade400,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (features[index]['title'] as String).split(' ')[0],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.stormyTeal
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey<int>(_selectedFeatureIndex),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              (features[_selectedFeatureIndex]['color']
                                      as Color)
                                  .withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          features[_selectedFeatureIndex]['icon'] as IconData,
                          color:
                              features[_selectedFeatureIndex]['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        features[_selectedFeatureIndex]['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.stormyTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    features[_selectedFeatureIndex]['desc'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed:
                          features[_selectedFeatureIndex]['action']
                              as VoidCallback,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.stormyTeal,
                        side: const BorderSide(
                          color: AppColors.stormyTeal,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            features[_selectedFeatureIndex]['actionText']
                                as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
