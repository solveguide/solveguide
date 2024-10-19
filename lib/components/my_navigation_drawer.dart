import 'package:flutter/material.dart';
import 'package:guide_solve/components/logo.dart';
import 'package:guide_solve/pages/contact_page.dart';
import 'package:guide_solve/pages/dashboard_page.dart';
import 'package:guide_solve/pages/profile_page.dart';
import 'package:guide_solve/pages/proven_solved_issues_page.dart';

class MyNavigationDrawer extends StatelessWidget {
  const MyNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: logoTitle(
                    5,
                    iconSize: 50,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text('D A S H B O A R D'),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (context) => const DashboardPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: ListTile(
                  title: const Text('S O L V E S'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (context) => const ProvenSolvesPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text('S E T T I N G S'),
                  leading: const Icon(Icons.settings),
                  onTap: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text('C O N T A C T S'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (context) => const ContactPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 25),
            child: ListTile(
              title: const Text('M Y   A C C O U N T'),
              leading: const Icon(Icons.logout),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<Widget>(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
