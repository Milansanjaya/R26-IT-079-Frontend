import 'package:flutter/material.dart';
import 'customer_home.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Close",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),

        centerTitle: true,

        title: const Text(
          "Profile Settings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// Profile Card
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          children: [

            Row(
              children: [

                const CircleAvatar(
                  radius: 32,
                  backgroundImage:
                      AssetImage("assets/images/profile.jpg"),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [

                      Text(
                        "Milan Sanjaya",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "milan.sanjaya@email.com",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "+94 77 123 4567",
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () {},

              icon: const Icon(Icons.swap_horiz),

              label: const Text("Switch Account"),

              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 25),

      /// Profile Insights
Container(
  padding: const EdgeInsets.all(18),

  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),

    boxShadow: [
      BoxShadow(
        color: Colors.grey.shade200,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),

  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      Row(
        children: [

          const Icon(
            Icons.bar_chart,
            color: Color(0xff123D8C),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              "Your Profile Insights",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.chevron_right,
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [

          insightItem(
            "12",
            "Total Orders",
          ),

          insightItem(
            "8.5K",
            "Total Spent\n(LKR)",
          ),

          insightItem(
            "24",
            "Reward Points",
          ),
        ],
      ),
    ],
  ),
),

const SizedBox(height: 25),


    const Text(
  "How do you set up an account?",
  style: TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

settingTile(
  Icons.person_outline,
  "Profile",
  "Update profile picture and change username",
),

settingTile(
  Icons.shield_outlined,
  "Account Security",
  "Change password, Two Factor Auth, Login Device",
),

settingTile(
  Icons.lock_outline,
  "Privacy Settings",
  "Make your account private and control visibility",
),

const SizedBox(height: 25),

const Text(
  "Adjust the theme to your preferences",
  style: TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

settingTile(
  Icons.wb_sunny_outlined,
  "Change Theme",
  "Dark Mode, Light Mode, adjust as you like",
),

const SizedBox(height: 25),

const Text(
  "Additional Settings",
  style: TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

settingTile(
  Icons.delete_outline,
  "Delete Account",
  "Delete your account permanently",
  iconColor: Colors.red,
),

settingTile(
  Icons.logout,
  "Log Out Account",
  "Log out of your account",
  iconColor: Colors.red,
),

const SizedBox(height: 30),


Widget settingTile(
  IconData icon,
  String title,
  String subtitle, {
  Color iconColor = const Color(0xff123D8C),
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade100,
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const Icon(Icons.chevron_right),

        bottomNavigationBar: BottomNavigationBar(
  currentIndex: 3,

  type: BottomNavigationBarType.fixed,

  selectedItemColor: const Color(0xff0A5B8E),

  unselectedItemColor: Colors.grey,

  onTap: (index) {
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Categories coming soon"),
        ),
      );
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Orders coming soon"),
        ),
      );
    }
  },

  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: "Home",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.grid_view),
      label: "Categories",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_bag_outlined),
      label: "Orders",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: "Profile",
    ),
  ],
),
      ],
    ),
  );
}

    
    );
  }
}