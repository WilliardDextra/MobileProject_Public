import 'package:flutter/material.dart';
import 'package:project_1/colorPallette.dart';
import 'package:project_1/services/api_service.dart';
import 'package:project_1/models/menu_model.dart';
import 'package:provider/provider.dart';
import 'package:project_1/providers/app_state_provider.dart';

class MerchantMenuPage extends StatefulWidget {
  const MerchantMenuPage({super.key});

  @override
  State<MerchantMenuPage> createState() => _MerchantMenuPageState();
}

class _MerchantMenuPageState extends State<MerchantMenuPage> {
  late Future<List<Menu>> _menusFuture;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  void _loadMenus() {
    final userId = context.read<AppStateProvider>().userId ?? 0;
    _menusFuture = ApiService().fetchMerchantMenus(userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadMenus();
    });
  }

  Future<void> _showMenuDialog({Menu? menu}) async {
    final isEdit = menu != null;
    final nameC = TextEditingController(text: menu?.fName ?? '');
    final descC = TextEditingController(text: menu?.fDescription ?? '');
    final imageC = TextEditingController(text: menu?.fImage ?? '');
    final priceC = TextEditingController(
      text: menu != null ? menu.fPrice.toString() : '',
    );
    final stockC = TextEditingController(
      text: menu != null ? menu.fStock.toString() : '',
    );
    bool isActive = (menu?.isActive ?? 1) == 1;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Menu' : 'Add Menu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descC,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: imageC,
                decoration: const InputDecoration(
                  labelText: 'Image path or URL',
                ),
              ),
              TextField(
                controller: priceC,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockC,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                value: isActive,
                title: const Text('Active'),
                onChanged: (v) => isActive = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameC.text.trim();
              final desc = descC.text.trim();
              final img = imageC.text.trim();
              final price = double.tryParse(priceC.text) ?? 0.0;
              final stock = int.tryParse(stockC.text) ?? 0;
              final userId = context.read<AppStateProvider>().userId ?? 0;
              final bakeryId = 1;

              if (name.isEmpty) return;

              if (isEdit) {
                await ApiService().updateMerchantMenu(
                  menuId: menu.id,
                  userId: userId,
                  name: name,
                  description: desc,
                  image: img,
                  price: price,
                  stock: stock,
                  isActive: isActive ? 1 : 0,
                );
              } else {
                await ApiService().createMerchantMenu(
                  userId: userId,
                  bakeryId: bakeryId,
                  name: name,
                  image: img.isEmpty ? null : img,
                  description: desc.isEmpty ? null : desc,
                  price: price,
                  stock: stock,
                );
              }

              Navigator.pop(ctx, true);
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );

    if (result == true) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Menu>>(
        future: _menusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.stormyTeal),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }

          final menus = snapshot.data ?? [];
          if (menus.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fastfood_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No menus yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.stormyTeal,
            backgroundColor: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: menus.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final m = menus[index];
                final bool isMenuProductActive = (m.isActive ?? 1) == 1;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(120),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: AppColors.cream,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 15,
                                      color: const Color.fromARGB(225, 0, 0, 0),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: m.fImage.isEmpty
                                      ? const Icon(
                                          Icons.fastfood,
                                          color: AppColors.stormyTeal,
                                          size: 28,
                                        )
                                      : Image.asset(
                                          m.fImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.fastfood,
                                                color: AppColors.stormyTeal,
                                              ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.fName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Rp${m.fPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.stormyTeal,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                  if (m.fDescription.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      m.fDescription,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.tigerFlame.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Stock: ${m.fStock}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.tigerFlame,
                                ),
                              ),
                            ),

                            SizedBox(width: 96),

                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.stormyTeal.withAlpha(50),
                                ),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.stormyTeal,
                                ),
                                onPressed: () async {
                                  await _showMenuDialog(menu: m);
                                  await _refresh();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade100),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final userId =
                                      context.read<AppStateProvider>().userId ??
                                      0;
                                  await ApiService().deleteMerchantMenu(
                                    menuId: m.id,
                                    userId: userId,
                                  );
                                  await _refresh();
                                },
                              ),
                            ),

                            Transform.scale(
                              scale: 0.85,
                              child: Switch(
                                value: isMenuProductActive,
                                activeColor: Colors.white,
                                activeTrackColor: AppColors.stormyTeal,
                                inactiveThumbColor: Colors.grey.shade400,
                                inactiveTrackColor: Colors.grey.shade200,
                                onChanged: (val) async {
                                  final userId =
                                      context.read<AppStateProvider>().userId ??
                                      0;
                                  await ApiService().toggleMerchantMenu(
                                    menuId: m.id,
                                    userId: userId,
                                    isActive: val ? 1 : 0,
                                  );
                                  await _refresh();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final userId = context.read<AppStateProvider>().userId ?? 0;
          final bakeryId = 1;

          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (ctx) {
              final nameC = TextEditingController();
              final priceC = TextEditingController();
              final stockC = TextEditingController();
              final imageC = TextEditingController();

              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.add_box_rounded,
                          color: AppColors.stormyTeal,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add New Menu',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.stormyTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: nameC,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Menu Name',
                        prefixIcon: const Icon(
                          Icons.fastfood_outlined,
                          size: 20,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: AppColors.stormyTeal,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.stormyTeal,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: priceC,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price (Rp)',
                        prefixIcon: const Icon(
                          Icons.monetization_on_outlined,
                          size: 20,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: AppColors.stormyTeal,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.stormyTeal,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: stockC,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Available Stock',
                        prefixIcon: const Icon(
                          Icons.inventory_2_outlined,
                          size: 20,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: AppColors.stormyTeal,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.stormyTeal,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 14),
                    TextField(
                      controller: nameC,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Menu Image',
                        prefixIcon: const Icon(Icons.image, size: 20),
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: AppColors.stormyTeal,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.stormyTeal,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                // Validasi sederhana agar tidak mengirim input kosong
                                if (nameC.text.trim().isEmpty) return;

                                Navigator.pop(ctx, {
                                  'name': nameC.text.trim(),
                                  'price': double.tryParse(priceC.text) ?? 0.0,
                                  'stock': int.tryParse(stockC.text) ?? 0,
                                  'image': imageC,
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.stormyTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Create',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );

          if (result != null) {
            await ApiService().createMerchantMenu(
              userId: userId,
              bakeryId: bakeryId,
              name: result['name'],
              price: result['price'],
              stock: result['stock'],
            );
            await _refresh();
          }
        },
        backgroundColor: AppColors.stormyTeal,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
