import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_1/colorPallette.dart';
import 'package:project_1/main.dart';
import 'package:project_1/providers/app_state_provider.dart';
import 'package:project_1/register_page.dart';
import 'package:project_1/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isConsumer = true;

  void _handleLogin() async {
    final result = await ApiService().loginUser(
      emailController.text,
      passwordController.text,
    );

    if (result['status'] == "success") {
      final userName = result['data']?['nama'] as String? ?? '';
      if (userName.isNotEmpty) {
        context.read<AppStateProvider>().userName = userName;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome Back!'),
          backgroundColor: AppColors.stormyTeal,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("images/FoodSaver_Orange_Main.png", height: 56),
                  const SizedBox(width: 8),
                  Text(
                    'Food Saver',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.stormyTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Login To Your Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Continue your journey, Save the earth!',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 20),

                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            alignment: isConsumer
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => isConsumer = true),
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Consumer',
                                      style: TextStyle(
                                        fontWeight: isConsumer
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => isConsumer = false),
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Merchant',
                                      style: TextStyle(
                                        fontWeight: !isConsumer
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      "Email",
                      "JonhDoe@gmail.com",
                      emailController,
                    ),

                    _buildTextField(
                      "Password",
                      "********",
                      passwordController,
                      isPassword: true,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.stormyTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Continue The Journey',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "く Back To Register",
                        style: TextStyle(
                          color: AppColors.tigerFlame,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
