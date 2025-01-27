import 'package:biblioteca/services/auth_service.dart';
import 'package:biblioteca/ui/widgets/custom_password_form_field.dart';
import 'package:biblioteca/ui/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.onTap});

  final void Function()? onTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rePasswordController = TextEditingController();

  void signUp() async {
    if (passwordController.text != rePasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("As senhas não coincidem."),
        ),
      );
      return;
    }

    final authService =
        Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signUpWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cadastro realizado com sucesso!"),
        ),
      );

      Navigator.of(context).pop();
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.chat_outlined,
                  size: 150,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 40),
                Text(
                  "Vamos criar uma nova conta!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  labelText: "E-mail",
                  controller: emailController,
                ),
                const SizedBox(height: 20),
                CustomPasswordFormField(
                  labelText: "Senha",
                  controller: passwordController,
                ),
                const SizedBox(height: 20),
                CustomPasswordFormField(
                  labelText: "Confirmar Senha",
                  controller: rePasswordController,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: "Cadastrar",
                  height: 100,
                  onClick: signUp,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Já é cadastrado?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Entrar agora.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
