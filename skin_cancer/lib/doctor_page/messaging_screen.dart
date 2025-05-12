import 'package:flutter/material.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final List<Message> _messages = [
    Message(
      text: 'Good morning!',
      sender: 'Patient',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    Message(
      text: 'Good morning! How are you?',
      sender: 'Doctor',
      timestamp: DateTime.now().subtract(Duration(minutes: 4)),
    ),
    Message(
      text: 'I am not good, doctor. I have had a temperature since last day.',
      sender: 'Patient',
      timestamp: DateTime.now().subtract(Duration(minutes: 3)),
    ),
    Message(
      text: 'Good morning! How are you?',
      sender: 'Doctor',
      timestamp: DateTime.now(),
    ),
  ];

  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  void _sendMessage(String messageText) {
    if (messageText.isNotEmpty) {
      setState(() {
        _messages.add(Message(
          text: messageText,
          sender: 'Patient',
          timestamp: DateTime.now(),
        ));
        _messageController.clear();
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assests/black_doctor.jpg'),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr Benedict Montero',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.call, color: Colors.blue[700]),
              onPressed: () {
                
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[700]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return Align(
                    alignment:
                        message.sender == 'Patient' ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message.sender == 'Patient'
                            ? Colors.blue
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: TextStyle(color: message.sender == 'Patient' ? Colors.white : Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message.timestamp.toString().split(' ')[1].substring(0, 5),
                            style: TextStyle(
                              fontSize: 10,
                              color: message.sender == 'Patient'
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'typing...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (value) {
                      setState(() {
                        _isTyping = value.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      hintStyle: TextStyle(color: Colors.blue[700]), // Hint text color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.blue[700]!), // Outline color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.blue[700]!), // Focused outline color
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: Colors.blue[700]),
                        onPressed: () {
                          _sendMessage(_messageController.text);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Model for messages
class Message {
  final String text;
  final String sender;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}