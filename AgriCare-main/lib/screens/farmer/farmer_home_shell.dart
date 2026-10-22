import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'crop_scan_tab.dart';
import 'dashboard_tab.dart';
import 'jobs_tab.dart';
import 'profile_tab.dart';

class FarmerHomeShell extends StatefulWidget {
  const FarmerHomeShell({super.key});

  @override
  State<FarmerHomeShell> createState() => _FarmerHomeShellState();
}

class _FarmerHomeShellState extends State<FarmerHomeShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'AgriCare',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          FarmerDashboardTab(onNavigate: _goTo),
          const CropScanTab(),
          const FarmerJobsTab(),
          const FarmerProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        indicatorColor: const Color(0xFFDCFCE7),
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: primaryGreen),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.center_focus_weak_rounded),
            selectedIcon: Icon(Icons.center_focus_strong_rounded, color: primaryGreen),
            label: 'Crop Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.engineering_outlined),
            selectedIcon: Icon(Icons.engineering_rounded, color: primaryGreen),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: primaryGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
