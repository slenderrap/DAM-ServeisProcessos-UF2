import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'game_data.dart';

class AppData extends ChangeNotifier {
  GameData gameData = GameData(name: "", levels: []);
  String filePath = "";
  String fileName = "";
  String selectedSection = "game";
  int selectedLevel = -1;
  int selectedLayer = -1;
  int selectedZone = -1;
  int selectedSprite = -1;

  void update() {
    notifyListeners();
  }

  Future<void> loadGame() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      String tmpPath = result.files.single.path!;
      final file = File(tmpPath);

      if (!await file.exists()) {
        throw Exception("File not found: $tmpPath");
      }

      filePath = file.parent.path;
      fileName = file.uri.pathSegments.last;

      final content = await file.readAsString();
      final jsonData = jsonDecode(content);
      gameData = GameData.fromJson(jsonData);

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading game file: $e");
      }
    }
  }

  Future<void> saveGame() async {
    try {
      if (fileName == "") {
        String? outputFilePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Choose location to save game file',
          fileName: "${gameData.name.replaceAll(" ", "_")}.json",
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputFilePath == null) {
          if (kDebugMode) {
            print("File name not selected, can't save.");
          }
          return;
        }

        final file = File(outputFilePath);
        filePath = file.parent.path;
        fileName = file.uri.pathSegments.last;
      }

      final file = File("$filePath/$fileName");
      final jsonData = jsonEncode(gameData.toJson());
      final prettyJson =
          const JsonEncoder.withIndent('  ').convert(jsonDecode(jsonData));

      final numberArrayRegex = RegExp(r'\[\s*((?:-?\d+\s*,\s*)*-?\d+\s*)\]');
      final output = prettyJson.replaceAllMapped(numberArrayRegex, (match) {
        final numbers = match.group(1)!;
        return '[${numbers.replaceAll(RegExp(r'\s+'), ' ').trim()}]';
      });
      await file.writeAsString(output);

      if (kDebugMode) {
        print("Game saved successfully to \"$filePath/$fileName\"");
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error saving game file: $e");
      }
    }
  }

  Future<String> pickImageFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      initialDirectory: filePath != "" ? filePath : null,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.single.path == null) {
      return "";
    } else {
      return result.files.single.path!.replaceAll("$filePath/", "");
    }
  }
/*
  String _responseText = "";
  bool _isLoading = false;
  bool _isInitial = true;
  http.Client? _client;
  IOClient? _ioClient;
  HttpClient? _httpClient;
  StreamSubscription<String>? _streamSubscription;
  final List<Drawable> drawables = [];

  String get responseText =>
      _isInitial ? "..." : (_isLoading ? "Esperant ..." : _responseText);

  bool get isLoading => _isLoading;

  AppData() {
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void addDrawable(Drawable drawable) {
    drawables.add(drawable);
    notifyListeners();
  }

  Future<void> callStream({required String question}) async {
    _responseText = "";
    _isInitial = false;
    setLoading(true);

    try {
      var request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/generate'),
      );

      request.headers.addAll({'Content-Type': 'application/json'});
      request.body =
          jsonEncode({'model': 'llama3.2', 'prompt': question, 'stream': true});

      var streamedResponse = await _client!.send(request);
      _streamSubscription =
          streamedResponse.stream.transform(utf8.decoder).listen((value) {
        var jsonResponse = jsonDecode(value);
        _responseText += jsonResponse['response'];
        notifyListeners();
      }, onError: (error) {
        if (error is http.ClientException &&
            error.message == 'Connection closed while receiving data') {
          _responseText += "\nRequest cancelled.";
        } else {
          _responseText = "Error during streaming: $error";
        }
        setLoading(false);
        notifyListeners();
      }, onDone: () {
        setLoading(false);
      });
    } catch (e) {
      _responseText = "Error during streaming.";
      setLoading(false);
      notifyListeners();
    }
  }

  dynamic fixJsonInStrings(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, fixJsonInStrings(value)));
    } else if (data is List) {
      return data.map(fixJsonInStrings).toList();
    } else if (data is String) {
      try {
        // Si és JSON dins d'una cadena, el deserialitzem
        final parsed = jsonDecode(data);
        return fixJsonInStrings(parsed);
      } catch (_) {
        // Si no és JSON, retornem la cadena tal qual
        return data;
      }
    }
    // Retorna qualsevol altre tipus sense canvis (números, booleans, etc.)
    return data;
  }

  dynamic cleanKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.trim()] = cleanKeys(v);
      });
      return result;
    }
    if (value is List) {
      return value.map(cleanKeys).toList();
    }
    return value;
  }

  Future<void> callWithCustomTools({required String userPrompt}) async {
    const apiUrl = 'http://localhost:11434/api/chat';
    _responseText = "";
    _isInitial = false;
    setLoading(true);

    final body = {
      "model": "llama3.2",
      "stream": false,
      "messages": [
        {"role": "user", "content": userPrompt}
      ],
      "tools": tools
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['message'] != null &&
            jsonResponse['message']['tool_calls'] != null) {
          final toolCalls = (jsonResponse['message']['tool_calls'] as List)
              .map((e) => cleanKeys(e))
              .toList();
          for (final tc in toolCalls) {
            if (tc['function'] != null) {
              _processFunctionCall(tc['function']);
            }
          }
        }
        setLoading(false);
      } else {
        setLoading(false);
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during API call: $e");
      }
      setLoading(false);
    }
  }

  void cancelRequests() {
    _streamSubscription?.cancel();
    _httpClient?.close(force: true);
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
    _responseText += "\nRequest cancelled.";
    setLoading(false);
    notifyListeners();
  }

  double parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  void _processFunctionCall(Map<String, dynamic> functionCall) {
    final fixedJson = fixJsonInStrings(functionCall);
    final parameters = fixedJson['arguments'];

    String name = fixedJson['name'];
    if (kDebugMode) {
      print("Draw $name: $parameters");
    }

    switch (name) {
      case 'draw_circle':
        if (parameters['x'] != null &&
            parameters['y'] != null &&
            parameters['radius'] != null) {
          final dx = parseDouble(parameters['x']);
          final dy = parseDouble(parameters['y']);
          final radius = max(0.0, parseDouble(parameters['radius']));
          addDrawable(Circle(center: Offset(dx, dy), radius: radius));
        } else {
          print("Missing circle properties: $parameters");
        }
        break;

      case 'draw_line':
        if (parameters['startX'] != null &&
            parameters['startY'] != null &&
            parameters['endX'] != null &&
            parameters['endY'] != null) {
          final startX = parseDouble(parameters['startX']);
          final startY = parseDouble(parameters['startY']);
          final endX = parseDouble(parameters['endX']);
          final endY = parseDouble(parameters['endY']);
          final start = Offset(startX, startY);
          final end = Offset(endX, endY);
          addDrawable(Line(start: start, end: end));
        } else {
          if (kDebugMode) {
            print("Missing line properties: $parameters");
          }
        }
        break;

      case 'draw_rectangle':
        if (parameters['topLeftX'] != null &&
            parameters['topLeftY'] != null &&
            parameters['bottomRightX'] != null &&
            parameters['bottomRightY'] != null) {
          final topLeftX = parseDouble(parameters['topLeftX']);
          final topLeftY = parseDouble(parameters['topLeftY']);
          final bottomRightX = parseDouble(parameters['bottomRightX']);
          final bottomRightY = parseDouble(parameters['bottomRightY']);
          final topLeft = Offset(topLeftX, topLeftY);
          final bottomRight = Offset(bottomRightX, bottomRightY);
          addDrawable(Rectangle(topLeft: topLeft, bottomRight: bottomRight));
        } else {
          if (kDebugMode) {
            print("Missing rectangle properties: $parameters");
          }
        }
        break;

      default:
        if (kDebugMode) {
          print("Unknown function call: ${fixedJson['name']}");
        }
    }
  }*/
}
