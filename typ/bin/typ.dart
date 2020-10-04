import "dart:io";
import "dart:convert";

import "package:path/path.dart" as path;
import "package:args/args.dart";
import 'package:typ/src/parser.dart';

void printHelp(ArgParser parser, {String message, int exitcode}) {
  if(message != null && message != "") {
    print(message);
    print("");
  }

  print("usage: typ [option] ... [file]");
  print("");
  print(parser.usage);

  if(exitcode != null) {
    exit(exitcode);
  }
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag("help", abbr: "h", negatable: false)
    ..addFlag("verbose", abbr: "v", negatable: false, help: "Verbose logging.")
    ..addOption("output", abbr: "o", defaultsTo: "output", valueHelp: "path", help: "path to output directory")
    ..addOption("mode", abbr: "m", help: "TyP output mode", defaultsTo: "pdf", allowed: ["pdf", "html"]);
  final results = parser.parse(arguments);

  if (results["help"]) {
    printHelp(parser, exitcode: 0);
  }

  String typName = "TyP";
  String typExtension = "typ";

  // If we have a rest it should be interpreted as a
  // path to a) a direcotry containing a main.typ file
  // or b) a direct path top a .typ file
  if (results.rest.length != 0) {
    for(String pathName in results.rest) {
      bool directoryExists = await Directory(pathName).exists();
      if(directoryExists) {
        pathName = path.join(pathName, "main.$typExtension");
      }

      bool fileExists = await File(pathName).exists();

      if(fileExists) {

        File typFile = File(pathName);

        String code = await typFile.readAsString();
        parse(code);

      } else {
        printHelp(parser, message: "$pathName does not exist.", exitcode: 1);
      }
    }

    exit(0);
  } else {
    Stream<String> readLine() => stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter());

    void runLiveInterpreter() {
      stdout.writeln("$typName Live Interpreter 0.0.1 (Alpha).");
      stdout.write("$typName > ");

      readLine().listen((code) {
        print(code);
        parse(code);
        stdout.write("$typName > ");
      });
    }

    runLiveInterpreter();
  }
}
