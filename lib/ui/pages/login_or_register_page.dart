import 'package:biblioteca/ui/pages/register_page.dart';
import 'package:biblioteca/ui/pages/login_page.dart';
import 'package:flutter/material.dart';


class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool shouldShowLoginPage = true;

  void togglePages() {
    setState(() {
      shouldShowLoginPage = !shouldShowLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return shouldShowLoginPage
        ? LoginPage(
      onTap: togglePages,
    )
        : RegisterPage(
      onTap: togglePages,
    );
  }
}