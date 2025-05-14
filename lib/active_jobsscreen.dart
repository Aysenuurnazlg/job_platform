import 'package:flutter/material.dart';
import 'ratingScreen.dart';

class MyActiveJobsScreen extends StatefulWidget {
  final int employerId;
  const MyActiveJobsScreen({Key? key, required this.employerId}) : super(key: key);

  @override
  State<MyActiveJobsScreen> createState() => _MyActiveJobsScreenState();
}

class _MyActiveJobsScreenState extends State<MyActiveJobsScreen> {
  List activeJobs = [];

  @override
  void initState() {
    super.initState();
    fetchActiveJobs();
  }

  Future<void> fetchActiveJobs() async {
    // Örnek veriler
    setState(() {
      activeJobs = [
        {
          'job_id': 1,
          'title': 'Web Sitesi Tasarımı',
          'worker_name': 'Ahmet Yılmaz',
          'worker_id': 10,
        },
        {
          'job_id': 2,
          'title': 'Logo Tasarımı',
          'worker_name': 'Elif Kaya',
          'worker_id': 15,
        },
      ];
    });
  }

  void navigateToRating(Map job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RateWorkerScreen(
          employerId: widget.employerId,
          workerId: job['worker_id'],
          jobId: job['job_id'],
          workerName: job['worker_name'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktif İlanlarım'),
        backgroundColor: const Color.fromARGB(255, 103, 144, 153),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: activeJobs.isEmpty
            ? const Center(child: Text("Aktif ilanınız bulunmamaktadır."))
            : ListView.builder(
                itemCount: activeJobs.length,
                itemBuilder: (context, index) {
                  final job = activeJobs[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['title'],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 20, color: Colors.blueGrey),
                              const SizedBox(width: 6),
                              Text("Çalışan: ${job['worker_name']}", style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => navigateToRating(job),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Tamamlandı Olarak İşaretle"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
