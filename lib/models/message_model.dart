class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final String type; // text, image, file
  final String timestamp;
  final bool isRead;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'text',
      timestamp: map['timestamp'] ?? '',
      isRead: map['isRead'] ?? false,
    );
  }
}