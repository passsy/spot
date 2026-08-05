import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('travel planner produces a full interaction timeline', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    timeline.mode = TimelineMode.always;
    await loadAppFonts();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff0d6e8c),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const _TravelPlanner(),
      ),
    );

    spotText('Lisbon, curated').existsOnce();
    spotText('Plan a three-day escape').existsOnce();
    spotText('Sunset cruise').existsOnce();

    await act.tap(spotText('Explore nearby'));
    spotText('18 nearby picks').existsOnce();

    // The animation renders every 16ms frame, but the timeline only captures
    // its visual states at the assertions before and after it. This creates a
    // deliberately visible skipped-frame gap in the report.
    await tester.pumpAndSettle(const Duration(milliseconds: 16));
    spotText('Choose an ocean view').existsOnce();
    spotText('Ocean views').existsOnce();

    await act.tap(spotText('Ocean views'));
    spotText('4 ocean-view picks').existsOnce();
    spotText('Blue hour at Miradouro').existsOnce();

    await act.tap(spotText('Sunset cruise'));
    await tester.pumpAndSettle();
    spotText('Golden hour on the Tagus').existsOnce();
    spotText('Reserve for €24').existsOnce();

    await act.tap(spot<FilledButton>().withChild(spotText('Reserve for €24')));
    await tester.pumpAndSettle();
    spotText('Booked: Sunset cruise').existsOnce();
    spotText('1 experience reserved').existsOnce();

    await act.tap(spot<FilledButton>().withChild(spotText('Save itinerary')));
    await tester.pumpAndSettle();
    spotText('Itinerary saved for your weekend').existsOnce();

    await act.tap(spot<OutlinedButton>().withChild(spotText('View itinerary')));
    await tester.pumpAndSettle();
    spotText('Your Lisbon itinerary').existsOnce();
    spotText('Sunset cruise · confirmed').existsOnce();
  });
}

class _TravelPlanner extends StatefulWidget {
  const _TravelPlanner();

  @override
  State<_TravelPlanner> createState() => _TravelPlannerState();
}

class _TravelPlannerState extends State<_TravelPlanner>
    with SingleTickerProviderStateMixin {
  bool _exploring = false;
  bool _oceanViews = false;
  bool _booked = false;
  bool _saved = false;
  late final AnimationController _exploreAnimation;

  @override
  void initState() {
    super.initState();
    _exploreAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _exploreAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Lisbon, curated',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Plan a three-day escape',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            _HeroCard(
              booked: _booked,
              saved: _saved,
              onSave: () => setState(() => _saved = true),
              onViewItinerary: _openItinerary,
            ),
            const SizedBox(height: 20),
            if (!_exploring) ...[
              Text(
                'Your weekend',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const _PlaceCard(
                title: 'Sunset cruise',
                subtitle: 'Saturday · 19:30 · Tagus river',
                icon: Icons.sailing,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _startExploring,
                icon: const Icon(Icons.explore),
                label: const Text('Explore nearby'),
              ),
            ] else ...[
              Text(
                '18 nearby picks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _exploreAnimation,
                builder: (context, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _exploreAnimation.isCompleted
                          ? 'Choose an ocean view'
                          : 'Finding the best views…',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: _exploreAnimation.value),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilterChip(
                label: const Text('Ocean views'),
                selected: _oceanViews,
                onSelected: (_) => setState(() => _oceanViews = !_oceanViews),
              ),
              const SizedBox(height: 16),
              if (_oceanViews) ...[
                Text(
                  '4 ocean-view picks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                const _PlaceCard(
                  title: 'Blue hour at Miradouro',
                  subtitle: 'A quiet hillside view over the city lights',
                  icon: Icons.wb_twilight,
                ),
              ],
              _PlaceCard(
                title: 'Sunset cruise',
                subtitle: 'Small boat · sparkling wine included',
                icon: Icons.sailing,
                onTap: _showCruise,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startExploring() {
    setState(() => _exploring = true);
    _exploreAnimation.forward();
  }

  void _openItinerary() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const _ItineraryPage()),
    );
  }

  Future<void> _showCruise() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Golden hour on the Tagus'),
        content: const Text(
          'A slow sail beneath the bridge, with room for only 12 guests.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              setState(() => _booked = true);
              Navigator.pop(context);
            },
            child: const Text('Reserve for €24'),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.booked,
    required this.saved,
    required this.onSave,
    required this.onViewItinerary,
  });

  final bool booked;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onViewItinerary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xff0d6e8c), Color(0xff6ab7bd)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: DefaultTextStyle(
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MAY 17–19', style: TextStyle(letterSpacing: 1.4)),
              const SizedBox(height: 28),
              const Text(
                '7 saved places',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                booked
                    ? '1 experience reserved'
                    : 'Make room for something memorable',
              ),
              if (booked) ...[
                const SizedBox(height: 16),
                const Text('Booked: Sunset cruise'),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: saved ? null : onSave,
                  icon: Icon(saved ? Icons.check : Icons.bookmark_border),
                  label: Text(
                    saved
                        ? 'Itinerary saved for your weekend'
                        : 'Save itinerary',
                  ),
                ),
                if (saved) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onViewItinerary,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('View itinerary'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ItineraryPage extends StatelessWidget {
  const _ItineraryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Lisbon itinerary')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sunday, May 19',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: CircleAvatar(child: Icon(Icons.sailing)),
              title: Text('Sunset cruise · confirmed'),
              subtitle: Text('19:30 · Tagus river'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
