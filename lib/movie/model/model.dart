import 'package:collection/collection.dart';

import 'rating.dart';

class Model {
  String? title;
  String? year;
  String? rated;
  String? released;
  String? runtime;
  String? genre;
  String? director;
  String? writer;
  String? actors;
  String? plot;
  String? language;
  String? country;
  String? awards;
  String? poster;
  List<Rating>? ratings;
  String? metascore;
  String? imdbRating;
  String? imdbVotes;
  String? imdbId;
  String? type;
  String? dvd;
  String? boxOffice;
  String? production;
  String? website;
  String? response;

  Model({
    this.title,
    this.year,
    this.rated,
    this.released,
    this.runtime,
    this.genre,
    this.director,
    this.writer,
    this.actors,
    this.plot,
    this.language,
    this.country,
    this.awards,
    this.poster,
    this.ratings,
    this.metascore,
    this.imdbRating,
    this.imdbVotes,
    this.imdbId,
    this.type,
    this.dvd,
    this.boxOffice,
    this.production,
    this.website,
    this.response,
  });

  factory Model.fromJson(Map<String, dynamic> json) => Model(
    title: json['Title'] as String?,
    year: json['Year'] as String?,
    rated: json['Rated'] as String?,
    released: json['Released'] as String?,
    runtime: json['Runtime'] as String?,
    genre: json['Genre'] as String?,
    director: json['Director'] as String?,
    writer: json['Writer'] as String?,
    actors: json['Actors'] as String?,
    plot: json['Plot'] as String?,
    language: json['Language'] as String?,
    country: json['Country'] as String?,
    awards: json['Awards'] as String?,
    poster: json['Poster'] as String?,
    ratings: (json['Ratings'] as List<dynamic>?)
        ?.map((e) => Rating.fromJson(e as Map<String, dynamic>))
        .toList(),
    metascore: json['Metascore'] as String?,
    imdbRating: json['imdbRating'] as String?,
    imdbVotes: json['imdbVotes'] as String?,
    imdbId: json['imdbID'] as String?,
    type: json['Type'] as String?,
    dvd: json['DVD'] as String?,
    boxOffice: json['BoxOffice'] as String?,
    production: json['Production'] as String?,
    website: json['Website'] as String?,
    response: json['Response'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'Title': title,
    'Year': year,
    'Rated': rated,
    'Released': released,
    'Runtime': runtime,
    'Genre': genre,
    'Director': director,
    'Writer': writer,
    'Actors': actors,
    'Plot': plot,
    'Language': language,
    'Country': country,
    'Awards': awards,
    'Poster': poster,
    'Ratings': ratings?.map((e) => e.toJson()).toList(),
    'Metascore': metascore,
    'imdbRating': imdbRating,
    'imdbVotes': imdbVotes,
    'imdbID': imdbId,
    'Type': type,
    'DVD': dvd,
    'BoxOffice': boxOffice,
    'Production': production,
    'Website': website,
    'Response': response,
  };

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Model) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      title.hashCode ^
      year.hashCode ^
      rated.hashCode ^
      released.hashCode ^
      runtime.hashCode ^
      genre.hashCode ^
      director.hashCode ^
      writer.hashCode ^
      actors.hashCode ^
      plot.hashCode ^
      language.hashCode ^
      country.hashCode ^
      awards.hashCode ^
      poster.hashCode ^
      ratings.hashCode ^
      metascore.hashCode ^
      imdbRating.hashCode ^
      imdbVotes.hashCode ^
      imdbId.hashCode ^
      type.hashCode ^
      dvd.hashCode ^
      boxOffice.hashCode ^
      production.hashCode ^
      website.hashCode ^
      response.hashCode;
}
