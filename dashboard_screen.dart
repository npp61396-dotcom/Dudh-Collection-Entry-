import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/milk_entry.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/dashboard/summary_card.dart';
import '../../widgets/dashboard/chart_widget.dart';
import '../../widgets/dashboard/recent_entries.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.dashboard,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardProvider>().loadDashboardData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile/settings
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: AppStrings.todayCollection,
                        value: '${provider.todayTotalWeight} किलो',
                        icon: Icons.local_drink,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: AppStrings.totalAmount,
                        value: '₹${provider.todayTotalAmount}',
                        icon: Icons.currency_rupee,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: AppStrings.morningShift,
                        value: '${provider.morningShiftWeight} किलो',
                        icon: Icons.wb_sunny,
                        color: AppColors.warningOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: AppStrings.eveningShift,
                        value: '${provider.eveningShiftWeight} किलो',
                        icon: Icons.nightlight,
                        color: AppColors.infoBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Charts Section
                const Text(
                  'संग्रह विश्लेषण',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey800,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ChartWidget(
                    chartData: provider.chartData,
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Entries
                const Text(
                  AppStrings.recentEntries,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey800,
                  ),
                ),
                const SizedBox(height: 12),
                RecentEntriesWidget(
                  entries: provider.recentEntries,
                  onTap: (entry) {
                    // Navigate to entry detail
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-entry');
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          AppStrings.addEntry,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
