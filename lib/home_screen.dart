import 'package:flutter/material.dart';
import 'package:movies_app/movie/model/model.dart';
import 'package:movies_app/movie_services.dart';

const Color bg = Color(0xFF10111B);
const Color surface = Color(0xFF1D1F2D);
const Color accent = Color(0xFFFFC857);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieServices service = MovieServices();
  final TextEditingController searchController = TextEditingController();

  late Future<List<Model>> featuredFuture;

  List<Model> searchResults = [];
  bool isSearching = false;
  bool searchSubmitted = false;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    featuredFuture = service.getFeaturedMovies();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
        searchSubmitted = false;
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchSubmitted = true;
    });

    try {
      final results = await service.searchMovies(query);

      if (!mounted) return;

      setState(() {
        searchResults = results;
        isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        searchResults = [];
        isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load movies. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: selectedIndex == 1
            ? buildSearchPage()
            : selectedIndex == 2
            ? const Center(child: Text('Watchlist coming soon'))
            : selectedIndex == 3
            ? const Center(child: Text('Profile'))
            : buildHome(),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: surface,
        indicatorColor: accent.withOpacity(0.15),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return FutureBuilder<List<Model>>(
      future: featuredFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: accent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load movies'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      featuredFuture = service.getFeaturedMovies();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final movies = snapshot.data ?? [];

        if (movies.isEmpty) {
          return const Center(child: Text('No movies found'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Row(
              children: [
                const Icon(Icons.movie_filter_rounded, color: accent, size: 34),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'CineScope',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => selectedIndex = 1);
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const Text(
              'Find your next',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const Text(
              'favorite movie.',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            searchField(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Featured Movie'),
            const SizedBox(height: 14),
            FeaturedCard(
              movie: movies.first,
              onTap: () => openDetails(movies.first),
            ),
            const SizedBox(height: 30),
            const SectionHeader(title: 'Popular Movies'),
            const SizedBox(height: 16),
            SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final movie = movies[index];

                  return MoviePosterCard(
                    movie: movie,
                    onTap: () => openDetails(movie),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildSearchPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Movies',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          searchField(),
          const SizedBox(height: 20),
          if (isSearching)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: accent)),
            )
          else if (!searchSubmitted)
            const Expanded(
              child: Center(
                child: Text(
                  'Search by movie title',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else if (searchResults.isEmpty)
            const Expanded(child: Center(child: Text('No movies found')))
          else
            Expanded(
              child: GridView.builder(
                itemCount: searchResults.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.53,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final movie = searchResults[index];

                  return MoviePosterCard(
                    movie: movie,
                    onTap: () => openDetails(movie),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget searchField() {
    return TextField(
      controller: searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: searchMovies,
      decoration: InputDecoration(
        hintText: 'Search movies...',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: () => searchMovies(searchController.text),
          icon: const Icon(Icons.arrow_forward),
        ),
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> openDetails(Model movie) async {
    if (movie.imdbId == null || movie.imdbId!.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: accent)),
    );

    try {
      final details = await service.getMovieDetails(movie.imdbId!);

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: details)),
      );
    } catch (_) {
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load movie details')),
      );
    }
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
    );
  }
}

class FeaturedCard extends StatelessWidget {
  final Model movie;
  final VoidCallback onTap;

  const FeaturedCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          image: movie.poster != null && movie.poster != 'N/A'
              ? DecorationImage(
                  image: NetworkImage(movie.poster!),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.55),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "TODAY'S PICK",
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                movie.title ?? 'Featured Movie',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${movie.year ?? ''}  •  ${movie.genre ?? 'Movie'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.play_circle_fill, color: accent, size: 23),
                  SizedBox(width: 7),
                  Text('View details'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoviePosterCard extends StatelessWidget {
  final Model movie;
  final VoidCallback onTap;

  const MoviePosterCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPoster =
        movie.poster != null &&
        movie.poster!.isNotEmpty &&
        movie.poster != 'N/A';

    return SizedBox(
      width: 155,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  color: surface,
                  child: hasPoster
                      ? Image.network(
                          movie.poster!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const PosterPlaceholder(),
                        )
                      : const PosterPlaceholder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              movie.title ?? 'Unknown title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 13, color: accent),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    movie.year ?? 'Year unknown',
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                if (movie.imdbRating != null && movie.imdbRating != 'N/A') ...[
                  const Icon(Icons.star, color: accent, size: 14),
                  const SizedBox(width: 3),
                  Text(movie.imdbRating!, style: const TextStyle(fontSize: 12)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.movie_outlined, size: 55, color: Colors.white30),
    );
  }
}

class MovieDetailsScreen extends StatelessWidget {
  final Model movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final hasPoster =
        movie.poster != null &&
        movie.poster!.isNotEmpty &&
        movie.poster != 'N/A';

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: bg,
            flexibleSpace: FlexibleSpaceBar(
              background: hasPoster
                  ? Image.network(
                      movie.poster!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const PosterPlaceholder(),
                    )
                  : const PosterPlaceholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? 'Movie Details',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${movie.year ?? ''}  •  ${movie.runtime ?? ''}  •  ${movie.rated ?? ''}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: accent),
                      const SizedBox(width: 6),
                      Text(
                        movie.imdbRating != null && movie.imdbRating != 'N/A'
                            ? movie.imdbRating!
                            : 'Not rated',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    movie.genre ?? 'Genre unavailable',
                    style: const TextStyle(color: accent, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Overview'),
                  const SizedBox(height: 8),
                  Text(
                    movie.plot ?? 'No plot available.',
                    style: const TextStyle(color: Colors.white70, height: 1.6),
                  ),
                  const SizedBox(height: 22),
                  detailRow('Director', movie.director),
                  detailRow('Cast', movie.actors),
                  detailRow('Writer', movie.writer),
                  detailRow('Language', movie.language),
                  detailRow('Awards', movie.awards),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Ratings'),
                  const SizedBox(height: 10),
                  if (movie.ratings == null || movie.ratings!.isEmpty)
                    const Text(
                      'No ratings available.',
                      style: TextStyle(color: Colors.white54),
                    )
                  else
                    ...movie.ratings!.map(
                      (rating) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(rating.source ?? 'Source'),
                        trailing: Text(
                          rating.value ?? 'N/A',
                          style: const TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String label, String? value) {
    if (value == null || value.isEmpty || value == 'N/A') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
