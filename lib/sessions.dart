import 'dart:async';

import 'package:flutter/material.dart';

import 'data.dart';
import 'design.dart';

// The demo models the consultation lifecycle locally; no network is involved.
enum _Phase { waiting, active, disconnected, complete }

class ConsultationPage extends StatefulWidget {
  const ConsultationPage(
    this.astrologer,
    this.method, {
    required this.onRecorded,
    super.key,
  });
  final Astrologer astrologer;
  final Method method;
  final ValueChanged<SessionRecord> onRecorded;

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final stopwatch = Stopwatch();
  final message = TextEditingController();
  final messagesScroll = ScrollController();
  final messages = <({String text, DateTime time, bool mine})>[];
  Timer? transition;
  Timer? clock;
  Timer? reply;
  _Phase phase = _Phase.waiting;
  bool dialogOpen = false;
  bool micMuted = false;
  bool camera = true;
  bool speaker = false;
  bool wasConnected = false;
  bool endedOffline = false;
  int replyIndex = 0;

  Astrologer get astrologer => widget.astrologer;
  Method get method => widget.method;
  String get firstName => astrologer.name.split(' ').first;

  @override
  void initState() {
    super.initState();
    connect();
  }

  @override
  void dispose() {
    transition?.cancel();
    clock?.cancel();
    reply?.cancel();
    stopwatch.stop();
    message.dispose();
    messagesScroll.dispose();
    super.dispose();
  }

  void connect() {
    // Simulate an astrologer accepting the request, or a successful reconnect.
    transition = Timer(const Duration(milliseconds: 2200), () {
      setState(() {
        if (!wasConnected && method == Method.chat) {
          messages.add((
            text: 'Hi, I’m $firstName. What would you like to explore today?',
            time: DateTime.now(),
            mine: false,
          ));
        }
        wasConnected = true;
        phase = _Phase.active;
        stopwatch.start();
      });
      // Stopwatch measures elapsed time; this timer only refreshes the display.
      clock = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {}),
      );
    });
  }

  void disconnect() {
    transition?.cancel();
    clock?.cancel();
    reply?.cancel();
    // Pausing the stopwatch excludes disconnected time from the session total.
    stopwatch.stop();
    setState(() => phase = _Phase.disconnected);
  }

  void retry() {
    setState(() => phase = _Phase.waiting);
    connect();
  }

  void finish() {
    transition?.cancel();
    clock?.cancel();
    reply?.cancel();
    stopwatch.stop();
    FocusScope.of(context).unfocus();
    // Cancelled requests never became consultations and have no history entry.
    if (!wasConnected) {
      Navigator.pop(context);
      return;
    }
    endedOffline = phase != _Phase.active;
    widget.onRecorded(
      SessionRecord(
        astrologer: astrologer,
        method: method,
        duration: stopwatch.elapsed,
        date: DateTime.now(),
        disconnected: endedOffline,
      ),
    );
    setState(() => phase = _Phase.complete);
  }

  Future<void> askToEnd() async {
    if (dialogOpen || phase == _Phase.complete) return;
    dialogOpen = true;
    final end = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: paper,
            title: Text(
              wasConnected ? 'End consultation?' : 'Cancel request?',
              style: title(27),
            ),
            content: Text(
              wasConnected
                  ? 'Your session details will appear in Sessions.'
                  : 'You can start a new consultation anytime.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(wasConnected ? 'Stay in session' : 'Keep waiting'),
              ),
              ActionButton(
                wasConnected ? 'End session' : 'Cancel request',
                () => Navigator.pop(dialogContext, true),
              ),
            ],
          ),
    );
    dialogOpen = false;
    if (mounted && end == true) finish();
  }

  void scrollToLatest() {
    // Wait for the new message bubble to be laid out before reading the extent.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && messagesScroll.hasClients) {
        messagesScroll.animateTo(
          messagesScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 210),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void send() {
    final text = message.text.trim();
    if (text.isEmpty || phase != _Phase.active) return;
    setState(() {
      messages.add((text: text, time: DateTime.now(), mine: true));
      message.clear();
    });
    scrollToLatest();
    // Replies are scripted demo content, not messages from a remote astrologer.
    reply?.cancel();
    reply = Timer(const Duration(milliseconds: 1150), () {
      const replies = [
        'Thank you for sharing. Is there a particular question you’d like to start with?',
        'That’s helpful context. We can explore that topic together in your reading.',
        'Let’s spend some time on what feels most important to you right now.',
      ];
      setState(() {
        messages.add((
          text: replies[replyIndex++ % replies.length],
          time: DateTime.now(),
          mine: false,
        ));
      });
      scrollToLatest();
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = phase == _Phase.active;
    final isCalling = active && method != Method.chat;
    return PopScope(
      canPop: phase == _Phase.complete,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) askToEnd();
      },
      child: Scaffold(
        backgroundColor: isCalling ? plum : canvas,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: isCalling ? plum : canvas,
          foregroundColor: isCalling ? Colors.white : ink,
          scrolledUnderElevation: 0,
          title: Text(
            method.label,
            style: body(
              16,
              color: isCalling ? Colors.white : ink,
              weight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            tooltip: phase == _Phase.complete ? 'Back' : 'Close consultation',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (phase == _Phase.complete) {
                Navigator.pop(context);
              } else {
                askToEnd();
              }
            },
          ),
          actions: [
            if (phase == _Phase.active || phase == _Phase.waiting)
              PopupMenuButton<String>(
                tooltip: 'Demo options',
                onSelected: (_) => disconnect(),
                itemBuilder:
                    (_) => [
                      const PopupMenuItem(
                        value: 'disconnect',
                        child: Text('Simulate disconnection'),
                      ),
                    ],
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: switch (phase) {
            _Phase.waiting => statusScreen(waiting: true),
            _Phase.disconnected => statusScreen(waiting: false),
            _Phase.active =>
              method == Method.chat ? chatScreen() : callScreen(),
            _Phase.complete => summaryScreen(),
          },
        ),
      ),
    );
  }

  Widget statusScreen({required bool waiting}) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: PageFrame(
        maxWidth: 510,
        child: surface(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Portrait(astrologer, size: 96, radius: 23)),
              const SizedBox(height: 15),
              if (waiting)
                const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                const Icon(Icons.wifi_off_rounded, color: rust, size: 24),
              const SizedBox(height: 12),
              Text(
                waiting
                    ? (wasConnected
                        ? 'Reconnecting…'
                        : 'Waiting for $firstName')
                    : 'Connection lost',
                style: title(32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                waiting
                    ? (wasConnected
                        ? 'Restoring your ${method.label.toLowerCase()}.'
                        : '${astrologer.name} is reviewing your ${method.label.toLowerCase()} request.')
                    : 'Your consultation is paused. Try reconnecting to continue.',
                style: body(15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 23),
              if (!waiting) ...[
                ActionButton('Try again', retry, icon: Icons.refresh_rounded),
                const SizedBox(height: 8),
              ],
              ActionButton(
                wasConnected ? 'End session' : 'Cancel request',
                askToEnd,
                outline: true,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget chatScreen() => PageFrame(
    maxWidth: 760,
    child: Column(
      children: [
        surface(
          padding: const EdgeInsets.all(11),
          radius: 14,
          child: Row(
            children: [
              Portrait(astrologer, size: 42, radius: 9),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      astrologer.name,
                      style: body(15, color: ink, weight: FontWeight.w700),
                    ),
                    Text('Online', style: body(12, color: green)),
                  ],
                ),
              ),
              _Elapsed(stopwatch.elapsed),
              const SizedBox(width: 5),
              IconButton(
                tooltip: 'End chat',
                onPressed: askToEnd,
                icon: const Icon(Icons.call_end_rounded, color: rust),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: messagesScroll,
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Center(child: Text('DEMO CONSULTATION', style: caps())),
              const SizedBox(height: 17),
              for (final item in messages)
                _ChatBubble(text: item.text, sent: item.mine, time: item.time),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: message,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => send(),
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    hintText: 'Write a message…',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Send message',
                onPressed: message.text.trim().isEmpty ? null : send,
                style: IconButton.styleFrom(
                  backgroundColor: plum,
                  minimumSize: const Size(49, 49),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget callScreen() {
    final video = method == Method.video;
    return PageFrame(
      maxWidth: 660,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 580;
          return Column(
            children: [
              const SizedBox(height: 7),
              Text(
                'DEMO ${method.label.toUpperCase()}',
                style: caps(color: orange),
              ),
              const SizedBox(height: 9),
              _Elapsed(stopwatch.elapsed, dark: true),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    color: const Color(0xFF39223F),
                  ),
                  width: double.infinity,
                  child:
                      video
                          ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/${astrologer.image}.webp',
                                fit: BoxFit.cover,
                                alignment: const Alignment(0, -.19),
                              ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Color(0xB529182D),
                                    ],
                                    stops: [.62, 1],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 13,
                                left: 15,
                                right: 105,
                                child: Text(
                                  astrologer.name,
                                  style: body(
                                    16,
                                    color: Colors.white,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  width: 77,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF342039),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        camera
                                            ? Icons.person_outline_rounded
                                            : Icons.videocam_off_outlined,
                                        color: orange,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        camera ? 'You' : 'Camera off',
                                        style: body(11, color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF925D67),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(compact ? 5 : 10),
                                    child: Portrait(
                                      astrologer,
                                      size: compact ? 78 : 126,
                                      radius: 90,
                                    ),
                                  ),
                                  const SizedBox(height: 11),
                                  Text(
                                    astrologer.name,
                                    textAlign: TextAlign.center,
                                    style: title(
                                      compact ? 24 : 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Connected',
                                    style: body(
                                      13,
                                      color: const Color(0xFFE4CCD8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                ),
              ),
              SizedBox(height: compact ? 11 : 17),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CallControl(
                    micMuted ? 'Unmute' : 'Mute',
                    micMuted ? Icons.mic_off_outlined : Icons.mic_none_rounded,
                    () => setState(() => micMuted = !micMuted),
                    selected: micMuted,
                  ),
                  if (video)
                    _CallControl(
                      camera ? 'Camera off' : 'Camera on',
                      camera
                          ? Icons.videocam_outlined
                          : Icons.videocam_off_outlined,
                      () => setState(() => camera = !camera),
                      selected: !camera,
                    )
                  else
                    _CallControl(
                      'Speaker',
                      speaker
                          ? Icons.volume_up_rounded
                          : Icons.volume_down_outlined,
                      () => setState(() => speaker = !speaker),
                      selected: speaker,
                    ),
                  _CallControl(
                    'End call',
                    Icons.call_end_rounded,
                    askToEnd,
                    destructive: true,
                  ),
                ],
              ),
              SizedBox(height: compact ? 10 : 17),
            ],
          );
        },
      ),
    );
  }

  Widget summaryScreen() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: PageFrame(
        maxWidth: 540,
        child: surface(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: sage,
                  foregroundColor: green,
                  child: Icon(Icons.check_rounded, size: 29),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                endedOffline
                    ? 'Consultation disconnected'
                    : 'Consultation complete',
                textAlign: TextAlign.center,
                style: title(35),
              ),
              const SizedBox(height: 9),
              Text(
                '${method.label} with ${astrologer.name}',
                textAlign: TextAlign.center,
                style: body(15),
              ),
              const SizedBox(height: 17),
              const Divider(height: 1, color: border),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(child: Text('Session duration', style: body(14))),
                  Text(
                    durationLabel(stopwatch.elapsed),
                    style: body(16, color: ink, weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Saved to your session history.', style: body(13)),
              const SizedBox(height: 20),
              ActionButton(
                'Done',
                () => Navigator.pop(context),
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Elapsed extends StatelessWidget {
  const _Elapsed(this.duration, {this.dark = false});
  final Duration duration;
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: dark ? const Color(0xFF503450) : rose,
      borderRadius: BorderRadius.circular(25),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: 15, color: dark ? orange : rust),
        const SizedBox(width: 4),
        Text(
          durationLabel(duration),
          style: body(
            13,
            color: dark ? Colors.white : ink,
            weight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.text,
    required this.sent,
    required this.time,
  });
  final String text;
  final bool sent;
  final DateTime time;

  @override
  Widget build(BuildContext context) => Align(
    alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: FractionallySizedBox(
        widthFactor: .86,
        alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              sent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sent ? plum : paper,
                border: Border.all(color: sent ? plum : border),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                text,
                style: body(15, color: sent ? Colors.white : ink),
              ),
            ),
            Text(TimeOfDay.fromDateTime(time).format(context), style: body(11)),
            const SizedBox(height: 11),
          ],
        ),
      ),
    ),
  );
}

class _CallControl extends StatelessWidget {
  const _CallControl(
    this.label,
    this.icon,
    this.onPressed, {
    this.selected = false,
    this.destructive = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      IconButton.filled(
        onPressed: onPressed,
        tooltip: label,
        style: IconButton.styleFrom(
          backgroundColor:
              destructive
                  ? const Color(0xFFB73946)
                  : selected
                  ? orange
                  : const Color(0xFF4F3455),
          foregroundColor: selected ? ink : Colors.white,
          minimumSize: const Size(51, 51),
        ),
        icon: Icon(icon, size: 24),
      ),
      const SizedBox(height: 5),
      Text(label, style: body(12, color: Colors.white)),
    ],
  );
}

class HistoryPage extends StatefulWidget {
  const HistoryPage(this.sessions, {required this.onExplore, super.key});
  final List<SessionRecord> sessions;
  final VoidCallback onExplore;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Method? method;

  void openRecord(SessionRecord record) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: paper,
      builder:
          (context) => SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(23, 0, 23, 23),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(record.astrologer.name, style: title(30)),
                  const SizedBox(height: 7),
                  Text(
                    '${record.method.label}  ·  ${dateLabel(record.date)}',
                    style: body(15),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'Duration  ${durationLabel(record.duration)}',
                    style: body(14, color: ink, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    record.disconnected ? 'Disconnected' : 'Completed',
                    style: body(14, color: record.disconnected ? rust : green),
                  ),
                  const SizedBox(height: 16),
                  ActionButton(
                    'Close',
                    () => Navigator.pop(context),
                    outline: true,
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = widget.sessions.where(
      (item) => method == null || item.method == method,
    );
    return SingleChildScrollView(
      key: const PageStorageKey('history'),
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: PageFrame(
        maxWidth: 810,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('YOUR CONSULTATIONS', style: caps()),
            const SizedBox(height: 6),
            Text('Sessions', style: title(43)),
            const SizedBox(height: 17),
            if (widget.sessions.isNotEmpty) ...[
              Wrap(
                spacing: 7,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: method == null,
                    onSelected: (_) => setState(() => method = null),
                  ),
                  for (final option in Method.values)
                    ChoiceChip(
                      label: Text(option.label),
                      selected: method == option,
                      onSelected: (_) => setState(() => method = option),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (sessions.isEmpty)
              EmptyPanel(
                icon: Icons.history_rounded,
                heading:
                    widget.sessions.isEmpty
                        ? 'No sessions yet'
                        : 'No sessions of this type',
                description:
                    widget.sessions.isEmpty
                        ? 'Your consultations will appear here after your first session.'
                        : 'Choose another consultation type to see more sessions.',
                action:
                    widget.sessions.isEmpty
                        ? ActionButton(
                          'Explore astrologers',
                          widget.onExplore,
                          icon: Icons.arrow_forward_rounded,
                        )
                        : null,
              )
            else
              for (final record in sessions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: surface(
                    padding: const EdgeInsets.all(2),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 6,
                      ),
                      leading: Portrait(
                        record.astrologer,
                        size: 52,
                        radius: 11,
                      ),
                      title: Text(record.astrologer.name, style: title(22)),
                      subtitle: Text(
                        '${record.method.label}  ·  ${dateLabel(record.date)}',
                        style: body(13),
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            durationLabel(record.duration),
                            style: body(
                              15,
                              color: ink,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            record.disconnected ? 'Disconnected' : 'Completed',
                            style: body(
                              12,
                              color: record.disconnected ? rust : green,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => openRecord(record),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
