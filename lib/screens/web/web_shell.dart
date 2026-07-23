import 'package:flutter/material.dart';
import 'zone_management_screen.dart';

class WebShell extends StatefulWidget {
  const WebShell({super.key});

  @override
  State<WebShell> createState() => _WebShellState();
}

class _WebShellState extends State<WebShell> {
  int _selectedIndex = 0;

  static const _tabs = [
    ('📊 Overview', null),
    ('📈 Reports', null),
    ('📋 Orders', null),
    ('📍 Zones', ZoneManagementScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WarehousePro Admin'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person),
            label: const Text('Quản lý'),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            destinations: _tabs
                .map((t) => NavigationRailDestination(
                      icon: Text(t.$1, style: const TextStyle(fontSize: 20)),
                      label: Text(t.$1.split(' ').last),
                    ))
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final tab = _tabs[_selectedIndex];
    if (tab.$2 != null) return tab.$2!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Đang phát triển...', style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
        ],
      ),
    );
  }
}
