import 'package:flutter/material.dart';

import '../Screens/settings_screen.dart';
import '../Services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    //get auth service
    final auth = AuthServices();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .background,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                  children: [
                    //logo
                    DrawerHeader(
                      child: Center(
                        child: Icon(
                          Icons.message,
                          size: 48,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                    ),

                    //home list tile
                    Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: ListTile(
                          title: const Text("H O M E"),
                          leading: const Icon(Icons.home),
                          onTap: () {
                            //pop drawer
                            Navigator.pop(context);
                          },
                        )
                    ),

                    //setting list tile
                    Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: ListTile(
                          title: const Text("S E T T I N G S"),
                          leading: const Icon(Icons.settings),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsPage()),
                            );
                          },
                        )
                    ),
                  ]
              ),

              //logout list tile
              Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: const Text("L O G O U T"),
                    leading: const Icon(Icons.logout),
                    onTap: logout,
                  )
              ),
            ]
        )
    );
  }
}
