import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/profile',
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
                    backgroundImage: AssetImage('assets/user-icon.jpg')
                        as ImageProvider<Object>,
                    child: null,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    user?.username ?? 'Guest',
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
            title: user?.rol == "client"
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
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              authProvider.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
