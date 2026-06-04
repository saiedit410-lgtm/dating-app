import 'dart:async';
import 'dart:convert';

import 'package:dating_app/features/discovery/domain/discovery_filters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'discovery_filters_controller.g.dart';

/// Holds the active [DiscoveryFilters], persisted locally via
/// SharedPreferences so they survive app restarts.
@Riverpod(keepAlive: true)
class DiscoveryFiltersController extends _$DiscoveryFiltersController {
  static const String _key = 'discovery_filters_v1';

  @override
  DiscoveryFilters build() {
    // Load persisted filters asynchronously; default until they arrive.
    unawaited(_load());
    return const DiscoveryFilters();
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      state = DiscoveryFilters.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      // Corrupt/old format — ignore and keep defaults.
    }
  }

  Future<void> update(DiscoveryFilters filters) async {
    state = filters;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(filters.toMap()));
  }

  Future<void> clear() => update(const DiscoveryFilters());
}
