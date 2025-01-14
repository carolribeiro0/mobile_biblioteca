import 'package:biblioteca/theme/theme.dart';
import 'package:biblioteca/theme/util.dart';
import 'package:biblioteca/ui/widgets/auth_checker.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/di/configure_providers.dart';
import 'firebase_options.dart';

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final data = await ConfigureProviders.createDependencyTree();

  runApp(AppRoot(data: data));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.data});

  final ConfigureProviders data;


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    TextTheme textTheme = createTextTheme(context, "Roboto Flex", "Roboto");

    MaterialTheme theme = MaterialTheme(textTheme);
    return MultiProvider(
      providers: data.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aula',
        theme: theme.light(),
        darkTheme: theme.dark(),
        home: const AuthChecker(),
      ),
    );
  }
}