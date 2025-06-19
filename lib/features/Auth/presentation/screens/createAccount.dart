import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapstract/Data/repositories/auth/auth_repository.dart';
import 'package:zapstract/features/personalization/presentation/expertise_level_screen.dart';
import 'package:zapstract/features/personalization/presentation/goal_selection_screen.dart';
import 'package:zapstract/utils/components/primaryButton.dart';
import 'package:zapstract/utils/components/loginButtons.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';

class CreateAccountScreen extends StatefulWidget {
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the password visibility state when the screen loads
    // context.read<AuthBloc>().add(AuthInitial() as AuthEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 17.w),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message))
                );
              }
              if (state is Authenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Sign up Successful"))
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GoalSelectionScreen()),
                );
              }
            },
            builder: (context, state) {
              final bloc = context.read<AuthBloc>();

              // Show loading indicator
              if (state is AuthLoading) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                );
              }

              // For all other states (including AuthInitial, AuthPasswordVisibilityState, etc.)
              // we show the main UI
              return _buildMainContent(state, bloc);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(AuthState state, AuthBloc bloc) {
    // Get visibility states - provide defaults if not AuthPasswordVisibilityState
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    bool agreed = false;

    if (state is AuthPasswordVisibilityState) {
      obscurePassword = state.obscurePassword;
      obscureConfirmPassword = state.obscureConfirmPassword;
      agreed = state.agreed;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 14.h),
        IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        Center(
          child: Column(
            children: [
              Image.asset('assets/logo/logo1.png', height: 150.h),
              SizedBox(height: 8.h),
              Text(
                  "Create your account",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  "Join our community and experience a seamless way to read science news.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Google Sign Up Button
        InkWell(
            onTap: () {
              context.read<AuthBloc>().add(SignInWithGoogle());
            },
            child: buildSocialButton(
                text: "Login with Google",
                assetPath: "assets/icons/google.png"
            )
        ),

        SizedBox(height: 16.h),
        Divider(thickness: 1, color: Colors.grey.shade300),
        SizedBox(height: 8.h),

        // Form fields
        _buildTextField(
          controller: _usernameController,
          label: "Username",
          icon: Icons.person,
          placeholder: "john@43",
        ),
        _buildTextField(
          controller: _emailController,
          label: "Email",
          icon: Icons.email,
          placeholder: "xyz@gmail.com",
        ),
        _buildTextField(
          controller: _passwordController,
          label: "Password",
          icon: Icons.lock,
          placeholder: ".........",
          isPassword: true,
          obscureText: obscurePassword,
          toggle: () => bloc.add(TogglePasswordVisibility()),
        ),
        _buildTextField(
          controller: _confirmController,
          label: "Confirm Password",
          icon: Icons.lock,
          placeholder: ".........",
          isPassword: true,
          obscureText: obscureConfirmPassword,
          toggle: () => bloc.add(ToggleConfirmPasswordVisibility()),
        ),

        Row(
          children: [
            Checkbox(
              value: agreed,
              onChanged: (_) => bloc.add(ToggleAgreement()),
            ),
            Expanded(
              child: Text(
                "By proceeding, you agree to our Terms & Conditions.",
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),
        CustomGradientButton(
          text: state is AuthLoading ? "Creating..." : "Create Account",
          onPressed: () {
            final username = _usernameController.text.trim();
            final email = _emailController.text.trim();
            final password = _passwordController.text.trim();
            final confirm = _confirmController.text.trim();

            if (!agreed) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please agree to terms."))
              );
              return;
            }

            if (password != confirm) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Passwords do not match."))
              );
              return;
            }

            bloc.add(SignUpRequested(
                email: email,
                password: password,
                name: username,
                phone: ''
            ));
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp)),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(fontSize: 14.sp),
            prefixIcon: Icon(icon, size: 20.sp),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  size: 20.sp
              ),
              onPressed: toggle,
            )
                : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r)
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}