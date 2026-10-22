import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'available_jobs_tab.dart';
import 'my_jobs_tab.dart';
import 'profile_tab.dart';

class WorkerHomeShell extends StatefulWidget {
  const WorkerHomeShell({super.key});

  @override
  State<WorkerHomeShell> createState() => _WorkerHomeShellState();
}

class _WorkerHomeShellState extends State<WorkerHomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('AgriCare Worker', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.3)),
          ],
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          AvailableJobsTab(),
          WorkerMyJobsTab(),
          WorkerProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: const Color(0xFFDCFCE7),
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded, color: primaryGreen),
            label: 'Available',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded, color: primaryGreen),
            label: 'My Jobs',
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
