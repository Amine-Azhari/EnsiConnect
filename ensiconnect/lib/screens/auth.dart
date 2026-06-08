import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../widgets/ensiconnect_app.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  // Deux formulaires separes pour valider la connexion et l'inscription.
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Service qui isole les appels Firestore de l'interface graphique.
  final _authServices = AuthServices();

  // Controllers utilises pour lire les valeurs saisies au moment du submit.
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signUpNomController = TextEditingController();
  final _signUpPrenomController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _hidePassword = true;

  // Evite les doubles clics pendant une requete Firebase.
  bool _isLoading = false;
  String? _authErrorMessage;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signUpNomController.dispose();
    _signUpPrenomController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_loginFormKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _authErrorMessage = null;
    });

    try {
      // Verification du compte dans la collection Etudiant.
      final isValid = await _authServices.login(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );

      if (!mounted) return;

      if (isValid) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _authErrorMessage = 'Adresse mail ou mot de passe incorrect.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _authErrorMessage = 'Erreur de connexion. Réessayez plus tard.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _register() async {
    if (!(_signUpFormKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _authErrorMessage = null;
    });

    try {
      // Creation du compte dans la collection Etudiant.
      await _authServices.register(
        nom: _signUpNomController.text,
        prenom: _signUpPrenomController.text,
        email: _signUpEmailController.text,
        password: _signUpPasswordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (mounted) {
        setState(() {
          _authErrorMessage = 'Erreur inscription : $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label obligatoire';
    }
    return null;
  }

  String? _uhaEmailValidator(String? value) {
    final email = value?.trim().toLowerCase() ?? '';

    // Format attendu: prenom.nom@uha.fr.
    if (email.isEmpty) {
      return 'Adresse mail obligatoire';
    }

    if (!RegExp(r'^[a-z]+[a-z-]*\.[a-z]+[a-z-]*@uha\.fr$').hasMatch(email)) {
      return 'Format attendu : prenom.nom@uha.fr';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Mot de passe obligatoire';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: double.infinity),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 64,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 390),
                      padding: const EdgeInsets.fromLTRB(26, 30, 26, 26),
                      // Carte centrale qui contient soit la connexion, soit l'inscription.
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: EnsiConnectApp.ensisaBlue.withValues(
                            alpha: isDark ? 0.55 : 0.35,
                          ),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: EnsiConnectApp.ensisaBlue.withValues(
                              alpha: isDark ? 0.24 : 0.11,
                            ),
                            blurRadius: 42,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: EnsiConnectApp.ensisaBlue.withValues(
                              alpha: isDark ? 0.12 : 0.06,
                            ),
                            blurRadius: 66,
                            spreadRadius: 11,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0 : 0.08,
                            ),
                            blurRadius: 28,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: _isSignUp ? _buildSignUpForm() : _buildLoginForm(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    // Formulaire de connexion avec validation email UHA + mot de passe.
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AuthTitle(
            title: 'Connexion',
            subtitle: 'Entrez vos identifiants.',
          ),
          const SizedBox(height: 26),
          const _FieldLabel('Adresse mail'),
          const SizedBox(height: 7),
          _AuthInput(
            controller: _loginEmailController,
            hintText: 'Entrez votre adresse mail UHA',
            keyboardType: TextInputType.emailAddress,
            validator: _uhaEmailValidator,
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Mot de passe'),
          const SizedBox(height: 7),
          _AuthInput(
            controller: _loginPasswordController,
            hintText: 'Entrez votre mot de passe',
            obscureText: _hidePassword,
            validator: _passwordValidator,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white60
                    : Colors.black45,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _PrimaryButton(
            label: _isLoading ? 'Connexion...' : 'Se connecter',
            onPressed: _isLoading ? null : _login,
          ),
          _InlineAuthError(message: _authErrorMessage),
          const SizedBox(height: 26),
          _AuthSwitch(
            text: 'Pas de compte ?',
            action: 'Inscrivez-vous',
            onPressed: () => setState(() {
              _isSignUp = true;
              _authErrorMessage = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    // Formulaire d'inscription complet avec menus obligatoires.
    return Form(
      key: _signUpFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AuthTitle(
            title: 'Inscription',
            subtitle: 'Créez votre compte EnsiConnect.',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _CompactAuthField(
                  label: 'Nom',
                  hintText: 'Nom',
                  controller: _signUpNomController,
                  validator: (value) => _requiredValidator(value, 'Nom'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactAuthField(
                  label: 'Prénom',
                  hintText: 'Prénom',
                  controller: _signUpPrenomController,
                  validator: (value) => _requiredValidator(value, 'Prénom'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Adresse mail'),
          const SizedBox(height: 7),
          _AuthInput(
            controller: _signUpEmailController,
            hintText: 'Entrez votre adresse mail UHA',
            keyboardType: TextInputType.emailAddress,
            validator: _uhaEmailValidator,
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Mot de passe'),
          const SizedBox(height: 7),
          _AuthInput(
            controller: _signUpPasswordController,
            hintText: 'Entrez votre mot de passe',
            obscureText: _hidePassword,
            validator: _passwordValidator,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white60
                    : Colors.black45,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: _isLoading ? 'Inscription...' : "S'inscrire",
            onPressed: _isLoading ? null : _register,
          ),
          _InlineAuthError(message: _authErrorMessage),
          const SizedBox(height: 24),
          _AuthSwitch(
            text: 'Déjà un compte ?',
            action: 'Connectez-vous',
            onPressed: () => setState(() {
              _isSignUp = false;
              _authErrorMessage = null;
            }),
          ),
        ],
      ),
    );
  }
}

class _AuthTitle extends StatelessWidget {
  const _AuthTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black45;

    return Column(
      children: [
        Center(
          child: Text(
            title,
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            subtitle,
            style: TextStyle(color: secondaryTextColor, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Champ reutilisable pour garder le meme style sur tout l'ecran.
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 14,
      ),
      cursorColor: EnsiConnectApp.ensisaBlue,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 13,
        ),
        errorStyle: const TextStyle(fontSize: 11),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? Colors.black : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE5E8EF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: EnsiConnectApp.ensisaBlue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    );
  }
}

class _CompactAuthField extends StatelessWidget {
  const _CompactAuthField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.validator,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 7),
        _AuthInput(
          controller: controller,
          hintText: hintText,
          validator: validator,
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: EnsiConnectApp.ensisaBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _InlineAuthError extends StatelessWidget {
  const _InlineAuthError({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Text(
          message!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AuthSwitch extends StatelessWidget {
  const _AuthSwitch({
    required this.text,
    required this.action,
    required this.onPressed,
  });

  final String text;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black45,
            fontSize: 12,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: const TextStyle(
              color: EnsiConnectApp.ensisaBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
