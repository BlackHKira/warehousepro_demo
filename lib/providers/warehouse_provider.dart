import 'package:flutter_riverpod/flutter_riverpod.dart';

class WarehouseState {
  final int totalProducts;
  final int pendingSync;
  final int todayImports;
  final int todayExports;
  final List<Map<String, dynamic>> recentImports;
  final List<Map<String, dynamic>> recentExports;

  WarehouseState({
    this.totalProducts = 0,
    this.pendingSync = 0,
    this.todayImports = 0,
    this.todayExports = 0,
    this.recentImports = const [],
    this.recentExports = const [],
  });

  WarehouseState copyWith({
    int? totalProducts,
    int? pendingSync,
    int? todayImports,
    int? todayExports,
    List<Map<String, dynamic>>? recentImports,
    List<Map<String, dynamic>>? recentExports,
  }) {
    return WarehouseState(
      totalProducts: totalProducts ?? this.totalProducts,
      pendingSync: pendingSync ?? this.pendingSync,
      todayImports: todayImports ?? this.todayImports,
      todayExports: todayExports ?? this.todayExports,
      recentImports: recentImports ?? this.recentImports,
      recentExports: recentExports ?? this.recentExports,
    );
  }
}

class WarehouseNotifier extends StateNotifier<WarehouseState> {
  WarehouseNotifier() : super(WarehouseState());

  void addImport(int itemCount, String supplier) {
    state = state.copyWith(
      totalProducts: state.totalProducts + itemCount,
      todayImports: state.todayImports + itemCount,
      pendingSync: state.pendingSync + itemCount,
      recentImports: [
        {'supplier': supplier, 'items': itemCount, 'time': DateTime.now()},
        ...state.recentImports,
      ],
    );
  }

  void addExport(int itemCount, String customer) {
    state = state.copyWith(
      totalProducts: state.totalProducts - itemCount,
      todayExports: state.todayExports + itemCount,
      pendingSync: state.pendingSync + itemCount,
      recentExports: [
        {'customer': customer, 'items': itemCount, 'time': DateTime.now()},
        ...state.recentExports,
      ],
    );
  }

  void syncNow() {
    state = state.copyWith(pendingSync: 0);
  }
}

final warehouseProvider = StateNotifierProvider<WarehouseNotifier, WarehouseState>((ref) {
  return WarehouseNotifier();
});
