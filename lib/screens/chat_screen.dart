import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_chat_service.dart';
import '../providers/medical_data_provider.dart';
import '../providers/user_profile_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': "Hi! I'm your Smart Health Assistant. How can I help you today?",
      'timestamp': DateTime.now()
    }
  ];
  bool _isTyping = false;
  final AIChatService _chatService = AIChatService();

  void _sendMessage() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({
        'isUser': true,
        'text': query,
        'timestamp': DateTime.now()
      });
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Prepare context
    final dataProvider = context.read<MedicalDataProvider>();
    final profileProvider = context.read<UserProfileProvider>();
    final contextMap = {
      'profile': profileProvider.activeProfile,
      'history': dataProvider.history.where((item) => item.userId == profileProvider.activeProfileId).toList(),
    };

    try {
      final response = await _chatService.getResponse(query, contextMap);
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text': response,
            'timestamp': DateTime.now()
          });
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
  }

  void _sendPrompt(String prompt) {
    _controller.text = prompt;
    _sendMessage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Chat'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _messages.clear());
              _messages.add({
                'isUser': false,
                'text': "Conversation cleared. How can I help you now?",
                'timestamp': DateTime.now()
              });
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHealthDisclaimer(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message['text'], message['isUser']);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Analyzing medical context...', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          _buildQuickPrompts(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHealthDisclaimer() {
    return Container(
      width: double.infinity,
      color: Colors.orange.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Educational purposes only. Not professional medical advice.',
              style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    final prompts = [
      '🔍 Check interactions',
      '💊 Explain med side effects',
      '📑 Analyze my lab results',
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(prompts[index], style: const TextStyle(fontSize: 12)),
              onPressed: () => _sendPrompt(prompts[index].substring(3)),
              backgroundColor: Colors.blue.withOpacity(0.05),
              side: BorderSide(color: Colors.blue.withOpacity(0.1)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Ask your health assistant...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
