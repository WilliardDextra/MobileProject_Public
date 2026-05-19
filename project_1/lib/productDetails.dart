import 'package:flutter/material.dart';
import 'package:project_1/payment.dart';
import 'package:provider/provider.dart';
import 'package:project_1/colorPallette.dart';
import 'package:project_1/models/bakery_model.dart';
import 'package:project_1/models/menu_model.dart';
import 'package:project_1/providers/cart_provider.dart';
import 'package:project_1/services/api_service.dart';

class DetailPage extends StatefulWidget {
  final Bakery productDetail;

  const DetailPage({super.key, required this.productDetail});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<List<Menu>> futureMenus;
  void initState() {
    super.initState();

    futureMenus = ApiService().fetchMenus(widget.productDetail.id);
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final rawClosingTime = widget.productDetail.closing_time;
    final closingTime = rawClosingTime.length >= 5
        ? rawClosingTime.substring(0, 5)
        : rawClosingTime;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(150, 0, 96, 96),
                      ),
                      child: ClipRRect(
                        child: Image.asset(
                          widget.productDetail.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _createVoucherBox(
                              "Discount 1",
                              "Discount Description Goes Here",
                            ),
                            _createVoucherBox(
                              "Discount 2",
                              "Discount Description Goes Here",
                            ),
                            _createVoucherBox(
                              "Discount 3",
                              "Discount Description Goes Here",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Our Menus",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    FutureBuilder<List<Menu>>(
                      future: futureMenus,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("No menus available."),
                          );
                        }

                        return Column(
                          children: snapshot.data!.map((menu) {
                            return MenuCard(
                              menu: menu,
                              bakery: widget.productDetail,
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 140),
                  ],
                ),
                Positioned(
                  top: 140,
                  child: Container(
                    width: 340,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 2),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15,
                          color: const Color.fromARGB(225, 0, 0, 0),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        SizedBox(height: 6),
                        Text(
                          widget.productDetail.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "⭐ ${widget.productDetail.rating}",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text("●", style: TextStyle(color: Colors.grey)),
                            SizedBox(width: 4),
                            Text(
                              "Avalaible: ${widget.productDetail.stock}",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: const Color.fromARGB(255, 119, 119, 119),
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text("●", style: TextStyle(color: Colors.grey)),
                            SizedBox(width: 4),
                            Text(
                              "Close - $closingTime",
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color.fromARGB(255, 119, 119, 119),
                              ),
                            ),
                          ],
                        ),

                        const Divider(
                          color: Color.fromARGB(255, 160, 160, 160),
                          thickness: 1.5,
                          indent: 20,
                          endIndent: 20,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${widget.productDetail.distance} Km",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "●",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "${widget.productDetail.duration} min",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(60),
                                spreadRadius: 3,
                                blurRadius: 3,
                                offset: const Offset(1.5, 2.5),
                              ),
                            ],
                          ),

                          child: Row(
                            children: [
                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(2, (index) {
                                  final labels = ["Delivery", "Pick Up"];
                                  bool isActive = _selectedIndex == index;

                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedIndex = index),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 17.3,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.stormyTeal
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        labels[index],
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              if (cartProvider.isEmpty ||
                  cartProvider.bakeryId != widget.productDetail.id) {
                return const SizedBox.shrink();
              }
              return Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          serviceType: _selectedIndex == 0
                              ? ServiceType.delivery
                              : ServiceType.pickUp,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.stormyTeal,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(100),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${cartProvider.totalItems} item',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: Rp${cartProvider.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Order',
                            style: TextStyle(
                              color: AppColors.stormyTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _createVoucherBox(String Discount_Title, String Discount_Description) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.only(top: 84, left: 8, right: 8),
        height: 60,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Colors.white,
          border: Border.all(width: 1, color: Colors.grey),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(200, 0, 0, 0).withAlpha(100),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Image.asset("images/DiscountIcon.png", height: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Discount_Title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    softWrap: true,
                  ),
                  Text(
                    Discount_Description,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    ],
  );
}

class MenuCard extends StatefulWidget {
  final Menu menu;
  final Bakery bakery;

  const MenuCard({super.key, required this.menu, required this.bakery});

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = context.read<CartProvider>();
      final existing = cartProvider.items[widget.menu.id];
      if (existing != null) {
        setState(() {
          quantity = existing.quantity;
        });
      }
    });
  }

  void _addToCart() {
    final cartProvider = context.read<CartProvider>();

    if (widget.menu.fStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This item is sold out'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (cartProvider.bakeryId != null &&
        cartProvider.bakeryId != widget.bakery.id) {
      _confirmReplaceOrder(cartProvider, 1);
      return;
    }

    cartProvider.addItem(menu: widget.menu, bakery: widget.bakery, quantity: 1);
    setState(() {
      quantity = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 110,
          left: 70,
          right: 70,
        ),

        content: Container(
          height: 20,
          width: 24,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
          child: Center(
            child: Text(
              'New Item Added',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(200, 255, 91, 31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  void _updateCartQuantity(int newQuantity) {
    final cartProvider = context.read<CartProvider>();
    if (newQuantity <= 0) {
      cartProvider.removeItem(widget.menu.id);
      setState(() {
        quantity = 0;
      });
      return;
    }

    cartProvider.updateQuantity(widget.menu.id, newQuantity);
    setState(() {
      quantity = newQuantity;
    });
  }

  void _confirmReplaceOrder(CartProvider cartProvider, int selectedQuantity) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Order'),
          content: const Text(
            'Are Your Sure To Change Order To This Restaurant?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                cartProvider.addItem(
                  menu: widget.menu,
                  bakery: widget.bakery,
                  quantity: selectedQuantity,
                  replaceExisting: true,
                );
                setState(() {
                  quantity = selectedQuantity;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Order Updated')));
              },
              child: const Text('Continued'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Column(
            children: [
              Divider(
                color: Color.fromARGB(255, 131, 131, 131),
                thickness: 1.5,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(height: 6),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.menu.fName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.menu.fRating}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${widget.menu.fSold}+)",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.menu.fDescription,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Rp${widget.menu.fPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(width: 2, color: Colors.black),
                          image: DecorationImage(
                            image: AssetImage(widget.menu.fImage),
                            fit: BoxFit.cover,
                            colorFilter: widget.menu.fStock <= 0
                                ? ColorFilter.mode(
                                    const Color.fromARGB(
                                      255,
                                      163,
                                      163,
                                      163,
                                    ).withAlpha(150),
                                    BlendMode.lighten,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -15,
                        child: Container(
                          width: 70,
                          height: 32,
                          decoration: BoxDecoration(
                            color: widget.menu.fStock <= 0
                                ? Colors.grey[300]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              width: 2,
                              color: widget.menu.fStock <= 0
                                  ? const Color.fromARGB(255, 193, 193, 193)
                                  : AppColors.stormyTeal,
                            ),
                          ),

                          child: widget.menu.fStock <= 0
                              ? Center(
                                  child: Text(
                                    "Sold Out",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : (quantity == 0
                                    ? GestureDetector(
                                        onTap: _addToCart,
                                        child: Center(
                                          child: Text(
                                            "Add",
                                            style: TextStyle(
                                              color: AppColors.stormyTeal,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _updateCartQuantity(
                                              quantity - 1,
                                            ),
                                            child: Text(
                                              "-",
                                              style: TextStyle(
                                                color: AppColors.stormyTeal,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "$quantity",
                                            style: TextStyle(
                                              color: AppColors.stormyTeal,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _updateCartQuantity(
                                              quantity + 1,
                                            ),
                                            child: Text(
                                              "+",
                                              style: TextStyle(
                                                color: AppColors.stormyTeal,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Stock: ${widget.menu.fStock}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.menu.fStock <= 0 ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
