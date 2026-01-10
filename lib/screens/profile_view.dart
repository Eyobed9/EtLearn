import 'package:flutter/material.dart';
import 'package:et_learn/authentication/auth.dart';
import 'package:et_learn/authentication/login_page.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Avatar and basic info from authenticated user
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              user?.photoURL != null
                  ? Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(user!.photoURL!),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: const Color(0xFF167F71),
                          width: 4,
                        ),
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                        border: Border.all(
                          color: const Color(0xFF167F71),
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (user?.displayName != null &&
                                  user!.displayName!.isNotEmpty)
                              ? user.displayName![0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF167F71), width: 3),
                ),
                child: const Icon(Icons.edit, size: 18),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            user?.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
              color: Color(0xFF202244),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            user?.email ?? 'No email',
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w700,
              color: Color(0xFF545454),
            ),
          ),

          const SizedBox(height: 24),

          // White Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                profileItem(Icons.person, 'Edit Profile'),
                profileItem(Icons.credit_card, 'Payment Option'),
                profileItem(Icons.notifications, 'Notifications'),
                profileItem(Icons.security, 'Security'),

                profileItem(
                  Icons.language,
                  'Language',
                  trailing: const Text(
                    'English (US)',
                    style: TextStyle(
                      color: Color(0xFF0961F5),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                profileItem(Icons.dark_mode, 'Dark Mode'),
                profileItem(Icons.description, 'Terms & Conditions'),
                profileItem(Icons.help_center, 'Help Center'),
                profileItem(Icons.group, 'Invite Friends'),

                profileItem(
                  Icons.logout,
                  'Logout',
                  color: Colors.red,
                  onTap: () async {
                    await Auth().signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget profileItem(
    IconData icon,
    String title, {
    Widget? trailing,
    Color color = const Color(0xFF202244),
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Mulish',
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
