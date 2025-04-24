import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zapstract/features/Auth/bloc/auth_bloc.dart';
import 'package:zapstract/features/Auth/bloc/auth_event.dart';
import 'package:zapstract/features/Auth/bloc/auth_state.dart';
import '../../../../utils/components/primaryButton.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 24.sp),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo/logo1.png', height: 100.h),
                      SizedBox(height: 12.h),
                      Text(
                        "Let’s get you signed in",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Join our community and experience a seamless way to read science news",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                /// Email Field
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  placeholder: "OneNews@gmail.com",
                  icon: Icons.email,
                ),

                /// Password Field
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    bool obscure = true;
                    if (state is AuthPasswordVisibilityState) {
                      obscure = state.obscurePassword;
                    }
                    return _buildTextField(
                      controller: _passwordController,
                      label: "Password",
                      placeholder: "..........",
                      icon: Icons.lock,
                      isPassword: true,
                      obscureText: obscure,
                      toggle: () => context.read<AuthBloc>().add(TogglePasswordVisibility()),
                    );
                  },
                ),

                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: true, onChanged: (_) {}),
                        Text("Remember Me", style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                    Text("Forgot password?", style: TextStyle(fontSize: 12.sp)),
                  ],
                ),

                SizedBox(height: 20.h),

                /// Login Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return CustomGradientButton(
                      text: state is AuthLoading ? "Logging in..." : "Login",
                      onPressed: () {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please fill all fields")),
                          );
                          return;
                        }

                        context.read<AuthBloc>().add(LoginRequested(email: email, password: password));
                      },
                    );
                  },
                ),

                SizedBox(height: 20.h),

                /// OR Divider
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text("OR", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                SizedBox(height: 20.h),

                /// Apple Button
                _buildSocialButton(text: "Login with Apple", icon: Icons.apple),

                SizedBox(height: 12.h),

                /// Google Button
                _buildSocialButton(text: "Login with Google", assetPath: "assets/icons/google.png"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String placeholder,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: toggle,
            )
                : null,
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSocialButton({required String text, IconData? icon, String? assetPath}) {
    return Container(
      height: 50.h,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 20.sp),
          if (assetPath != null) Image.asset(assetPath, height: 20.h, width: 20.w),
          SizedBox(width: 8.w),
          Text(text, style: TextStyle(fontSize: 14.sp)),
        ],
      ),
    );
  }
}
