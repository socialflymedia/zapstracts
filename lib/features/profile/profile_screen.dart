import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:zapstract/features/Auth/bloc/auth_bloc.dart';
import 'package:zapstract/features/Auth/presentation/screens/createAccount.dart';
import 'package:zapstract/features/Auth/presentation/screens/login.dart';
import 'package:zapstract/features/homeScreen/home_screen.dart';

import '../../utils/components/navbar/customnavbar.dart';
import '../Auth/bloc/auth_event.dart';
import '../Auth/bloc/auth_state.dart';
import 'bloc/profile_bloc.dart';
import 'bloc/profile_event.dart';
import 'bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    // Trigger profile loading when the screen initializes
    context.read<ProfileBloc>().add(LoadProfile());
  }
  int _selectedIndex = 2;
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
   else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [

            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, authState) {
                if (authState is Unauthenticated) {
                  print("User is not authenticated");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false, // This removes ALL previous routes from the stack
                  );
                }

              },
              builder: (context, authState) {
                return const SizedBox(); // or your UI
              },
            ),

            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProfileLoaded) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            _buildHeader(context),
                            _buildProfileInfo(state),
                             _buildStats(state),

                            _buildPreferences(context, state),
                          ],
                        ),
                      ),
                    );
                  } else if (state is ProfileError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ProfileBloc>().add(LoadProfile());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            CustomNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onNavItemTapped,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Researcher Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
    );
  }
  Future<String?> _getProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('image');
  }

  Widget _buildProfileInfo(ProfileLoaded state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),

      ),

      child: Row(
        children: [
          // Avatar on the left
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF6750A4),
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final prefs = snapshot.data!;
              final imageUrl = prefs.getString('image') ?? '';
              final name = prefs.getString('name') ?? 'User';
              final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

              if (imageUrl.isNotEmpty) {
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(imageUrl),
                );
              } else {
                return CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF6750A4),
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                );
              }
            },
          ),


          const SizedBox(width: 16), // Space between the avatar and text

          // Name, occupation, and address on the right in a column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.profile.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.profile.occupation,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ' ${state.profile.subject}',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6750A4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(ProfileLoaded state) {
    // Only one selected subject exists
    final selectedSubject = state.profile.subject;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Your Research Focus',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            _getIconForSubject(selectedSubject),
            size: 50,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 12),
          Text(
            selectedSubject,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          //_buildStatBar(selectedSubject.key, selectedSubject.value),
        ],
      ),
    );
  }

  IconData _getIconForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'physics':
        return Icons.science;
      case 'chemistry':
        return Icons.bubble_chart;
      case 'biology':
        return Icons.biotech;
      default:
        return Icons.school;
    }
  }


  Widget _buildStatBar(String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF6750A4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferences(BuildContext context, ProfileLoaded state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPreferenceItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: state.profile.notificationsEnabled ? 'Enabled' : 'Disabled',
            onTap: () {
              context.read<ProfileBloc>().add(
                UpdateNotifications(!state.profile.notificationsEnabled),
              );
            },
          ),
          const Divider(height: 32),
          _buildPreferenceItem(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: state.profile.language,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Language'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('English'),
                        onTap: () {
                          context.read<ProfileBloc>().add(
                            const UpdateLanguage('English'),
                          );
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Spanish'),
                        onTap: () {
                          context.read<ProfileBloc>().add(
                            const UpdateLanguage('Spanish'),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 32),
          _buildPreferenceItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'FAQ, Contact us',
            onTap: () {
              // Handle help and support
            },
          ),
          const Divider(height: 32),
          _buildPreferenceItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out from the app',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Clear session/token if needed
                        context.read<AuthBloc>().add(LogoutRequested());
                        // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF6750A4),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}