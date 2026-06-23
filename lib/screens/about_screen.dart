import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.deepMaroon,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.deepMaroon, AppTheme.lightMaroon],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.gold, AppTheme.saffron],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.saffron.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🪷', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Shri Hit Radha Kripa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Guruji ke pravachan aapki seva mein',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    icon: '📺',
                    title: 'YouTube Channel',
                    subtitle: '@ShriHitRadhaKripa',
                    color: const Color(0xFFFF0000),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: '🎙️',
                    title: 'App ke baare mein',
                    subtitle:
                        'Yeh app Guruji ke YouTube videos ke transcripts se aapke sawalon ke jawab deti hai. AI technology ka upyog karke Guruji ke pravachan se relevant answers dhundhe jaate hain.',
                    color: AppTheme.saffron,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: '⚠️',
                    title: 'Disclaimer',
                    subtitle:
                        'Ye app sirf Guruji ke videos ke transcripts se answers provide karti hai. Yeh Guruji ka official app nahi hai. Kisi bhi baat ki confirmation ke liye Guruji ke videos zaroor dekhein.',
                    color: AppTheme.gold,
                  ),
                  const SizedBox(height: 24),
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('100+', 'Videos'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('∞', 'Sawaal'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('24/7', 'Uplabdh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Jai Radhe text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFF3CD),
                          Color(0xFFFFE8B0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.gold.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          '🙏 Radhe Radhe 🙏',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.deepMaroon,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '"Radha naam ka jaap karo,\nPrem ka dip jalaao,\nGuruji ke vachan sunna,\nAur apna jivan safal banaao"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6B4C00),
                            fontSize: 13,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.deepMaroon,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF998877),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.saffron,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF998877),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
