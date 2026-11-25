import 'package:flutter/material.dart';

const canvas = Color(0xFFF9F6F0);
const paper = Color(0xFFFFFDFC);
const ink = Color(0xFF28192C);
const muted = Color(0xFF6E6069);
const border = Color(0xFFE9E0D7);
const rust = Color(0xFFAA472E);
const orange = Color(0xFFEE9A65);
const plum = Color(0xFF2A1731);
const green = Color(0xFF35664C);
const sage = Color(0xFFE7F1E9);
const rose = Color(0xFFF9EDE6);

TextStyle title(double size, {Color color = ink, double height = 1.08}) =>
    TextStyle(
      fontFamily: 'Playfair',
      color: color,
      fontSize: size,
      height: height,
      fontWeight: FontWeight.w600,
      letterSpacing: -size * .037,
    );

TextStyle body(
  double size, {
  Color color = muted,
  FontWeight weight = FontWeight.w400,
}) => TextStyle(color: color, fontSize: size, fontWeight: weight, height: 1.45);

TextStyle caps({Color color = rust}) => TextStyle(
  fontSize: 11,
  color: color,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.7,
  height: 1.35,
);

/// Shared card surface with a Material ancestor for visible ink effects.
Widget surface({
  required Widget child,
  EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  Color color = paper,
  double radius = 19,
}) => Material(
  color: color,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
    side: const BorderSide(color: border),
  ),
  clipBehavior: Clip.antiAlias,
  child: Padding(padding: padding, child: child),
);

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: plum,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.auto_awesome_rounded, size: 18, color: orange),
      ),
      const SizedBox(width: 10),
      Text('nakshatra', style: title(25)),
      Text('.', style: title(25, color: rust)),
    ],
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {this.active = true, super.key});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: active ? sage : const Color(0xFFF1EAE5),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? green : muted,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: body(
            11,
            color: active ? green : muted,
            weight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class ActionButton extends StatelessWidget {
  const ActionButton(
    this.label,
    this.onPressed, {
    this.icon,
    this.light = false,
    this.outline = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool light;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 17, vertical: 13),
      ),
      textStyle: WidgetStatePropertyAll(body(14, weight: FontWeight.w700)),
      minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
    );
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(label, textAlign: TextAlign.center)),
        if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 17)],
      ],
    );
    if (outline) {
      return OutlinedButton(
        onPressed: onPressed,
        style: style.copyWith(
          foregroundColor: const WidgetStatePropertyAll(plum),
          side: const WidgetStatePropertyAll(BorderSide(color: border)),
        ),
        child: child,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: style.copyWith(
        backgroundColor:
            onPressed == null
                ? null
                : WidgetStatePropertyAll(
                  light ? const Color(0xFFF4A777) : plum,
                ),
        foregroundColor:
            onPressed == null
                ? null
                : WidgetStatePropertyAll(light ? ink : Colors.white),
      ),
      child: child,
    );
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({required this.child, this.maxWidth = 1170, super.key});
  final Widget child;
  final double maxWidth;
  @override
  // Constrain content on large screens while keeping phone gutters consistent.
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width >= 760 ? 36 : 19,
        ),
        child: child,
      ),
    ),
  );
}

class ScreenBar extends StatelessWidget implements PreferredSizeWidget {
  const ScreenBar(this.label, {super.key});
  final String label;
  @override
  Size get preferredSize => const Size.fromHeight(66);
  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(label, style: body(16, color: ink, weight: FontWeight.w700)),
    backgroundColor: canvas,
    scrolledUnderElevation: 0,
    centerTitle: true,
    toolbarHeight: 66,
  );
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({
    required this.icon,
    required this.heading,
    required this.description,
    this.action,
    super.key,
  });
  final IconData icon;
  final String heading;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => surface(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CircleAvatar(
          backgroundColor: rose,
          foregroundColor: rust,
          radius: 25,
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 15),
        Text(heading, textAlign: TextAlign.center, style: title(27)),
        const SizedBox(height: 8),
        Text(description, textAlign: TextAlign.center, style: body(14)),
        if (action != null) ...[
          const SizedBox(height: 20),
          Center(child: action),
        ],
      ],
    ),
  );
}

class AstroField extends StatelessWidget {
  const AstroField(
    this.label,
    this.controller, {
    this.icon,
    this.hint,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
    this.maxLength,
    this.autofillHints,
    super.key,
  });
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: body(13, color: ink, weight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          maxLength: maxLength,
          autofillHints: autofillHints,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 18, color: rust),
            counterText: '',
          ),
        ),
      ],
    ),
  );
}

String dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String durationLabel(Duration duration) {
  final minutes = duration.inMinutes.toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
