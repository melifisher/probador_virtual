import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../screens/client/profile_page.dart';

class DrawerWidget extends StatelessWidget {
  final User user;

  const DrawerWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              // Navega a la página de perfil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: user),
                ),
              );
            },
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        /* user.photoUrl.isNotEmpty? NetworkImage(user.photoUrl)
                        : const */
                        AssetImage('assets/user-icon.jpg')
                            as ImageProvider<Object>,
                    child: null,
                    /* child: user.photoUrl.isEmpty
                        ? Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          )
                        : null, */
                  ),
                  const SizedBox(width: 16),
                  Text(
                    user.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              // TODO: Implement cart functionality
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: user.rol == "client"
                ? const Text('Order History')
                : const Text('Alquileres'),
            onTap: () {
              // TODO: Implement order history functionality
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorias de prendas'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/categories',
                arguments: user,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              // TODO: Implement logout functionality
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
