import 'package:flutter/material.dart';

import 'habi_colors.dart';
import 'habi_nav_bar.dart';
import 'job_card.dart';
import 'job_store.dart';
import 'jobs_screen.dart';

/// My Jobs: the jobs the person applied for or is taking.
class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabiColors.navy,
      appBar: AppBar(
        backgroundColor: HabiColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Jobs',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/habi_bg.jpg', fit: BoxFit.cover),
          Container(color: HabiColors.navy.withAlpha(225)),
          SafeArea(
            child: ListenableBuilder(
              listenable: JobStore.instance,
              builder: (context, _) {
                final jobs = JobStore.instance.appliedJobs;
                if (jobs.isEmpty) return _buildEmpty(context);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        'Jobs you applied for or are taking.',
                        style: TextStyle(
                          fontSize: 14,
                          color: HabiColors.cream.withAlpha(210),
                        ),
                      ),
                    ),
                    for (final job in jobs)
                      JobCard(job: job, userName: userName),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: HabiNavBar(userName: userName),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.work_outline, color: HabiColors.gold, size: 44),
            const SizedBox(height: 12),
            const Text(
              'No jobs yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Jobs you apply for will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: HabiColors.cream.withAlpha(200),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => JobsScreen(userName: userName),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE2BB6C),
                foregroundColor: HabiColors.navy,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Browse jobs',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}