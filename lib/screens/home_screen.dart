import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/api_service.dart';
import '../models/auth_service.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';
import 'profile_screen.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestedQuestions = [];
  late AnimationController _headerAnim;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _headerFade =
        CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _loadSuggestions();
  }

  void _showLogoutMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.saffron.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.info_outline_rounded, color: AppTheme.saffron)),
              title: const Text('About', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.deepMaroon)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())); },
            ),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout_rounded, color: Colors.red)),
              title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Logout?', style: TextStyle(color: AppTheme.deepMaroon, fontWeight: FontWeight.w700)),
                    content: const Text('Kya aap logout karna chahte hain?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await AuthService.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSuggestions() async {
    final questions = await ApiService.getSuggestedQuestions();
    if (mounted) setState(() => _suggestedQuestions = questions);
  }

  void _askQuestion(String question) {
    if (question.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(initialQuestion: question.trim()),
      ),
    );
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          // Search bar
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),
          // Suggested questions label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.saffron,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Puchhe jaane wale sawaal',
                    style: TextStyle(
                      color: AppTheme.deepMaroon,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Suggested questions grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= _suggestedQuestions.length) {
                    return _buildSkeletonCard();
                  }
                  return _buildQuestionCard(
                    _suggestedQuestions[index],
                    index,
                  );
                },
                childCount:
                    _suggestedQuestions.isEmpty ? 6 : _suggestedQuestions.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.deepMaroon, AppTheme.lightMaroon],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.gold.withOpacity(0.2),
                            border: Border.all(
                              color: AppTheme.gold.withOpacity(0.4),
                            ),
                          ),
                          child: const Center(
                            child: Text('🪷', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shri Hit',
                              style: TextStyle(
                                color: AppTheme.gold.withOpacity(0.9),
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                            ),
                            const Text(
                              'Radha Kripa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showLogoutMenu(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Radhe Radhe! 🙏',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Guruji ke pravachan se apne\nsawalon ke jawab paaiye',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.saffron.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _askQuestion,
          style: const TextStyle(
            color: AppTheme.deepMaroon,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Apna sawaal yahan likhein...',
            hintStyle: const TextStyle(
              color: Color(0xFFBBAA99),
              fontSize: 15,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('🔍', style: TextStyle(fontSize: 18)),
            ),
            suffixIcon: GestureDetector(
              onTap: () => _askQuestion(_searchController.text),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.saffron,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  const BorderSide(color: AppTheme.saffron, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(String question, int index) {
    final colors = [
      [const Color(0xFFFFEDD8), AppTheme.saffron],
      [const Color(0xFFFFF3CD), AppTheme.gold],
      [const Color(0xFFFFE4E1), AppTheme.lightMaroon],
      [const Color(0xFFF0FFF4), const Color(0xFF2D6A4F)],
      [const Color(0xFFE8F4FD), const Color(0xFF1565C0)],
      [const Color(0xFFF3E5F5), const Color(0xFF6A1B9A)],
    ];
    final colorSet = colors[index % colors.length];

    return GestureDetector(
      onTap: () => _askQuestion(question),
      child: Container(
        decoration: BoxDecoration(
          color: colorSet[0],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorSet[1].withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorSet[1].withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: colorSet[1],
                size: 16,
              ),
            ),
            const Spacer(),
            Text(
              question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.deepMaroon,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E0D8),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E0D8),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 80,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E0D8),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'Home', true, () {}),
              _navItem(Icons.chat_bubble_outline_rounded, 'Puchho', false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              }),
              _navItem(Icons.history_rounded, 'History', false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              }),
              _navItem(Icons.person_outline_rounded, 'Profile', false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.saffron.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: active ? AppTheme.saffron : const Color(0xFFAA9988),
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: active ? AppTheme.saffron : const Color(0xFFAA9988),
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
