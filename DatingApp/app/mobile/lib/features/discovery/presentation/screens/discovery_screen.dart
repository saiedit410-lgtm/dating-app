import 'package:dating_app/features/discovery/presentation/screens/nearby_screen.dart';
import 'package:dating_app/features/discovery/presentation/widgets/all_discovery_body.dart';
import 'package:flutter/material.dart';

/// Top-level discovery screen — switches between "All" (paginated global
/// feed) and "Nearby" (radius-bucketed, location-aware feed).
class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.public), text: 'All'),
              Tab(icon: Icon(Icons.near_me_outlined), text: 'Nearby'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[AllDiscoveryBody(), NearbyScreen()],
        ),
      ),
    );
  }
}
