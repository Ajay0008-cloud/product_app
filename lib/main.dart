import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/product_list_vm.dart';
import 'viewmodels/wishlist_vm.dart';
import 'viewmodels/cart_vm.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductListViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: MaterialApp(
        title: 'Luxe Shop',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0C0C0F),
          primaryColor: const Color(0xFFE5C158), // Champagne Gold
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE5C158),
            brightness: Brightness.dark,
            primary: const Color(0xFFE5C158),
            secondary: const Color(0xFFE97B5E), // Terracotta Coral
            surface: const Color(0xFF16161A),
            onSurface: const Color(0xFFF5F5F7),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0C0C0F),
            foregroundColor: Color(0xFFF5F5F7),
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF16161A),
            elevation: 8,
            shadowColor: Colors.black.withAlpha(80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900, color: Color(0xFFF5F5F7), letterSpacing: 0.5),
            titleLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Color(0xFFF5F5F7)),
            bodyLarge: TextStyle(fontFamily: 'Outfit', color: Color(0xFFE1E1E6)),
            bodyMedium: TextStyle(fontFamily: 'Outfit', color: Color(0xFF8C8C96)),
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: const Color(0xFFE5C158),
            inactiveTrackColor: Colors.white.withAlpha(20),
            thumbColor: const Color(0xFFE5C158),
            overlayColor: const Color(0xFFE5C158).withAlpha(38),
            valueIndicatorColor: const Color(0xFF16161A),
            valueIndicatorTextStyle: const TextStyle(color: Color(0xFFE5C158), fontWeight: FontWeight.bold),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
