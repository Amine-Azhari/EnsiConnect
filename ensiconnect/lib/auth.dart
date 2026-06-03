import 'package:flutter/material.dart';

import 'main.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _filieres = const ['CPB1', 'CPB2', 'IR', 'ASE', 'GI', 'Textile'];
  final _annees = const ['CPB1', 'CPB2', '1A', '2A', '3A'];

  bool _isSignUp = false;
  bool _hidePassword = true;
  String? _selectedFiliere;
  String? _selectedAnnee;

  void _submit(GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushReplacementNamed('/home');
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

    if (email.isEmpty) {
      return 'Adresse mail obligatoire';
    }

    if (!email.endsWith('@uha.fr')) {
      return "Utilisez une adresse mail de l'UHA (@uha.fr)";
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Mot de passe obligatoire';
    }

    if (password.length < 6) {
      return 'Minimum 6 caractères';
    }

    if (!RegExp('[A-Za-z]').hasMatch(password)) {
      return 'Ajoutez au moins une lettre';
    }

    if (!RegExp('[0-9]').hasMatch(password)) {
      return 'Ajoutez au moins un chiffre';
    }

    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Ajoutez au moins un caractère spécial';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
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
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 390),
                  padding: const EdgeInsets.fromLTRB(26, 30, 26, 26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: _isSignUp ? _buildSignUpForm() : _buildLoginForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
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
            hintText: 'Entrez votre adresse mail UHA',
            keyboardType: TextInputType.emailAddress,
            validator: _uhaEmailValidator,
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Mot de passe'),
          const SizedBox(height: 7),
          _AuthInput(
            hintText: 'Entrez votre mot de passe',
            obscureText: _hidePassword,
            validator: _passwordValidator,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black45,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  color: EnsiConnectApp.ensisaBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _PrimaryButton(
            label: 'Se connecter',
            onPressed: () => _submit(_loginFormKey),
          ),
          const SizedBox(height: 26),
          _AuthSwitch(
            text: 'Pas de compte ?',
            action: 'Inscrivez-vous',
            onPressed: () => setState(() => _isSignUp = true),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
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
          const _FieldLabel('Nom'),
          const SizedBox(height: 7),
          _AuthInput(
            hintText: 'Entrez votre nom',
            validator: (value) => _requiredValidator(value, 'Nom'),
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Prénom'),
          const SizedBox(height: 7),
          _AuthInput(
            hintText: 'Entrez votre prénom',
            validator: (value) => _requiredValidator(value, 'Prénom'),
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Adresse mail'),
          const SizedBox(height: 7),
          _AuthInput(
            hintText: 'Entrez votre adresse mail UHA',
            keyboardType: TextInputType.emailAddress,
            validator: _uhaEmailValidator,
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Mot de passe'),
          const SizedBox(height: 7),
          _AuthInput(
            hintText: 'Minimum 6 caractères',
            obscureText: _hidePassword,
            validator: _passwordValidator,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black45,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Filière'),
          const SizedBox(height: 7),
          _AuthDropdown(
            hintText: 'Choisissez votre filière',
            value: _selectedFiliere,
            items: _filieres,
            onChanged: (value) => setState(() => _selectedFiliere = value),
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Année'),
          const SizedBox(height: 7),
          _AuthDropdown(
            hintText: 'Choisissez votre année',
            value: _selectedAnnee,
            items: _annees,
            onChanged: (value) => setState(() => _selectedAnnee = value),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: "S'inscrire",
            onPressed: () => _submit(_signUpFormKey),
          ),
          const SizedBox(height: 24),
          _AuthSwitch(
            text: 'Déjà un compte ?',
            action: 'Connectez-vous',
            onPressed: () => setState(() => _isSignUp = false),
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
    return Column(
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.black45, fontSize: 13),
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
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      cursorColor: EnsiConnectApp.ensisaBlue,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
        errorStyle: const TextStyle(fontSize: 11),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFFE5E8EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide:
              const BorderSide(color: EnsiConnectApp.ensisaBlue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    );
  }
}

class _AuthDropdown extends StatelessWidget {
  const _AuthDropdown({
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hintText;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Champ obligatoire' : null,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      dropdownColor: Colors.white,
      iconEnabledColor: Colors.black54,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
        errorStyle: const TextStyle(fontSize: 11),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFFE5E8EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide:
              const BorderSide(color: EnsiConnectApp.ensisaBlue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5D6DF5),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(color: Colors.black45, fontSize: 12),
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