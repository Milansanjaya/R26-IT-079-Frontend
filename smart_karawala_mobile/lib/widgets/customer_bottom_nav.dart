import 'package:flutter/material.dart';

class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0A5B8E).withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                unselectedIcon: Icons.home_outlined,
                label: "Home",
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.grid_view_rounded,
                unselectedIcon: Icons.grid_view_outlined,
                label: "Categories",
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.shopping_bag_rounded,
                unselectedIcon: Icons.shopping_bag_outlined,
                label: "Orders",
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_rounded,
                unselectedIcon: Icons.person_outline_rounded,
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData unselectedIcon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xff0A5B8E).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? icon : unselectedIcon,
                color: isSelected
                    ? const Color(0xff0A5B8E)
                    : const Color(0xff7E99B3),
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xff0A5B8E)
                    : const Color(0xff7E99B3),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
