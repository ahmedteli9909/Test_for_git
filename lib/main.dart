import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:d_hawk/core/theme/app_theme.dart';
import 'package:d_hawk/core/router/app_router.dart';
import 'package:d_hawk/core/utils/storage_helper.dart';
import 'package:d_hawk/providers/auth_provider.dart';
import 'package:d_hawk/providers/security_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await StorageHelper.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: MaterialApp.router(
        title: 'D-HAWK Security',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
