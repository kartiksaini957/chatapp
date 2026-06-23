import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // In real app, load from local DB (Hive / SharedPreferences)
  final List<QuestionHistory> _history = [
    QuestionHistory(
      id: '1',
      question: 'Bhakti kya hai aur kaise karein?',
      shortAnswer: 'Bhakti ek prem hai jo Bhagwan ke liye...',
      askedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    QuestionHistory(
      id: '2',
      question: 'Radha ji ki mahima batayein',
      shortAnswer: 'Radha ji Vrindavan ki adhishthatri...',
      askedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    QuestionHistory(
      id: '3',
      question: 'Guru seva ka mahatva kya hai?',
      shortAnswer: 'Guru ki seva sab sevao mein uttam...',
      askedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.deepMaroon),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Aapke Sawaal',
          style: TextStyle(
            color: AppTheme.deepMaroon,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('History Clear Karein?'),
                  content: const Text(
                      'Kya aap sab purane sawaal delete karna chahte hain?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _history.clear());
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightMaroon,
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppTheme.lightMaroon),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8DDD0)),
        ),
      ),
      body: _history.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildHistoryCard(_history[index]);
              },
            ),
    );
  }

  Widget _buildHistoryCard(QuestionHistory item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(initialQuestion: item.question),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.saffron.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.history_rounded,
                  color: AppTheme.saffron,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.question,
                    style: const TextStyle(
                      color: AppTheme.deepMaroon,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.shortAnswer,
                    style: const TextStyle(
                      color: Color(0xFF998877),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item.askedAt),
                    style: const TextStyle(
                      color: Color(0xFFBBAA99),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFBBAA99),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📜', style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            'Koi sawaal nahi pucha abhi tak',
            style: TextStyle(
              color: AppTheme.deepMaroon,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Guruji se apna pehla sawaal poochiye!',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes} minute pehle';
    if (diff.inDays < 1) return '${diff.inHours} ghante pehle';
    if (diff.inDays == 1) return 'Kal';
    return '${diff.inDays} din pehle';
  }
}
