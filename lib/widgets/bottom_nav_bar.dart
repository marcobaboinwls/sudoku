import 'package:flutter/material.dart';
import '../screens/daily_challenges_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home,
            label: 'Main',
            isSelected: currentIndex == 0,
            onTap: () {
              if (currentIndex != 0) {
                Navigator.of(context).pop();
              }
            },
          ),
          _NavItem(
            icon: Icons.calendar_today,
            label: 'Daily Challenges',
            isSelected: currentIndex == 1,
            onTap: () {
              if (currentIndex != 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DailyChallengesScreen(),
                  ),
                );
              }
            },
          ),
          _NavItem(
            icon: Icons.person,
            label: 'Me',
            isSelected: currentIndex == 2,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
