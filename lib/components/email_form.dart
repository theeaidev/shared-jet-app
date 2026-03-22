import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devtodollars/components/recover_password_dialog.dart';
import 'package:devtodollars/services/auth_notifier.dart';

enum AuthAction { signIn, signUp }

class EmailForm extends ConsumerStatefulWidget {
  const EmailForm({super.key});

  @override
  ConsumerState<EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends ConsumerState<EmailForm> {
  AuthAction action = AuthAction.signUp;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  String errorMessage = '';
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  String? validateEmailField() {
    final email = emailController.text;
    if (email.isEmpty) {
      return "Email is required";
    }
    // https://stackoverflow.com/a/4964766/13659833
    if (!RegExp(r"^\S+@\S+\.\S+$").hasMatch(email)) {
      return "Invalid email";
    }
    return null;
  }

  String? validatePasswordField() {
    final password = pwController.text;
    if (password.isEmpty) {
      return "Password is required";
    }
    if (password.length < 6) {
      return "Password must be at least 6 characters long";
    }
    return null;
  }

  String? validateConfirmPasswordField() {
    final password = pwController.text;
    final confirmPassword = confirmPwController.text;
    if (confirmPassword.isEmpty) {
      return "Password confirmation is required";
    }
    if (confirmPassword != password) {
      return "Passwords do not match";
    }
    return null;
  }

  void submitForm() async {
    final email = emailController.text;
    final password = pwController.text;
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => loading = true);
        final authNotif = ref.read(authProvider.notifier);

        if (action == AuthAction.signIn) {
          await authNotif.signInWithPassword(email, password);
        } else if (action == AuthAction.signUp) {
          await authNotif.signUp(email, password);
          if (mounted) {
            setState(() => action = AuthAction.signIn);
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Registro completado"),
                content: const Text("Puedes iniciar sesión."),
                actions: [
                  TextButton(
                      onPressed: context.pop, child: const Text("Aceptar"))
                ],
              ),
            );
          }
        }
        if (mounted) setState(() => loading = false);
      } on AuthException catch (e) {
        setState(() {
          loading = false;
          errorMessage = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text((action == AuthAction.signIn) ? "Log in" : "Create an account",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextFormField(
              controller: emailController,
              enabled: !loading,
              autofocus: true,
              style: GoogleFonts.lato(color: Colors.black87),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: GoogleFonts.lato(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black54),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (_) => validateEmailField(),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: pwController,
              enabled: !loading,
              style: GoogleFonts.lato(color: Colors.black87),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: GoogleFonts.lato(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black54),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              obscureText: true,
              validator: (_) => validatePasswordField(),
              autofillHints: const [AutofillHints.password],
              keyboardType: TextInputType.text,
            ),
            (action == AuthAction.signUp)
                ? Column(
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPwController,
                        enabled: !loading,
                        style: GoogleFonts.lato(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          labelStyle: GoogleFonts.lato(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black54),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        obscureText: true,
                        validator: (_) => validateConfirmPasswordField(),
                        autofillHints: const [AutofillHints.password],
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  )
                : const SizedBox(height: 0),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorMessage,
                  style:
                      textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (action == AuthAction.signIn) {
                          action = AuthAction.signUp;
                        } else {
                          action = AuthAction.signIn;
                        }
                        errorMessage = "";
                      });
                    },
                    child: Text(
                      (action == AuthAction.signIn)
                          ? "Don't have an account?"
                          : "Already have an account?",
                      style: GoogleFonts.lato(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return RecoverPasswordDialog(
                              email: emailController.text);
                        },
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.lato(
                        color: const Color(0xFFD4AF37), // Gold highlight
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: (loading) ? null : submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      (action == AuthAction.signUp) ? "Sign Up" : "Sign In",
                      style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
