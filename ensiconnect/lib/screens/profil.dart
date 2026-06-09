import 'package:flutter/material.dart';

class ProfilWidget {
  final BuildContext context;

  ProfilWidget(this.context);

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: _isDark ? const Color(0xD90A111C) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF248BFF), width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF248BFF).withValues(alpha: 0.08),
          blurRadius: 26,
          spreadRadius: 1,
        ),
      ],
    );
  }

  Widget statCard({required String title, required String value}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isDark ? Colors.white : Colors.black87,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isDark ? const Color(0xFFACB1BC) : Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget profileCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: child,
    );
  }

  Widget sectionTitle(String title, {Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF248BFF),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            _IconTile(icon: icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        color: _isDark
                            ? const Color(0xFFACB1BC)
                            : Colors.black54,
                      )),
                  const SizedBox(height: 5),
                  Text(
                    value.isEmpty ? '-' : value,
                    style: TextStyle(
                      color: _isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(
          color: _isDark
              ? const Color(0xFF243142)
              : const Color(0xFFE2E8F0),
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;

  const _IconTile({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF102033) : const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: const Color(0xFF248BFF)),
    );
  }
}