import 'package:flutter/material.dart';
import 'package:probador_virtual/controllers/address_controller.dart';
import 'package:probador_virtual/screens/payment/qr_payment_page.dart';
import 'package:provider/provider.dart';
import 'models/devolucion.dart';
import 'providers/auth_provider.dart';
import 'config/environment/environment.dart';
import 'config/theme/app_theme.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/product/products_page.dart';
import 'screens/product/product_detail_page.dart';
import 'models/product.dart';
import 'models/category.dart';
import 'models/alquiler.dart';
import 'screens/home_page.dart';
import 'screens/category/categories_page.dart';
import 'screens/category/category_detail_page.dart';
import 'screens/client/profile_page.dart';
import 'screens/alquiler/alquiler_list_screen.dart';
import 'screens/alquiler/alquiler_detail_page.dart';
import 'screens/rent/cart_page.dart';
import 'screens/address/list_address_page.dart';
import 'screens/address/create_address_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/devolucion/devolucion_list_page.dart';
import 'screens/devolucion/devolucion_detail_page.dart';
import 'screens/recommendation/recommended_products_page.dart';
import 'screens/recommendation/choose_recommendation_page.dart';
import 'screens/card/credit_card_widget.dart';
import 'screens/payment/payment_confirmation_page.dart';

void main() async {
  await Environment.initEnvironment();
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar SharedPreferences y cargar user_id
  final prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('user_id'); // Carga el user_id si está guardado

    runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AddressController()),
        // Puedes añadir más providers si es necesario
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PROBADOR VIRTUAL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const HomePage());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginView());
          case '/register':
            return MaterialPageRoute(
                builder: (context) => const RegisterView());
          case '/products':
            final categoryId = settings.arguments as int?;
            return MaterialPageRoute(
                builder: (context) => ProductsPage(
                      categoryId: categoryId,
                    ));
          case '/product':
            final product = settings.arguments as Product?;
            return MaterialPageRoute(
              builder: (context) => ProductDetailView(
                product: product,
              ),
            );
          case '/categories':
            return MaterialPageRoute(
                builder: (context) => const CategoriesPage());
          case '/category':
            final category = settings.arguments as Category?;
            return MaterialPageRoute(
              builder: (context) => CategoryDetailView(
                category: category,
              ),
            );
          case '/cart':
            return MaterialPageRoute(
              builder: (context) => CartPage(
                cartItems: [], // Puedes pasar los items del carrito aquí si es necesario
                rentalDays: 0, // Ajusta los días según la lógica de tu app
                totalPrice:
                    0, // Ajusta el precio total según la lógica de tu app
              ),
            );
          case '/listAddress':
            return MaterialPageRoute(builder: (context) => ListAddressPage());

          case '/addAddress':
            return MaterialPageRoute(
              builder: (context) => CreateAddressPage(),
            );
          

          

          case '/profile':
            return MaterialPageRoute(builder: (context) => const ProfilePage());
          case '/rentals':
            return MaterialPageRoute(
                builder: (context) => const AlquilerListScreen());
          case '/rental':
            final alquiler = settings.arguments as Alquiler?;
            return MaterialPageRoute(
                builder: (context) => AlquilerDetailPage(
                      rental: alquiler,
                    ));
          case '/devoluciones':
            return MaterialPageRoute(
                builder: (context) => const DevolucionListPage());
          case '/devolucion':
            final alquiler = settings.arguments as Devolucion?;
            return MaterialPageRoute(
                builder: (context) => DevolucionDetailPage(
                      devolucion: alquiler,
                    ));
          case '/recommendations':
            return MaterialPageRoute(
                builder: (context) => const ChooseRecommendationsPage());
          case '/recommended_products':
            final type = settings.arguments as int?;
            return MaterialPageRoute(
                builder: (context) => RecommendationsPage(type: type ?? 0));
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ),
            );
        }
      },
    );
  }
}
