import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:zapstract/features/Auth/bloc/auth_bloc.dart';
import 'package:zapstract/features/Auth/presentation/screens/login.dart';
import 'package:zapstract/features/homeScreen/home_screen.dart';
import 'package:zapstract/features/savedArticles/savedPapersScreen.dart';
import 'package:zapstract/features/search/presentation/search_screen.dart';

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
    else if(index==0){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen()),
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
                        (route) => false,
                  );
                }
              },
              builder: (context, authState) {
                return const SizedBox();
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
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(context),
                            _buildProfileInfo(state),
                            _buildStats(state),
                            _buildSavedArticlesButton(), // Simple button
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
                          Text(
                            state.message,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ProfileBloc>().add(LoadProfile());
                            },
                            child: Text(
                              'Retry',
                              style: TextStyle(fontSize: 14.sp),
                            ),
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
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Researcher Profile',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 24.sp,
            ),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(ProfileLoaded state) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: [
          // Avatar on the left
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(
                  radius: 50.r,
                  backgroundColor: const Color(0xFF6750A4),
                  child: const CircularProgressIndicator(color: Colors.white),
                );
              }

              final prefs = snapshot.data!;
              final imageUrl = prefs.getString('image') ?? '';
              final name = prefs.getString('name') ?? 'User';
              final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

              if (imageUrl.isNotEmpty) {
                return CircleAvatar(
                  radius: 50.r,
                  backgroundImage: NetworkImage(imageUrl),
                );
              } else {
                return CircleAvatar(
                  radius: 50.r,
                  backgroundColor: const Color(0xFF6750A4),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 40.sp,
                      color: Colors.white,
                    ),
                  ),
                );
              }
            },
          ),
          SizedBox(width: 16.w),
          // Name, occupation, and address on the right in a column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.profile.name,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  state.profile.occupation,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  state.profile.subject,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14.sp,
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

  Widget _buildStats(ProfileLoaded state) {
    final selectedSubject = state.profile.subject;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your Research Focus',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          Icon(
            _getIconForSubject(selectedSubject),
            size: 50.sp,
            color: Colors.deepPurple,
          ),
          SizedBox(height: 12.h),
          Text(
            selectedSubject,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Simple Saved Articles Button (same style as Preferences)
  Widget _buildSavedArticlesButton() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to Saved Articles page
          print("Navigate to Saved Articles");
          // Navigator.push(context, MaterialPageRoute(builder: (context) => SavedArticlesPage()));
        },
        child: Row(
          children: [
            Icon(
              Icons.bookmark_outlined,
              size: 24.sp,
              color: const Color(0xFF6750A4),
            ),
            SizedBox(width: 16.w),
            InkWell(
              onTap: (){
                print("Navigate to Saved Articles");
                Navigator.push(context, MaterialPageRoute(builder: (context) => SavedPapersScreen()));
              },
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Articles',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'View your bookmarked papers',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 24.sp,
            ),
          ],
        ),
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

  Widget _buildPreferences(BuildContext context, ProfileLoaded state) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
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
          Divider(height: 32.h),
          _buildPreferenceItem(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: state.profile.language,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Select Language',
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          'English',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        onTap: () {
                          context.read<ProfileBloc>().add(
                            const UpdateLanguage('English'),
                          );
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Spanish',
                          style: TextStyle(fontSize: 16.sp),
                        ),
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
          Divider(height: 32.h),
          _buildPreferenceItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'FAQ, Contact us',
            onTap: () {
              // Handle help and support
            },
          ),
          Divider(height: 32.h),
          _buildPreferenceItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out from the app',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Logout',
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  content: Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(LogoutRequested());
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(fontSize: 14.sp),
                      ),
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
            size: 24.sp,
            color: const Color(0xFF6750A4),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}
