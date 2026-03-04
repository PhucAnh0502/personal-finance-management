import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/budget_bloc/budget_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/core/theme/app_theme.dart';
import 'package:pmf_app/presentation/features/budget/budget_screen.dart';
import 'package:pmf_app/presentation/features/transaction/transaction_list_screen.dart';
import 'package:pmf_app/presentation/features/profile/profile_screen.dart';
import 'package:pmf_app/presentation/features/assets/asset_screen.dart';
import 'package:pmf_app/core/services/bank_monitor_service.dart';
import 'package:pmf_app/presentation/features/group/group_list_screen.dart';
import 'package:pmf_app/presentation/features/notifications/notifications_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 2; // Mặc định là Budget tab

  final List<Widget> _screens = [
    const GroupListScreen(),
    const AssetScreen(),
    const BudgetScreen(),
    const TransactionListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    BankMonitorService.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            top: 8,
            right: 12,
            child: SafeArea(
              child: ValueListenableBuilder(
                valueListenable: BankMonitorService.notifications,
                builder: (context, notifications, _) {
                  final count =
                      notifications.where((item) => !item.isRead).length;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.getSurfaceColor(context),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.getTextPrimaryColor(context),
                            size: 22,
                          ),
                          if (count > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.expense,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppTheme.getSurfaceColor(context),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  count > 99 ? '99+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Builder(
      builder: (context) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 86,
              padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 22,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                child: CustomPaint(
                  painter: _BottomNavPainter(AppTheme.getSurfaceColor(context)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.groups_outlined,
                      activeIcon: Icons.groups,
                      label: 'Groups',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.trending_up_outlined,
                      activeIcon: Icons.trending_up,
                      label: 'Assets',
                    ),
                    const SizedBox(width: 72),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long,
                      label: 'History',
                    ),
                    _buildNavItem(
                      index: 4,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profile',
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -24,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.getSurfaceColor(context),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: () => _setTab(2),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.emeraldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryEmerald.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColors.primaryEmerald.withOpacity(0.2),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return Builder(
      builder: (context) {
        final isActive = _currentIndex == index;
        final color = isActive ? AppColors.primaryEmerald : AppTheme.getSubtitleStyle(context).color ?? AppColors.textSecondary;

        return GestureDetector(
          onTap: () => _setTab(index),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 58,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isActive ? activeIcon : icon, color: color, size: 21),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 2) {
      context.read<BudgetBloc>().add(FetchBudgetsEvent(DateTime.now()));
    }
  }
}

class _BottomNavPainter extends CustomPainter {
  final Color backgroundColor;

  _BottomNavPainter(this.backgroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final notchRadius = 40.0;
    final notchMargin = 8.0;

    // Start from top-left
    path.moveTo(0, 0);
    
    // Line to the start of the notch
    path.lineTo(centerX - notchRadius - notchMargin, 0);
    
    // Create smooth curve leading into the notch
    path.quadraticBezierTo(
      centerX - notchRadius - notchMargin / 2,
      0,
      centerX - notchRadius,
      notchMargin,
    );
    
    // Arc for the notch cutout
    path.arcToPoint(
      Offset(centerX + notchRadius, notchMargin),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    
    // Smooth curve out of the notch
    path.quadraticBezierTo(
      centerX + notchRadius + notchMargin / 2,
      0,
      centerX + notchRadius + notchMargin,
      0,
    );
    
    // Line to top-right
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BottomNavPainter oldDelegate) => oldDelegate.backgroundColor != backgroundColor;
}
