import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

const _keyLastSync = 'warehouse_last_sync';

class WarehouseState {
  final int totalProducts;
  final int todayImports;
  final int todayExports;
  final bool isSyncing;
  final String? lastSyncAt;
  final String? syncError;
  final List<Map<String, dynamic>> recentImports;
  final List<Map<String, dynamic>> recentExports;

  WarehouseState({
    this.totalProducts = 0,
    this.todayImports = 0,
    this.todayExports = 0,
    this.isSyncing = false,
    this.lastSyncAt,
    this.syncError,
    this.recentImports = const [],
    this.recentExports = const [],
  });

  int get pendingSync =>
    recentImports.where((e) => e['syncStatus'] == 'pending').length +
    recentExports.where((e) => e['syncStatus'] == 'pending').length;

  WarehouseState copyWith({
    int? totalProducts,
    int? todayImports,
    int? todayExports,
    bool? isSyncing,
    String? lastSyncAt,
    String? syncError,
    List<Map<String, dynamic>>? recentImports,
    List<Map<String, dynamic>>? recentExports,
  }) {
    return WarehouseState(
      totalProducts: totalProducts ?? this.totalProducts,
      todayImports: todayImports ?? this.todayImports,
      todayExports: todayExports ?? this.todayExports,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncError: syncError ?? this.syncError,
      recentImports: recentImports ?? this.recentImports,
      recentExports: recentExports ?? this.recentExports,
    );
  }
}

class WarehouseNotifier extends StateNotifier<WarehouseState> {
  final FirestoreService _firestore = FirestoreService();
  final Connectivity _connectivity = Connectivity();

  WarehouseNotifier() : super(WarehouseState()) {
    _loadPersistedState();
    _connectivity.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none) && state.pendingSync > 0) {
        syncData();
      }
    });
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_keyLastSync);
    if (lastSync != null) {
      state = state.copyWith(lastSyncAt: lastSync);
    }
  }

  void addImport(int itemCount, String supplier, {String zone = 'D'}) {
    final entry = {
      'syncStatus': 'pending',
      'supplier': supplier,
      'items': itemCount,
      'type': 'import',
      'zone': zone,
      'time': DateTime.now().toIso8601String(),
    };
    state = state.copyWith(
      totalProducts: state.totalProducts + itemCount,
      todayImports: state.todayImports + itemCount,
      recentImports: [entry, ...state.recentImports],
    );
    _persistData();
    syncData();
  }

  void addExport(int itemCount, String customer, {String zone = 'D'}) {
    final entry = {
      'syncStatus': 'pending',
      'customer': customer,
      'items': itemCount,
      'type': 'export',
      'zone': zone,
      'time': DateTime.now().toIso8601String(),
    };
    state = state.copyWith(
      totalProducts: state.totalProducts - itemCount,
      todayExports: state.todayExports + itemCount,
      recentExports: [entry, ...state.recentExports],
    );
    _persistData();
    syncData();
  }

  Future<void> syncData() async {
    if (state.isSyncing || state.pendingSync == 0) return;
    state = state.copyWith(isSyncing: true, syncError: null);

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      state = state.copyWith(
        isSyncing: false,
        syncError: 'Không có kết nối mạng',
      );
      return;
    }

    try {
      final syncedImports = <Map<String, dynamic>>[];
      for (final entry in state.recentImports) {
        if (entry['syncStatus'] == 'synced') {
          syncedImports.add(Map<String, dynamic>.from(entry));
          continue;
        }
        await _firestore.transactions.add({
          'type': 'import',
          'supplier': entry['supplier'],
          'items': entry['items'],
          'zone': entry['zone'] ?? 'D',
          'createdAt': FieldValue.serverTimestamp(),
        });
        syncedImports.add({...entry, 'syncStatus': 'synced'});
      }

      final syncedExports = <Map<String, dynamic>>[];
      for (final entry in state.recentExports) {
        if (entry['syncStatus'] == 'synced') {
          syncedExports.add(Map<String, dynamic>.from(entry));
          continue;
        }
        await _firestore.transactions.add({
          'type': 'export',
          'customer': entry['customer'],
          'items': entry['items'],
          'zone': entry['zone'] ?? 'D',
          'createdAt': FieldValue.serverTimestamp(),
        });
        syncedExports.add({...entry, 'syncStatus': 'synced'});
      }

      final syncTime = DateTime.now().toIso8601String();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastSync, syncTime);

      state = state.copyWith(
        isSyncing: false,
        lastSyncAt: syncTime,
        syncError: null,
        recentImports: syncedImports,
        recentExports: syncedExports,
      );
      _persistData();
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncError: 'Lỗi đồng bộ: $e',
      );
    }
  }

  void clearSyncError() {
    state = state.copyWith(syncError: null);
  }

  Future<void> _persistData() async {
    final prefs = await SharedPreferences.getInstance();
    if (state.lastSyncAt != null) {
      await prefs.setString(_keyLastSync, state.lastSyncAt!);
    }
  }
}

final warehouseProvider = StateNotifierProvider<WarehouseNotifier, WarehouseState>((ref) {
  return WarehouseNotifier();
});
