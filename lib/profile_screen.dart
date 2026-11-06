import 'package:flutter/material.dart';

import 'habi_colors.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userName});

  final String userName;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String get _profileName {
    final saved = HabiSettingsData.account;
    final name = [
      saved['firstName'],
      saved['middleName'],
      saved['lastName'],
      saved['suffix'],
    ].where((part) => part != null && part.trim().isNotEmpty).join(' ');
    return name.isEmpty ? widget.userName : name;
  }

  List<String> get _skills {
    final saved = HabiSettingsData.profile['skills'] ?? '';
    if (saved.trim().isEmpty) {
      return const [
        'Communication',
        'Teamwork',
        'Microsoft Office',
        'Customer Service',
      ];
    }
    return saved
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: HabiColors.navyLight,
        ),
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  sliver: SliverList.list(
                    children: [
                      _profileCard(context),
                      const SizedBox(height: 14),
                      _skillsCard(context),
                      const SizedBox(height: 14),
                      _shortcutsCard(context),
                      const SizedBox(height: 14),
                      _growthCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavigation(context),
    );
  }

  Widget _header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 8, 16, 4),
    child: Row(
      children: [
        Image.asset('assets/habi_logo.png', width: 36, height: 36),
        const SizedBox(width: 9),
        const Text(
          'HABI',
          style: TextStyle(
            color: HabiColors.cream,
            fontFamily: 'serif',
            fontSize: 19,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => _openSettings(context),
          style: IconButton.styleFrom(
            backgroundColor: HabiColors.navyMid.withAlpha(220),
          ),
          icon: const Icon(Icons.settings_outlined, color: HabiColors.gold),
        ),
      ],
    ),
  );

  Widget _profileCard(BuildContext context) => _Panel(
    child: Column(
      children: [
        Row(
          children: [
            HabiProfileAvatar(
              size: 72,
              imageBytes: HabiSettingsData.profileImageBytes,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Job Seeker',
                    style: TextStyle(color: HabiColors.cream, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.verified, size: 15, color: HabiColors.gold),
                      SizedBox(width: 5),
                      Text(
                        'Profile 85% complete',
                        style: TextStyle(
                          color: HabiColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit profile',
              onPressed: () => _openAccountSettings(context),
              icon: const Icon(Icons.edit_outlined, color: HabiColors.gold),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const LinearProgressIndicator(
            value: .85,
            minHeight: 6,
            color: HabiColors.gold,
            backgroundColor: HabiColors.navyLight,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: HabiColors.navy.withAlpha(150),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, color: HabiColors.gold, size: 19),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Your next opportunity starts with a great profile.',
                  style: TextStyle(color: HabiColors.cream, fontSize: 12),
                ),
              ),
              Icon(Icons.chevron_right, color: HabiColors.gold),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _skillsCard(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Skills',
          action: 'Edit',
          onTap: () => _openEditProfile(context),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.map((skill) => _SkillChip(skill)).toList(),
        ),
        const SizedBox(height: 13),
        Divider(color: HabiColors.cream.withAlpha(35), height: 1),
        const SizedBox(height: 11),
        const Row(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              color: HabiColors.gold,
              size: 17,
            ),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                'Add skills to improve your job matches',
                style: TextStyle(color: HabiColors.tan, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _shortcutsCard(BuildContext context) => _Panel(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Column(
      children: [
        _ProfileLink(
          icon: Icons.description_outlined,
          title: 'My Applications',
          subtitle: 'Track your application progress',
          onTap: () => _showMessage(context, 'Applications are coming soon.'),
        ),
        _rule(),
        _ProfileLink(
          icon: Icons.bookmark_border,
          title: 'Saved Jobs',
          subtitle: 'Jobs you have bookmarked',
          onTap: () => _showMessage(context, 'Saved jobs are coming soon.'),
        ),
        _rule(),
        _ProfileLink(
          icon: Icons.article_outlined,
          title: 'Resume',
          subtitle: 'View or update your resume',
          onTap: () => _showMessage(context, 'Resume editing is coming soon.'),
        ),
      ],
    ),
  );

  Widget _growthCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        colors: [Color(0xFF183F53), Color(0xFF155344)],
      ),
      border: Border.all(color: HabiColors.gold.withAlpha(90)),
    ),
    child: const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keep growing!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your next opportunity is closer than you think.',
                style: TextStyle(color: HabiColors.cream, fontSize: 11),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Icon(Icons.spa_outlined, size: 32, color: HabiColors.gold),
      ],
    ),
  );

  Widget _bottomNavigation(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: HabiColors.navy,
      border: Border(top: BorderSide(color: HabiColors.cream.withAlpha(40))),
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 68,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () => Navigator.of(context).pop(),
            ),
            _NavItem(
              icon: Icons.work_outline,
              label: 'Jobs',
              onTap: () => _showMessage(context, 'Jobs are coming soon.'),
            ),
            _NavItem(
              icon: Icons.school_outlined,
              label: 'Training',
              onTap: () => _showMessage(context, 'Training is coming soon.'),
            ),
            const _NavItem(icon: Icons.person, label: 'Profile', active: true),
          ],
        ),
      ),
    ),
  );

  Widget _rule() => Divider(color: HabiColors.cream.withAlpha(35), height: 1);

  Future<void> _openSettings(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(userName: widget.userName),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openAccountSettings(BuildContext context) async {
    await Navigator.of(context)
        .push<void>(SettingsScreen.accountSettingsRoute(widget.userName));
    if (mounted) setState(() {});
  }

  Future<void> _openEditProfile(BuildContext context) async {
    await Navigator.of(context)
        .push<void>(SettingsScreen.editProfileRoute(widget.userName));
    if (mounted) setState(() {});
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: HabiColors.navyMid.withAlpha(245),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: HabiColors.cream.withAlpha(45)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(35),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      const Spacer(),
      if (action != null)
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                action!,
                style: const TextStyle(
                  color: HabiColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.chevron_right, size: 17, color: HabiColors.gold),
            ],
          ),
        ),
    ],
  );
}

class _SkillChip extends StatelessWidget {
  const _SkillChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: HabiColors.navyLight.withAlpha(190),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: HabiColors.gold.withAlpha(85)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: HabiColors.cream,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: HabiColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: HabiColors.tan, fontSize: 10),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: HabiColors.cream, size: 19),
        ],
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? HabiColors.gold : HabiColors.cream.withAlpha(190),
            size: 23,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? HabiColors.gold : HabiColors.cream.withAlpha(190),
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}