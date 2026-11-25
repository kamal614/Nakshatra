import 'package:flutter/material.dart';

import 'data.dart';
import 'design.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({
    required this.profile,
    required this.phone,
    required this.onVerified,
    required this.onProfile,
    required this.onSignOut,
    super.key,
  });
  final ConsumerProfile? profile;
  final String? phone;
  final ValueChanged<String> onVerified;
  final ValueChanged<ConsumerProfile> onProfile;
  final VoidCallback onSignOut;

  void openAuth(BuildContext context, {required bool signup}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (_) => AuthPage(
              signup: signup,
              onVerified: onVerified,
              onProfile: onProfile,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const PageStorageKey('account'),
    padding: const EdgeInsets.symmetric(vertical: 30),
    child: PageFrame(
      maxWidth: 670,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('YOUR ACCOUNT', style: caps()),
          const SizedBox(height: 6),
          Text('Profile', style: title(43)),
          const SizedBox(height: 18),
          if (phone == null)
            surface(
              padding: const EdgeInsets.all(23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      backgroundColor: rose,
                      foregroundColor: rust,
                      radius: 24,
                      child: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text('Make it personal', style: title(30)),
                  const SizedBox(height: 8),
                  Text(
                    'Create a profile with your birth details so they’re ready for your consultation.',
                    style: body(15),
                  ),
                  const SizedBox(height: 20),
                  ActionButton(
                    'Create an account',
                    () => openAuth(context, signup: true),
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: 8),
                  ActionButton(
                    'Log in',
                    () => openAuth(context, signup: false),
                    outline: true,
                  ),
                ],
              ),
            )
          else ...[
            surface(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: rose,
                    foregroundColor: rust,
                    radius: 25,
                    child:
                        profile == null
                            ? const Icon(Icons.person_outline_rounded)
                            : Text(
                              profile!.name.characters.first.toUpperCase(),
                              style: body(
                                20,
                                color: rust,
                                weight: FontWeight.w700,
                              ),
                            ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile?.name ?? 'Your account', style: title(26)),
                        const SizedBox(height: 4),
                        Text('+91 $phone', style: body(14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Birth details', style: title(26)),
                  const SizedBox(height: 10),
                  if (profile == null)
                    Text(
                      'Add your date, time and place of birth.',
                      style: body(14),
                    )
                  else ...[
                    _Detail(
                      Icons.calendar_today_outlined,
                      'Date of birth',
                      dateLabel(profile!.birthDate),
                    ),
                    _Detail(
                      Icons.schedule_rounded,
                      'Birth time',
                      profile!.birthTime.format(context),
                    ),
                    _Detail(
                      Icons.place_outlined,
                      'Birthplace',
                      profile!.birthplace,
                    ),
                  ],
                  const SizedBox(height: 15),
                  ActionButton(
                    profile == null ? 'Add birth details' : 'Edit profile',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder:
                              (_) => BirthProfilePage(
                                initial: profile,
                                onSave: onProfile,
                              ),
                        ),
                      );
                    },
                    outline: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Log out'),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _Detail extends StatelessWidget {
  const _Detail(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Icon(icon, color: rust, size: 18),
        const SizedBox(width: 9),
        Expanded(child: Text(label, style: body(13))),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: body(14, color: ink, weight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({
    required this.signup,
    required this.onVerified,
    required this.onProfile,
    super.key,
  });
  final bool signup;
  final ValueChanged<String> onVerified;
  final ValueChanged<ConsumerProfile> onProfile;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final phone = TextEditingController();
  final code = TextEditingController();
  final phoneForm = GlobalKey<FormState>();
  final otpForm = GlobalKey<FormState>();
  bool verifying = false;

  @override
  void dispose() {
    phone.dispose();
    code.dispose();
    super.dispose();
  }

  void requestCode() {
    if (!phoneForm.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // This demo does not send an SMS; the next step accepts the displayed code.
    setState(() => verifying = true);
  }

  void verify() {
    if (!otpForm.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    widget.onVerified(phone.text.trim());
    if (widget.signup) {
      // Replacing the auth route keeps Back from returning to a verified OTP.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder:
              (_) =>
                  BirthProfilePage(onSave: widget.onProfile, onboarding: true),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: ScreenBar(widget.signup ? 'Create account' : 'Log in'),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 24),
      child: PageFrame(
        maxWidth: 520,
        child: surface(
          padding: const EdgeInsets.all(23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(alignment: Alignment.centerLeft, child: Brand()),
              const SizedBox(height: 24),
              Text(
                verifying
                    ? 'Verify your number'
                    : widget.signup
                    ? 'Create your account'
                    : 'Welcome back',
                style: title(35),
              ),
              const SizedBox(height: 9),
              Text(
                verifying
                    ? 'Enter the six-digit code for +91 ${phone.text.trim()}.'
                    : 'Enter your mobile number to continue.',
                style: body(15),
              ),
              const SizedBox(height: 22),
              if (verifying) ...[
                Form(
                  key: otpForm,
                  child: AstroField(
                    'Verification code',
                    code,
                    hint: '000000',
                    icon: Icons.password_rounded,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    validator:
                        (text) =>
                            text?.trim() == '123456'
                                ? null
                                : 'Enter the demo code 123456.',
                  ),
                ),
                Text(
                  'Demo verification code 123456',
                  style: body(13, color: rust, weight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                ActionButton(
                  'Verify and continue',
                  verify,
                  icon: Icons.arrow_forward_rounded,
                ),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          code.clear();
                          verifying = false;
                        });
                      },
                      child: const Text('Change number'),
                    ),
                    TextButton(
                      onPressed: () {
                        code.clear();
                        otpForm.currentState?.reset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Demo code ready. Enter 123456.'),
                          ),
                        );
                      },
                      child: const Text('Resend code'),
                    ),
                  ],
                ),
              ] else ...[
                Form(
                  key: phoneForm,
                  child: AstroField(
                    'Mobile number (+91)',
                    phone,
                    hint: '10-digit mobile number',
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    autofillHints: const [
                      AutofillHints.telephoneNumberNational,
                    ],
                    validator:
                        (text) =>
                            RegExp(r'^\d{10}$').hasMatch(text?.trim() ?? '')
                                ? null
                                : 'Enter a 10-digit mobile number.',
                  ),
                ),
                ActionButton(
                  'Continue with OTP',
                  requestCode,
                  icon: Icons.arrow_forward_rounded,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class BirthProfilePage extends StatefulWidget {
  const BirthProfilePage({
    this.initial,
    this.onboarding = false,
    required this.onSave,
    super.key,
  });
  final ConsumerProfile? initial;
  final bool onboarding;
  final ValueChanged<ConsumerProfile> onSave;

  @override
  State<BirthProfilePage> createState() => _BirthProfilePageState();
}

class _BirthProfilePageState extends State<BirthProfilePage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final date = TextEditingController();
  final time = TextEditingController();
  final place = TextEditingController();
  DateTime? birthDate;
  TimeOfDay? birthTime;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      name.text = initial.name;
      birthDate = initial.birthDate;
      date.text = dateLabel(initial.birthDate);
      birthTime = initial.birthTime;
      place.text = initial.birthplace;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (birthTime != null) time.text = birthTime!.format(context);
  }

  @override
  void dispose() {
    name.dispose();
    date.dispose();
    time.dispose();
    place.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final next = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: birthDate ?? DateTime(1995, 1, 1),
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (next == null || !mounted) return;
    birthDate = next;
    date.text = dateLabel(next);
  }

  Future<void> selectTime() async {
    final next = await showTimePicker(
      context: context,
      initialTime: birthTime ?? const TimeOfDay(hour: 12, minute: 0),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (next == null || !mounted) return;
    birthTime = next;
    time.text = next.format(context);
  }

  void save() {
    if (!form.currentState!.validate()) return;
    widget.onSave(
      ConsumerProfile(
        name: name.text.trim(),
        birthDate: birthDate!,
        birthTime: birthTime!,
        birthplace: place.text.trim(),
      ),
    );
    Navigator.pop(context);
  }

  String? requiredField(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Please complete this field.' : null;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: ScreenBar(widget.onboarding ? 'Set up profile' : 'Edit profile'),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      child: PageFrame(
        maxWidth: 565,
        child: surface(
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Your birth details', style: title(34)),
                const SizedBox(height: 7),
                Text(
                  'Your astrologer uses these details to prepare your birth chart.',
                  style: body(14),
                ),
                const SizedBox(height: 21),
                AstroField(
                  'Full name',
                  name,
                  hint: 'Enter your name',
                  icon: Icons.person_outline_rounded,
                  validator: requiredField,
                ),
                AstroField(
                  'Date of birth',
                  date,
                  hint: 'Select a date',
                  icon: Icons.calendar_today_outlined,
                  validator: requiredField,
                  readOnly: true,
                  onTap: selectDate,
                ),
                AstroField(
                  'Birth time',
                  time,
                  hint: 'Select a time',
                  icon: Icons.schedule_rounded,
                  validator: requiredField,
                  readOnly: true,
                  onTap: selectTime,
                ),
                AstroField(
                  'Birthplace',
                  place,
                  hint: 'City, state or country',
                  icon: Icons.place_outlined,
                  validator: requiredField,
                ),
                const SizedBox(height: 4),
                ActionButton('Save profile', save, icon: Icons.check_rounded),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
