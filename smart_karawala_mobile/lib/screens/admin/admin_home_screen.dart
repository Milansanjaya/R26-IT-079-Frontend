
import 'admin_profile_screen.dart';

class PanelItem {
  final String id;
  final String title;
  final IconData icon;
  final String category;
  final List<String> keywords;
  final void Function(BuildContext context) onTap;

  const PanelItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    required this.keywords,
    required this.onTap,
  });
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(context),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,

      ),
    );
  }
}
