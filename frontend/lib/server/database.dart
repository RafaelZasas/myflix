import "package:myflix/server/server.dart";

import "../models/models.dart";
import "package:http/http.dart" as http;
import "dart:convert";

class Database {
  Uri get _serverUri {
    return Config.shared.serverUri;
  }

  Future<Content> fetchFeaturedContent() async {
    var url = _serverUri.replace(path: "/content/featured");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Content.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception("Failed to load album");
    }
  }

  Future<List<Content>> fetchPreviews() async {
    final response = await http.get(_serverUri.replace(path: "/movies"));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Iterable l = json.decode(response.body)["result"];
      List<Content> content =
          List<Content>.from(l.map((model) => Content.fromJson(model)));
      return content;
    } else {
      throw Exception("Failed to fetch previews from server");
    }
  }

  Future<List<Content>> fetchOldies() async {
    final response = await http.post(_serverUri.replace(path: "/search/movies"),
        body: json.encode({
          "sort": ["year:asc"],
          "q": "",
          "limit": 8
        }));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Iterable l = json.decode(response.body);
      List<Content> content =
          List<Content>.from(l.map((model) => Content.fromJson(model)));
      return content;
    } else {
      print(response.reasonPhrase);
      throw Exception("Failed to fetch oldies from server");
    }
  }

  Future<List<Content>> fetchCriticallyAclaimed() async {
    final response = await http.post(_serverUri.replace(path: "/search/movies"),
        body: json.encode({
          "sort": ["metascore:desc"],
          "q": "",
          "limit": 10
        }));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Iterable l = json.decode(response.body);
      List<Content> content =
          List<Content>.from(l.map((model) => Content.fromJson(model)));
      return content;
    } else {
      print(response.reasonPhrase);
      throw Exception("Failed to fetch oldies from server");
    }
  }
}
