class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? videoTitle;
  final String? videoUrl;
  final bool isLoading;
  final bool isStreaming;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.videoTitle,
    this.videoUrl,
    this.isLoading = false,
    this.isStreaming = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'videoTitle': videoTitle,
        'videoUrl': videoUrl,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        videoTitle: json['videoTitle'] as String?,
        videoUrl: json['videoUrl'] as String?,
      );

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? videoTitle,
    String? videoUrl,
    bool? isLoading,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      videoTitle: videoTitle ?? this.videoTitle,
      videoUrl: videoUrl ?? this.videoUrl,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

class QuestionHistory {
  final String id;
  final String question;
  final String shortAnswer;
  final DateTime askedAt;

  QuestionHistory({
    required this.id,
    required this.question,
    required this.shortAnswer,
    required this.askedAt,
  });
}
