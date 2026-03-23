import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/place.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/place_provider.dart';
import '../../../../shared/widgets/place_card.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentTab = 0;

  void switchTab(int index) {
    setState(() => _currentTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: [
          _HomeContent(onSearchTap: () => switchTab(1)),
          const _SearchContent(),
          const _BookmarksContent(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Home Tab
// ──────────────────────────────────────────
class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.onSearchTap});
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final officialAsync = ref.watch(officialPlacesProvider);
    final communityAsync = ref.watch(communityPlacesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final officialPlaces = officialAsync.valueOrNull ?? [];
    final communityPlaces = communityAsync.valueOrNull ?? [];

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover Korea',
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Find the best places loved by locals',
                    style: AppTextStyles.body.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              child: GestureDetector(
                onTap: onSearchTap,
                child: const SearchBarWidget(),
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.md),
                children: [
                  CategoryChip(
                    icon: Icons.restaurant_rounded,
                    label: 'Food',
                    isSelected: selectedCategory == 'Food',
                    onTap: () => _toggleCategory(ref, 'Food'),
                  ),
                  CategoryChip(
                    icon: Icons.coffee_rounded,
                    label: 'Cafe',
                    isSelected: selectedCategory == 'Cafe',
                    onTap: () => _toggleCategory(ref, 'Cafe'),
                  ),
                  CategoryChip(
                    icon: Icons.photo_camera_rounded,
                    label: 'Attractions',
                    isSelected: selectedCategory == 'Attraction',
                    onTap: () => _toggleCategory(ref, 'Attraction'),
                  ),
                  CategoryChip(
                    icon: Icons.local_bar_rounded,
                    label: 'Bars',
                    isSelected: selectedCategory == 'Bars',
                    onTap: () => _toggleCategory(ref, 'Bars'),
                  ),
                  CategoryChip(
                    icon: Icons.shopping_bag_rounded,
                    label: 'Shopping',
                    isSelected: selectedCategory == 'Shopping',
                    onTap: () => _toggleCategory(ref, 'Shopping'),
                  ),
                  CategoryChip(
                    icon: Icons.museum_rounded,
                    label: 'Culture',
                    isSelected: selectedCategory == 'Culture',
                    onTap: () => _toggleCategory(ref, 'Culture'),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),

          // Popular Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Popular Near You', style: AppTextStyles.heading3),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (officialAsync.isLoading)
            const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(AppSizes.lg),
                child: CircularProgressIndicator(),
              )),
            )
          else
            // Popular Places List
            SliverList.builder(
              itemCount: _filterByCategory(officialPlaces, selectedCategory).length,
              itemBuilder: (context, index) {
                final place =
                    _filterByCategory(officialPlaces, selectedCategory)[index];
                return PlaceCard(
                  name: place.name,
                  category: place.category,
                  district: place.district,
                  rating: place.rating,
                  reviewCount: place.reviewCount,
                  sourceType: place.sourceType,
                  distance: place.distance,
                  description: place.description,
                  onTap: () => context.pushNamed(
                    'placeDetail',
                    pathParameters: {'id': place.id},
                  ),
                );
              },
            ),

          // Community Picks Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.lg,
                AppSizes.md,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Community Picks', style: AppTextStyles.heading3),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          SliverList.builder(
            itemCount:
                _filterByCategory(communityPlaces, selectedCategory).length,
            itemBuilder: (context, index) {
              final place =
                  _filterByCategory(communityPlaces, selectedCategory)[index];
              return PlaceCard(
                name: place.name,
                category: place.category,
                district: place.district,
                rating: place.rating,
                reviewCount: place.reviewCount,
                sourceType: place.sourceType,
                distance: place.distance,
                description: place.description,
                registeredBy: place.registeredBy,
                onTap: () => context.pushNamed(
                  'placeDetail',
                  pathParameters: {'id': place.id},
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
        ],
      ),
    );
  }

  void _toggleCategory(WidgetRef ref, String category) {
    final current = ref.read(selectedCategoryProvider);
    ref.read(selectedCategoryProvider.notifier).state =
        current == category ? null : category;
  }

  List<Place> _filterByCategory(List<Place> places, String? category) {
    if (category == null) return places;
    return places.where((p) => p.category == category).toList();
  }
}

// ──────────────────────────────────────────
// Search Tab
// ──────────────────────────────────────────
class _SearchContent extends ConsumerStatefulWidget {
  const _SearchContent();

  @override
  ConsumerState<_SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends ConsumerState<_SearchContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final query = ref.watch(searchQueryProvider);
    final filteredAsync = ref.watch(filteredPlacesProvider);
    final filteredPlaces = filteredAsync.valueOrNull ?? [];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search', style: AppTextStyles.heading2),
            const SizedBox(height: AppSizes.md),

            // Active search bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSizes.md),
                  Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search restaurants, attractions...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                      ),
                      style: AppTextStyles.body,
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                    ),
                  ),
                  if (query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    ),
                  const SizedBox(width: AppSizes.xs),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Results or Recent Searches
            if (query.isEmpty) ...[
              Text('Recent Searches', style: AppTextStyles.heading3),
              const SizedBox(height: AppSizes.md),
              _RecentSearchItem(
                text: 'Korean BBQ near Myeongdong',
                onTap: () {
                  _searchController.text = 'Korean BBQ near Myeongdong';
                  ref.read(searchQueryProvider.notifier).state =
                      'Korean BBQ near Myeongdong';
                },
              ),
              _RecentSearchItem(
                text: 'Best cafes in Hongdae',
                onTap: () {
                  _searchController.text = 'Best cafes in Hongdae';
                  ref.read(searchQueryProvider.notifier).state =
                      'Best cafes in Hongdae';
                },
              ),
              _RecentSearchItem(
                text: 'Bukchon Hanok Village',
                onTap: () {
                  _searchController.text = 'Bukchon Hanok Village';
                  ref.read(searchQueryProvider.notifier).state =
                      'Bukchon Hanok Village';
                },
              ),
              const SizedBox(height: AppSizes.lg),
              Text('Popular Tags', style: AppTextStyles.heading3),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: [
                  'Hidden gem',
                  'Budget-friendly',
                  'Must-visit',
                  'Date spot',
                  'Street Food',
                  'Views',
                  'Traditional',
                ]
                    .map((tag) => ActionChip(
                          label: Text(tag, style: AppTextStyles.caption),
                          onPressed: () {
                            _searchController.text = tag;
                            ref.read(searchQueryProvider.notifier).state = tag;
                          },
                        ))
                    .toList(),
              ),
            ] else ...[
              Text(
                '${filteredPlaces.length} results',
                style: AppTextStyles.label.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Expanded(
                child: filteredPlaces.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppSizes.md),
                            Text(
                              'No places found',
                              style: AppTextStyles.subtitle,
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              'Try different keywords',
                              style: AppTextStyles.body.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredPlaces.length,
                        itemBuilder: (context, index) {
                          final place = filteredPlaces[index];
                          return PlaceCard(
                            name: place.name,
                            category: place.category,
                            district: place.district,
                            rating: place.rating,
                            reviewCount: place.reviewCount,
                            sourceType: place.sourceType,
                            distance: place.distance,
                            description: place.description,
                            registeredBy: place.registeredBy,
                            onTap: () => context.pushNamed(
                              'placeDetail',
                              pathParameters: {'id': place.id},
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentSearchItem extends StatelessWidget {
  const _RecentSearchItem({required this.text, this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.history, color: colorScheme.onSurfaceVariant),
      title: Text(text, style: AppTextStyles.body),
      trailing: Icon(Icons.north_west,
          size: 16, color: colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}

// ──────────────────────────────────────────
// Bookmarks Tab (Soft Wall)
// ──────────────────────────────────────────
class _BookmarksContent extends ConsumerWidget {
  const _BookmarksContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider);

    // Guest mode - show sign-in prompt
    if (user.isGuest) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border_rounded,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSizes.md),
                Text('Save your favorites', style: AppTextStyles.heading3),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Sign in to bookmark places\nand build your Korea itinerary',
                  style: AppTextStyles.body.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.lg),
                FilledButton(
                  onPressed: () => context.pushNamed('login'),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Authenticated - show bookmarks
    final bookmarkedIds = user.bookmarkedPlaceIds;
    final allPlacesAsync = ref.watch(placesProvider);
    final allPlaces = allPlacesAsync.valueOrNull ?? [];
    final bookmarkedPlaces =
        allPlaces.where((p) => bookmarkedIds.contains(p.id)).toList();

    if (bookmarkedPlaces.isEmpty) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border_rounded,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSizes.md),
                Text('No bookmarks yet', style: AppTextStyles.heading3),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Tap the bookmark icon on any place\nto save it here',
                  style: AppTextStyles.body.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('Saved Places', style: AppTextStyles.heading2),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: bookmarkedPlaces.length,
              itemBuilder: (context, index) {
                final place = bookmarkedPlaces[index];
                return PlaceCard(
                  name: place.name,
                  category: place.category,
                  district: place.district,
                  rating: place.rating,
                  reviewCount: place.reviewCount,
                  sourceType: place.sourceType,
                  distance: place.distance,
                  description: place.description,
                  onTap: () => context.pushNamed(
                    'placeDetail',
                    pathParameters: {'id': place.id},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
