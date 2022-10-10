class Content {
  final String title;
  final String poster;
  final String plot;
  final String rated;
  final String genre;
  final String directror;
  final String imdbId;
  // final String videoUrl;

  const Content(
      {required this.poster,
      required this.plot,
      required this.rated,
      required this.genre,
      required this.directror,
      required this.imdbId,
      // required this.videoUrl,
      required this.title});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      title: json["title"],
      directror: json["director"],
      genre: json["genre"],
      imdbId: json["imdbId"],
      plot: json["plot"],
      poster: json["poster"],
      rated: json["rated"],
      // videoUrl: json["videoUrl"]
    );
  }
}
