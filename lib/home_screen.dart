import 'package:flutter/material.dart';

import 'account_store.dart';
import 'habi_colors.dart';
import 'habi_nav_bar.dart';
import 'job_card.dart';
import 'job_store.dart';
import 'jobs_screen.dart';
import 'login_screen.dart';
import 'my_applications_screen.dart';
import 'my_jobs_screen.dart';
import 'notification_store.dart';
import 'notifications_screen.dart';
import 'profile_setup_screen.dart';
import 'support_screen.dart';

/// Home / Dashboard.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userName});

  final String userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // TODO (backend): replace with the signed-in user.
    JobStore.instance.currentUser = widget.userName;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName =>
      AccountStore.instance.byDisplayName(widget.userName)?.firstName ??
      widget.userName;

  String get _initial =>
      _firstName.isEmpty ? 'H' : _firstName[0].toUpperCase();

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: HabiColors.navyLight,
        ),
      );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _openProfile() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(userName: widget.userName),
      ),
    );
    if (saved == true && mounted) _message('Profile saved.');
  }

  void _logOut() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabiColors.navy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/habi_bg.jpg', fit: BoxFit.cover),
          Container(color: HabiColors.navy.withAlpha(225)),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildBanner(),
                  const SizedBox(height: 22),
                  _buildShortcuts(),
                  const SizedBox(height: 24),
                  _buildProfilePrompt(),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recommended for You',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _push(JobsScreen(userName: widget.userName)),
                        style: TextButton.styleFrom(
                          foregroundColor: HabiColors.gold,
                        ),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRecommended(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HabiNavBar(
        userName: widget.userName,
        active: NavTab.home,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting,',
                style: TextStyle(
                  fontSize: 18,
                  color: HabiColors.cream.withAlpha(230),
                ),
              ),
              Text(
                '$_firstName!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Discover opportunities that fit you.',
                style: TextStyle(
                  fontSize: 14,
                  color: HabiColors.cream.withAlpha(210),
                ),
              ),
            ],
          ),
        ),
        ListenableBuilder(
          listenable: NotificationStore.instance,
          builder: (context, _) {
            final unread =
                NotificationStore.instance.unreadCount(widget.userName);
            return IconButton(
              tooltip: 'Notifications',
              onPressed: () =>
                  _push(NotificationsScreen(userName: widget.userName)),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 28,
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: HabiColors.gold,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: HabiColors.navy,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          tooltip: 'Account',
          color: HabiColors.navyMid,
          onSelected: (value) {
            if (value == 'profile') {
              _openProfile();
            } else {
              _logOut();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'profile',
              child: Text('My Profile', style: TextStyle(color: Colors.white)),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Text('Log out', style: TextStyle(color: Colors.white)),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: HabiColors.gold,
              child: Text(
                _initial,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: HabiColors.navy,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: HabiColors.navy.withAlpha(200),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HabiColors.cream.withAlpha(70)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        cursorColor: HabiColors.gold,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _message('Search is coming soon.'),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search jobs, skills, or companies...',
          hintStyle: TextStyle(
            color: HabiColors.cream.withAlpha(150),
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: IconButton(
            icon: Icon(Icons.tune, color: HabiColors.cream.withAlpha(200)),
            onPressed: () => _message('Filters are coming soon.'),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HabiColors.gold, width: 3),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
        decoration: BoxDecoration(
          color: HabiColors.navyMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HabiColors.gold.withAlpha(110)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your skills are in demand',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Administrative roles near you',
                    style: TextStyle(
                      fontSize: 15,
                      color: HabiColors.cream.withAlpha(220),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () =>
                        _push(JobsScreen(userName: widget.userName)),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE2BB6C),
                      foregroundColor: HabiColors.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Explore Jobs',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.shopping_basket_outlined,
              size: 84,
              color: HabiColors.gold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortcut(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: HabiColors.navy.withAlpha(200),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: HabiColors.cream.withAlpha(70)),
              ),
              child: Icon(icon, color: HabiColors.gold, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 12, color: HabiColors.cream),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcuts() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shortcut(
          Icons.work_outline,
          'Jobs',
          () => _push(MyJobsScreen(userName: widget.userName)),
        ),
        _shortcut(
          Icons.support_agent,
          'Support',
          () => _push(SupportScreen(userName: widget.userName)),
        ),
        _shortcut(
          Icons.description_outlined,
          'My Applications',
          () => _push(MyApplicationsScreen(userName: widget.userName)),
        ),
      ],
    );
  }

  Widget _buildProfilePrompt() {
    return ListenableBuilder(
      listenable: AccountStore.instance,
      builder: (context, _) {
        final account = AccountStore.instance.byDisplayName(widget.userName);
        if (account == null || account.profileDone) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HabiColors.navy.withAlpha(200),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HabiColors.gold.withAlpha(140)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: HabiColors.gold,
                  size: 30,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complete your profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Add your skills, work preferences and accessibility '
                        'needs.',
                        style: TextStyle(
                          fontSize: 13,
                          color: HabiColors.cream.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _openProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE2BB6C),
                    foregroundColor: HabiColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommended() {
    return ListenableBuilder(
      listenable: JobStore.instance,
      builder: (context, _) {
        final jobs = JobStore.instance.jobs.take(5).toList();
        if (jobs.isEmpty) return _buildEmpty();
        return Column(
          children: [
            for (final job in jobs)
              JobCard(job: job, userName: widget.userName),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        color: HabiColors.navy.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HabiColors.cream.withAlpha(60)),
      ),
      child: Column(
        children: [
          const Icon(Icons.work_outline, color: HabiColors.gold, size: 34),
          const SizedBox(height: 10),
          const Text(
            'No jobs posted yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jobs that people post will show up here. Tap the round HABI button below to post one.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: HabiColors.cream.withAlpha(190),
            ),
          ),
        ],
      ),
    );
  }
}