import 'package:flutter/material.dart';

class BbDashboard extends StatefulWidget {
  const BbDashboard({super.key});

  @override
  State<BbDashboard> createState() => _BbDashboardState();
}

class _BbDashboardState extends State<BbDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Transparent SliverAppBar that collapses
          SliverAppBar(
            expandedHeight: 200,
            pinned: false, // Don't keep it fixed on top
            floating: true, // No quick reappear
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.blue.shade700,
                child: const Center(
                  child: Text(
                    'Study = Game!',
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // The list below scrolls under the AppBar
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Item #$index'),
              ),
              childCount: 20,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade100, // Optional background
    );
  }
}
