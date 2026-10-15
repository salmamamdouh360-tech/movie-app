import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:movies_app/movie/model/model.dart';

class MovieServices {
  final Dio dio = Dio();

  static const String key = 'e2dc80';
  final String baseUrl = 'https://www.omdbapi.com';

  // Search movies by title.
  Future<List<Model>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await dio.get(
        baseUrl,
        queryParameters: {'apikey': key, 's': query.trim(), 'type': 'movie'},
      );

      final data = response.data as Map<String, dynamic>;

      if (data['Response'] != 'True') {
        return [];
      }

      final results = data['Search'] as List<dynamic>? ?? [];

      return results
          .map((movie) => Model.fromJson(movie as Map<String, dynamic>))
          .toList();
    } on DioException catch (e, stackTrace) {
      log('Search error: ${e.message}', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get movie details by IMDb ID.
  Future<Model> getMovieDetails(String imdbId) async {
    final response = await dio.get(
      baseUrl,
      queryParameters: {'apikey': key, 'i': imdbId, 'plot': 'full'},
    );

    final data = response.data as Map<String, dynamic>;

    if (data['Response'] != 'True') {
      throw Exception(data['Error'] ?? 'Movie not found');
    }

    return Model.fromJson(data);
  }

  // Suggested movies for the Home screen.
  Future<List<Model>> getFeaturedMovies() async {
    const suggestions = [
      'Interstellar',
      'Inception',
      'The Dark Knight',
      'Avatar',
    ];

    final results = await Future.wait(suggestions.map(searchMovies));

    final movies = results.expand((list) => list).toList();

    // Remove duplicate movies by IMDb ID.
    final uniqueMovies = <String, Model>{};

    for (final movie in movies) {
      final id = movie.imdbId;
      if (id != null && id.isNotEmpty) {
        uniqueMovies[id] = movie;
      }
    }

    return uniqueMovies.values.toList();
  }
}
