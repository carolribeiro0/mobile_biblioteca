import 'package:biblioteca/ui/widgets/auth_checker.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/di/configure_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final data = await ConfigureProviders.createDependencyTree();
  await Firebase.initializeApp();
  runApp(AppRoot(data: data));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.data});

  final ConfigureProviders data;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: data.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Biblioteca virtual',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: const AuthChecker(),
      ),
    );
  }
}
