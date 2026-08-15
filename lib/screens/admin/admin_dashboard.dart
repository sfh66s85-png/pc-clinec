import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth_screen.dart';
import '../../core/widgets/glass_container.dart';
import 'medicine_management_screen.dart';
import 'order_management_screen.dart';
import 'admin_stats_screen.dart';
import 'pos_screen.dart';
import 'reports_screen.dart';
import 'admin_prescriptions_screen.dart';
import 'admin_alerts_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminStatsScreen(),
    const MedicineManagementScreen(),
    const OrderManagementScreen(),
    const POSScreen(),
    const AdminPrescriptionsScreen(),
    const AdminAlertsScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Row(
          children: [
            // Sidebar for Desktop/Tablet
            if (MediaQuery.of(context).size.width > 600)
              NavigationRail(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                leading: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(Icons.local_pharmacy, color: Colors.tealAccent, size: 40),
                    const SizedBox(height: 20),
                  ],
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        onPressed: () {
                          context.read<AuthProvider>().signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const AuthScreen()),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                labelType: NavigationRailLabelType.all,
                selectedLabelTextStyle: const TextStyle(color: Colors.tealAccent),
                unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined, color: Colors.white70),
                    selectedIcon: Icon(Icons.bar_chart, color: Colors.tealAccent),
                    label: Text('الإحصائيات'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined, color: Colors.white70),
                    selectedIcon: Icon(Icons.inventory_2, color: Colors.tealAccent),
                    label: Text('الأدوية'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.shopping_bag_outlined, color: Colors.white70),
                    selectedIcon: Icon(Icons.shopping_bag, color: Colors.tealAccent),
                    label: Text('الطلبات'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.point_of_sale_outlined, color: Colors.white70),
                    selectedIcon: Icon(Icons.point_of_sale, color: Colors.tealAccent),
                    label: Text('POS'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.description_outlined, color: Colors.white70),
                    selectedIcon: Icon(Icons.description, color: Colors.tealAccent),
                    label: Text('الروشتات'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.notifications_active_outlined, color: Colors.white70),
                    selectedIcon: Icon(Icons.notifications_active, color: Colors.tealAccent),
                    label: Text('التنبيهات'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_outlined, color: Colors.white70),
                    selectedIcon: Icon(Icons.analytics, color: Colors.tealAccent),
                    label: Text('التقارير'),
                  ),
                ],
              ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'لوحة تحكم المسؤول',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (MediaQuery.of(context).size.width <= 600)
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              // Drawer or BottomSheet for Mobile
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: _screens[_selectedIndex],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 600
          ? BottomNavigationBar(
              backgroundColor: const Color(0xFF203A43),
              selectedItemColor: Colors.tealAccent,
              unselectedItemColor: Colors.white70,
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'الإحصائيات'),
                BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'الأدوية'),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'الطلبات'),
              ],
            )
          : null,
    );
  }
}
