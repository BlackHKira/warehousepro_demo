import 'package:flutter/material.dart';
import 'import_screen.dart';
import 'export_screen.dart';
import 'bulk_scan_screen.dart';
import 'search_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WarehousePro'),
        centerTitle: false,
        actions: [
          // Sync status badge
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sync_problem, size: 16, color: Color(0xFFE65100)),
                const SizedBox(width: 4),
                Text('3', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100), fontSize: 13)),
                const Text(' chờ sync', style: TextStyle(fontSize: 12, color: Color(0xFFE65100))),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: cs.primaryContainer, child: Icon(Icons.person, color: cs.onPrimaryContainer)),
                title: const Text('Nguyễn Văn A', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Thủ kho'),
                trailing: Icon(Icons.wifi_off, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Tổng SP', value: '486', icon: Icons.inventory_2, color: cs.primary)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Chờ sync', value: '3', icon: Icons.sync, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Nhập hôm nay', value: '5', icon: Icons.arrow_downward, color: Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Xuất hôm nay', value: '12', icon: Icons.arrow_upward, color: Colors.red.shade400)),
              ],
            ),
            const SizedBox(height: 24),

            // Main actions - matching requirement spec
            Text('Tác vụ', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            _ActionButton(
              icon: Icons.import_export,
              label: 'Nhập kho',
              subtitle: 'Tạo phiếu nhập → Quét mã + nhập SL → Lưu',
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportScreen())),
            ),
            _ActionButton(
              icon: Icons.output,
              label: 'Xuất kho',
              subtitle: 'Tạo phiếu xuất / Chọn lệnh xuất → Quét + confirm',
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen())),
            ),
            _ActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Quét hàng loạt (kiểm kê)',
              subtitle: 'Chọn khu vực → Continuous scan → So sánh tồn',
              color: cs.primary,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BulkScanScreen())),
            ),
            _ActionButton(
              icon: Icons.search,
              label: 'Tra cứu sản phẩm',
              subtitle: 'Tìm bằng Barcode hoặc tên sản phẩm',
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            ),
            const SizedBox(height: 12),

            // Quick sync button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đồng bộ 3 phiếu'), behavior: SnackBarBehavior.floating),
                  );
                },
                icon: const Icon(Icons.sync),
                label: const Text('Đồng bộ ngay'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(radius: 26, backgroundColor: color.withAlpha(25), child: Icon(icon, color: color)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
