import "package:myflix/models/content_model.dart";

class Movie extends Content {
  final String runtime;
  final String released;
  final String imdbRating;
  final String metaScore;

  Movie(this.runtime, this.released, this.imdbRating, this.metaScore,
      {required super.poster,
      required super.plot,
      required super.rated,
      required super.genre,
      required super.directror,
      required super.imdbId,
      // required super.videoUrl,
      required super.title});
}
