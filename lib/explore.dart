import 'package:flutter/material.dart';

import 'data.dart';
import 'design.dart';
import 'sessions.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({required this.onConsultation, super.key});
  final ValueChanged<SessionRecord> onConsultation;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final scroll = ScrollController();
  final search = TextEditingController();
  final listings = GlobalKey();
  String category = 'All';
  bool availableOnly = false;
  String sort = 'Recommended';

  static const categories = {
    'All': Icons.auto_awesome_outlined,
    'Vedic': Icons.wb_sunny_outlined,
    'Tarot': Icons.style_outlined,
    'Numerology': Icons.tag_rounded,
    'Relationships': Icons.favorite_border_rounded,
    'Career': Icons.work_outline_rounded,
  };

  @override
  void dispose() {
    scroll.dispose();
    search.dispose();
    super.dispose();
  }

  List<Astrologer> get results {
    // Apply all filters before sorting so the counts reflect the visible list.
    final query = search.text.trim().toLowerCase();
    final matches =
        astrologers.where((a) {
          final searchable =
              '${a.name} ${a.expertise.join(' ')} ${a.languages}'.toLowerCase();
          return (category == 'All' || a.expertise.contains(category)) &&
              (!availableOnly || a.available) &&
              searchable.contains(query);
        }).toList();
    if (sort == 'Lowest price') {
      matches.sort((a, b) => a.price.compareTo(b.price));
    }
    if (sort == 'Top rated') {
      matches.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return matches;
  }

  void reset() {
    setState(() {
      category = 'All';
      availableOnly = false;
      sort = 'Recommended';
      search.clear();
    });
  }

  Future<void> showFilters() async {
    // Keep edits local to the sheet until the user explicitly applies them.
    var draftAvailability = availableOnly;
    var draftSort = sort;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: paper,
      builder:
          (sheetContext) => StatefulBuilder(
            builder:
                (context, setSheetState) => SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(23, 0, 23, 23),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Filter astrologers', style: title(29)),
                        const SizedBox(height: 13),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Online now'),
                          subtitle: const Text(
                            'Show astrologers available to consult',
                          ),
                          value: draftAvailability,
                          onChanged:
                              (value) => setSheetState(
                                () => draftAvailability = value,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sort by',
                          style: body(13, color: ink, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 5,
                          children: [
                            for (final option in [
                              'Recommended',
                              'Lowest price',
                              'Top rated',
                            ])
                              ChoiceChip(
                                label: Text(option),
                                selected: draftSort == option,
                                onSelected:
                                    (_) =>
                                        setSheetState(() => draftSort = option),
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        ActionButton(
                          'Apply filters',
                          () => Navigator.pop(sheetContext, true),
                          icon: Icons.arrow_forward_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
    if (applied == true && mounted) {
      setState(() {
        availableOnly = draftAvailability;
        sort = draftSort;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final matches = results;
    final online = matches.where((a) => a.available).length;
    return SingleChildScrollView(
      key: const PageStorageKey('explore'),
      controller: scroll,
      child: PageFrame(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 680;
            final count =
                constraints.maxWidth >= 1020
                    ? 4
                    : wide
                    ? 2
                    : 1;
            final cardWidth = (constraints.maxWidth - (count - 1) * 15) / count;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: wide ? 30 : 13),
                _ExploreHero(
                  wide: wide,
                  onBrowse: () {
                    final target = listings.currentContext;
                    if (target != null) {
                      Scrollable.ensureVisible(
                        target,
                        duration: const Duration(milliseconds: 330),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                ),
                SizedBox(height: wide ? 32 : 25),
                Row(
                  key: listings,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FIND YOUR GUIDE', style: caps()),
                          const SizedBox(height: 5),
                          Text(
                            'Explore astrologers',
                            style: title(wide ? 38 : 33),
                          ),
                        ],
                      ),
                    ),
                    if (wide && online > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: StatusPill('$online online now'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: search,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search by name or specialty',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: muted,
                            size: 21,
                          ),
                          suffixIcon:
                              search.text.isEmpty
                                  ? null
                                  : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () => setState(search.clear),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    SizedBox(
                      height: 51,
                      child: OutlinedButton(
                        onPressed: showFilters,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ink,
                          backgroundColor: paper,
                          padding: EdgeInsets.symmetric(
                            horizontal: wide ? 16 : 13,
                          ),
                          side: const BorderSide(color: border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 19,
                              semanticLabel: wide ? null : 'Filters',
                            ),
                            if (wide) ...[
                              const SizedBox(width: 7),
                              const Text('Filters'),
                            ],
                            if (availableOnly || sort != 'Recommended')
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(Icons.circle, color: rust, size: 7),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final entry in categories.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _Category(
                            label: entry.key,
                            icon: entry.value,
                            selected: category == entry.key,
                            onTap: () => setState(() => category = entry.key),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${matches.length} astrologer${matches.length == 1 ? '' : 's'}',
                        style: body(13, weight: FontWeight.w600),
                      ),
                    ),
                    if (!wide && online > 0) StatusPill('$online online now'),
                  ],
                ),
                const SizedBox(height: 9),
                if (matches.isEmpty)
                  EmptyPanel(
                    icon: Icons.search_off_rounded,
                    heading: 'No matches found',
                    description: 'Try a different name, specialty or filter.',
                    action: ActionButton('Clear filters', reset, outline: true),
                  )
                else
                  Wrap(
                    spacing: 15,
                    runSpacing: 13,
                    children: [
                      for (final astrologer in matches)
                        SizedBox(
                          width: cardWidth,
                          child: _AstrologerCard(
                            astrologer,
                            horizontal: count == 1,
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder:
                                        (_) => AstrologerPage(
                                          astrologer,
                                          onConsultation: widget.onConsultation,
                                        ),
                                  ),
                                ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 26),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExploreHero extends StatelessWidget {
  const _ExploreHero({required this.wide, required this.onBrowse});
  final bool wide;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(wide ? 24 : 21),
    child: Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: const Color(0xFF25132D),
            child: Align(
              alignment: wide ? Alignment.centerRight : Alignment.bottomRight,
              child: FractionallySizedBox(
                widthFactor: wide ? .65 : .96,
                heightFactor: 1,
                child: Image.asset(
                  'assets/images/zodiac.webp',
                  fit: BoxFit.cover,
                  alignment:
                      wide
                          ? const Alignment(0.6, 0.05)
                          : const Alignment(.25, -.14),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors:
                    wide
                        ? const [
                          Color(0xFF25132D),
                          Color(0xFF25132D),
                          Color(0x1825132D),
                          Color(0x0025132D),
                        ]
                        : const [
                          Color(0xFF25132D),
                          Color(0xDA25132D),
                          Color(0x3825132D),
                        ],
                stops: wide ? const [0, .36, .68, 1] : const [0, .49, 1],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            wide ? 42 : 22,
            wide ? 29 : 24,
            wide ? 38 : 20,
            wide ? 30 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: orange),
                  const SizedBox(width: 8),
                  Text(
                    'PERSONAL ASTROLOGY',
                    style: caps(color: const Color(0xFFF5AE82)),
                  ),
                ],
              ),
              SizedBox(height: wide ? 10 : 11),
              Text(
                'A little clarity\nfrom the stars.',
                style: title(
                  wide ? 61 : 39,
                  color: const Color(0xFFFFF5E8),
                  height: 1.01,
                ),
              ),
              const SizedBox(height: 13),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 357 : 254),
                child: Text(
                  'Find an astrologer and connect by chat, voice or video.',
                  style: body(wide ? 16 : 14, color: const Color(0xFFE6D5DF)),
                ),
              ),
              SizedBox(height: wide ? 22 : 17),
              ActionButton(
                'Browse astrologers',
                onBrowse,
                light: true,
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Category extends StatelessWidget {
  const _Category({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FilterChip(
    showCheckmark: false,
    selected: selected,
    onSelected: (_) => onTap(),
    avatar: Icon(icon, size: 15, color: selected ? Colors.white : rust),
    label: Text(
      label,
      style: body(
        13,
        color: selected ? Colors.white : ink,
        weight: FontWeight.w600,
      ),
    ),
    backgroundColor: paper,
    selectedColor: plum,
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
    side: BorderSide(color: selected ? plum : border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );
}

class _AstrologerCard extends StatelessWidget {
  const _AstrologerCard(
    this.astrologer, {
    required this.onTap,
    required this.horizontal,
  });
  final Astrologer astrologer;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final status = StatusPill(
      astrologer.available ? 'Online' : 'Offline',
      active: astrologer.available,
    );
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(astrologer.name, style: title(horizontal ? 22 : 24)),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.verified_rounded,
              color: rust,
              size: 15,
              semanticLabel: 'Verified astrologer',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(astrologer.expertise.join('  ·  '), style: body(13)),
      ],
    );
    return Material(
      color: paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (horizontal)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Portrait(astrologer, size: 58, radius: 12),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, right: 3),
                        child: identity,
                      ),
                    ),
                    status,
                  ],
                )
              else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Portrait(astrologer, size: 70),
                    const Spacer(),
                    status,
                  ],
                ),
                const SizedBox(height: 11),
                identity,
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: rust, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    astrologer.rating.toStringAsFixed(1),
                    style: body(13, color: ink, weight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  Text('(${astrologer.reviews})', style: body(12)),
                  const SizedBox(width: 9),
                  Text('·  ${astrologer.experience} yrs exp.', style: body(12)),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: border),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '₹${astrologer.price}',
                            style: body(
                              18,
                              color: ink,
                              weight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: ' / min', style: body(12)),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'View profile',
                    style: body(13, color: rust, weight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 16,
                    color: rust,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AstrologerPage extends StatelessWidget {
  const AstrologerPage(
    this.astrologer, {
    required this.onConsultation,
    super.key,
  });
  final Astrologer astrologer;
  final ValueChanged<SessionRecord> onConsultation;

  void chooseMethod(BuildContext context, Method method) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: paper,
      builder:
          (sheetContext) => SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(23, 0, 23, 23),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Start a ${method.label.toLowerCase()}',
                    style: title(29),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Consult with ${astrologer.name} for ₹${astrologer.rate(method)} per minute.',
                    style: body(15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is a demo session. You won’t be charged.',
                    style: body(13),
                  ),
                  const SizedBox(height: 23),
                  ActionButton('Request consultation', () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder:
                            (_) => ConsultationPage(
                              astrologer,
                              method,
                              onRecorded: onConsultation,
                            ),
                      ),
                    );
                  }, icon: Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const ScreenBar('Astrologer profile'),
    body: SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 25),
      child: PageFrame(
        maxWidth: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Portrait(astrologer, size: 100, radius: 22),
                  const SizedBox(height: 11),
                  Text(
                    astrologer.name,
                    style: title(37),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(astrologer.expertise.join('  ·  '), style: body(15)),
                  const SizedBox(height: 10),
                  StatusPill(
                    astrologer.available
                        ? 'Available now'
                        : 'Currently offline',
                    active: astrologer.available,
                  ),
                  const SizedBox(height: 17),
                  const Divider(height: 1, color: border),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _ProfileMetric(
                        Icons.star_rounded,
                        astrologer.rating.toStringAsFixed(1),
                        '${astrologer.reviews} reviews',
                      ),
                      _ProfileMetric(
                        Icons.auto_awesome_outlined,
                        '${astrologer.experience} years',
                        'Experience',
                      ),
                      _ProfileMetric(
                        Icons.translate_rounded,
                        '${astrologer.languages.split(', ').length}',
                        'Languages',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('About', style: title(27)),
            const SizedBox(height: 7),
            Text(astrologer.bio, style: body(15)),
            const SizedBox(height: 10),
            Text(
              astrologer.languages,
              style: body(13, color: rust, weight: FontWeight.w700),
            ),
            const SizedBox(height: 22),
            Text('Choose a consultation', style: title(27)),
            const SizedBox(height: 7),
            if (!astrologer.available)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Check back when ${astrologer.name.split(' ').first} is online.',
                  style: body(14),
                ),
              ),
            for (final method in Method.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: surface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  radius: 13,
                  child: ListTile(
                    enabled: astrologer.available,
                    leading: CircleAvatar(
                      backgroundColor: rose,
                      foregroundColor: rust,
                      child: Icon(method.icon, size: 19),
                    ),
                    title: Text(
                      method.label,
                      style: body(
                        15,
                        color: astrologer.available ? ink : muted,
                        weight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '₹${astrologer.rate(method)} / min',
                      style: body(13),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap:
                        astrologer.available
                            ? () => chooseMethod(context, method)
                            : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: rust, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: body(15, color: ink, weight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        Text(label, style: body(12), textAlign: TextAlign.center),
      ],
    ),
  );
}
