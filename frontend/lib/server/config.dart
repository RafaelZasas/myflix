import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

class Config {
  static Config shared = Config();
  Uri _serverUri = Uri();

  Config() {
    setServerUri();
  }

  String get host {
    return _serverUri.host;
  }

  String get port {
    return _serverUri.port.toString();
  }

  Future<String> get _serverPort async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("port") ?? "";
  }

  Future<String> get _serverHost async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("host") ?? "";
  }

  Uri get serverUri {
    return _serverUri;
  }

  void setServerUri() async {
    final prefs = await SharedPreferences.getInstance();

    var port = prefs.getString("port");
    var host = prefs.getString("host");
    _serverUri = Uri.parse("http://$host:$port");
  }

  void setServerPort(String port) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("port", port);
    _serverUri = _serverUri.replace(port: int.parse(port));
  }

  void setServerHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("host", host);
    _serverUri = _serverUri.replace(host: host);
  }

  Future<bool> testServerConnection() async {
    print("testing server connection");
    try {
      final String host = await _serverHost;
      final String port = await _serverPort;

      if (host == "" || port == "") {
        return false;
      }

      final response = await http.get(_serverUri.replace(path: "/movies"));

      return response.statusCode == 200;
    } catch (err) {
      print("error testing connection:\n$err");
      return false;
    }
  }
}
