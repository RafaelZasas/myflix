import "package:flutter/material.dart";
import "package:myflix/screens/screens.dart";
import "package:myflix/server/config.dart";
import 'package:myflix/spinners/fading_circle.dart';

// ignore: todo
class ServerSetupScreen extends StatefulWidget {
  const ServerSetupScreen({super.key});
  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends State<ServerSetupScreen> {
  var serverStatus = false;
  bool loading = false;
  String host = Config.shared.host;
  String port = Config.shared.port;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController myController = TextEditingController(text: "none");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 100, left: 10, right: 10),
          color: Colors.black,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Server Configuration",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        TextFormField(
                          textAlign: TextAlign.center,
                          initialValue: host,
                          onChanged: (String value) {
                            host = value;
                          },
                          decoration: const InputDecoration(
                              hintText: "Server Ip Address:",
                              border: OutlineInputBorder(),
                              hintStyle: TextStyle(color: Colors.white)),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          validator: (String? value) {
                            if ((value == null || value.isEmpty) &&
                                port == "") {
                              return "Please enter host IP";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: port,
                          textAlign: TextAlign.center,
                          onChanged: (String value) {
                            port = value;
                          },
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0))),
                              hintText: "Server Port:",
                              hintStyle: TextStyle(color: Colors.white)),
                          style: const TextStyle(color: Colors.white),
                          validator: (String? value) {
                            if ((value == null || value.isEmpty) &&
                                host == "") {
                              return "Please enter port number";
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate will return true if the form is valid, or false if
                              // the form is invalid.
                              if (_formKey.currentState!.validate()) {
                                if (host != "") {
                                  Config.shared.setServerHost(host);
                                }

                                if (port != "") {
                                  Config.shared.setServerPort(port);
                                }

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      // Retrieve the text that the user has entered by using the
                                      // TextEditingController.
                                      content: Text(
                                          "Ip host set to ${host.isEmpty ? "0.0.0.0" : host}\nPort is set to ${port.isEmpty ? "0000" : port}"),
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text("Submit"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Server Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  indent: 30,
                  endIndent: 30,
                ),
                const SizedBox(height: 20),
                if (loading)
                  const SpinKitFadingCircle(color: Colors.blueAccent),
                if (!loading)
                  Text(
                    "Server is ${serverStatus ? "" : "un"}healthy",
                    style: TextStyle(
                      color:
                          serverStatus ? Colors.greenAccent[400] : Colors.red,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      var res = await Config.shared.testServerConnection();
                      setState(() {
                        setState(() {
                          loading = true;
                          serverStatus = res;
                          loading = false;
                        });
                      });
                    },
                    child: const Text("test connection"),
                  ),
                ),
                HomeButton(serverStatus: serverStatus),
              ]),
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final bool serverStatus;
  const HomeButton({super.key, required this.serverStatus});

  @override
  Widget build(BuildContext context) {
    if (serverStatus) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: ElevatedButton(
          onPressed: () async {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NavScreen()));
          },
          child: const Text("Home"),
        ),
      );
    } else {
      return Container();
    }
  }
}
