import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/strings.dart';
import 'core/themes/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/milk_entry_provider.dart';
import 'presentation/providers/farmer_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/ai_chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive/SQLite here if needed
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MilkEntryProvider()),
        ChangeNotifierProvider(create: (_) => FarmerProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AiChatProvider()),
      ],
      child: const SmartDairyApp(),
    ),
  );
}

class SmartDairyApp extends StatelessWidget {
  const SmartDairyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('hi', 'IN'), // Hindi
            Locale('en', 'US'),
          ],
          locale: const Locale('hi', 'IN'),
          home: const DashboardScreen(),
          onGenerateRoute: AppRouter.generateRoute,
          builder: (context, child) {
            return Stack(
              children: [
                child!,
                // Floating AI Assistant Button
                const Positioned(
                  bottom: 20,
                  right: 20,
                  child: AiChatWidget(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
