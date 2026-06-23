import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _webhookUrl =
      'https://automation.vqcodes.com/webhook/user-query';

  /// Streaming response — yields content chunks as they arrive (ChatGPT-style)
  static Stream<String> askQuestionStreaming(String question) async* {
    final request = http.Request('POST', Uri.parse(_webhookUrl));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({'text': question});

    final streamedResponse = await request.send();
    if (streamedResponse.statusCode != 200) {
      throw Exception('Server error: ${streamedResponse.statusCode}');
    }

    String remainder = '';
    await for (final chunk
        in streamedResponse.stream.transform(const Utf8Decoder())) {
      remainder += chunk;
      final lines = remainder.split('\n');
      remainder = lines.removeLast();

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        try {
          final obj = jsonDecode(trimmed) as Map<String, dynamic>;
          if (obj['type'] == 'item') {
            final content = obj['content']?.toString() ?? '';
            // Skip the final assembled JSON object from "Respond to Webhook"
            try {
              final parsed = jsonDecode(content);
              if (parsed is Map && parsed.containsKey('output')) continue;
            } catch (_) {
              yield content;
            }
          }
        } catch (_) {}
      }
    }

    // Flush any remaining buffered line
    final trimmed = remainder.trim();
    if (trimmed.isNotEmpty) {
      try {
        final obj = jsonDecode(trimmed) as Map<String, dynamic>;
        if (obj['type'] == 'item') {
          final content = obj['content']?.toString() ?? '';
          try {
            final parsed = jsonDecode(content);
            if (parsed is Map && parsed.containsKey('output')) return;
          } catch (_) {
            yield content;
          }
        }
      } catch (_) {}
    }
  }

  /// Guruji se question poochho
  static Future<Map<String, dynamic>> askQuestion(String question) async {
    try {
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'test': question}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final lines = response.body.trim().split('\n');
        for (final line in lines) {
          try {
            final obj = jsonDecode(line) as Map<String, dynamic>;
            if (obj['type'] == 'item' && obj['content'] != null) {
              return {'answer': obj['content'].toString()};
            }
          } catch (_) {}
        }
        return {'answer': response.body.trim()};
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<List<String>> getSuggestedQuestions() async {
    return _staticSuggestedQuestions;
  }

  static const List<String> _staticSuggestedQuestions = [
    'Bhakti kya hai aur kaise karein?',
    'Radha ji ki mahima batayein',
    'Mantra jaap ka sahi tarika kya hai?',
    'Guru ki seva kaise karein?',
    'Vrindavan ki mahima kya hai?',
    'Bhagwad Gita ka saar kya hai?',
  ];
}
