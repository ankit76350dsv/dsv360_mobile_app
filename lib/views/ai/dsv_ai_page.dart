import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:dsv360/repositories/ai_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

final aiLoadingProvider = StateProvider<bool>((ref) => false);
final aiModeProvider = StateProvider<String>((ref) => 'AI Model');
final aiModelProvider = StateProvider<String>(
  (ref) => 'Text Model — crm-di-qwen_text_14b-fp8-it',
);
final aiImagesProvider = StateProvider<List<String>>((ref) => []);

class DsvAiPage extends ConsumerStatefulWidget {
  const DsvAiPage({super.key});

  @override
  ConsumerState<DsvAiPage> createState() => _DsvAiPageState();
}

class _DsvAiPageState extends ConsumerState<DsvAiPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  final List<String> _aiModels = [
    'Text Model — crm-di-qwen_text_14b-fp8-it',
    'Code Model — crm-di-qwen_coder_7b-it',
    'Vision Model — VL-Qwen2.5-7B',
  ];

  final List<String> _ragBots = ['HR Bot', 'Vedanta', 'Finance Bot'];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final isLoading = ref.read(aiLoadingProvider);
    final userMessage = _messageController.text.trim();
    final pickedImages = ref.read(aiImagesProvider);

    if ((userMessage.isEmpty && pickedImages.isEmpty) || isLoading) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
          images: List.from(pickedImages),
        ),
      );
      _messageController.clear();
      ref.read(aiImagesProvider.notifier).state = [];
      ref.read(aiLoadingProvider.notifier).state = true;
    });

    _scrollToBottom();

    try {
      String responseText = "";
      final aiRepository = ref.read(aiRepositoryProvider);
      final selectedMode = ref.read(aiModeProvider);
      final selectedModel = ref.read(aiModelProvider);

      if (selectedMode == 'AI Model') {
        String modelType = "text";
        String modelId = "crm-di-qwen_text_14b-fp8-it";

        if (selectedModel.contains('Code Model')) {
          modelType = "code";
          modelId = "crm-di-qwen_coder_7b-it";
        } else if (selectedModel.contains('Vision Model')) {
          modelType = "vision";
          modelId = "VL-Qwen2.5-7B";
        }

        responseText = await aiRepository.getLlmAnswer(
          prompt: userMessage.isEmpty ? "What is in this image?" : userMessage,
          modelType: modelType,
          model: modelId,
          images: pickedImages.isNotEmpty ? pickedImages : null,
        );
      } else {
        List<String> documents = [];
        if (selectedModel == 'HR Bot') {
          documents = ["2492000000017183"];
        } else if (selectedModel == 'Vedanta') {
          documents = ["2492000000018094"];
        } else if (selectedModel == 'Finance Bot') {
          documents = ["2492000000017184"];
        }

        responseText = await aiRepository.getRagAnswer(
          query: userMessage,
          documents: documents,
        );
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: responseText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Error: Could not get a response. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } finally {
      ref.read(aiLoadingProvider.notifier).state = false;
      _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      final String base64Image = base64Encode(bytes);
      ref
          .read(aiImagesProvider.notifier)
          .update((state) => [...state, base64Image]);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    final theme = Theme.of(context);
    final selectedMode = ref.watch(aiModeProvider);
    final selectedModel = ref.watch(aiModelProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        toolbarHeight: 35.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text('DSV AI', style: theme.textTheme.titleMedium),
        // if needed can add the icon as well here
        // hook for info action
        // you can open a dialog or screen here
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, size: 18),
            onSelected: (value) {
              // Direct selection logic if needed, but we'll use submenus
              // or handle the provider updates in the itemBuilder if they're final selections
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(
                    "AI MODELS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                ..._aiModels.map(
                  (model) => PopupMenuItem<String>(
                    value: 'model:$model',
                    child: Text(model, style: const TextStyle(fontSize: 13)),
                    onTap: () {
                      ref.read(aiModeProvider.notifier).state = 'AI Model';
                      ref.read(aiModelProvider.notifier).state = model;
                    },
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(
                    "RAG BOTS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                ..._ragBots.map(
                  (bot) => PopupMenuItem<String>(
                    value: 'bot:$bot',
                    child: Text(bot, style: const TextStyle(fontSize: 13)),
                    onTap: () {
                      ref.read(aiModeProvider.notifier).state = 'RAG Bot';
                      ref.read(aiModelProvider.notifier).state = bot;
                    },
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      // backgroundColor: const Color(0xFF0F0F11),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.0),

            /// HEADER SECTION
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563eb), Color(0xFF4f46e5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Talk to DSV AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Connected to $selectedModel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            /// CHAT AREA
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start a conversation',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : Consumer(
                      builder: (context, ref, child) {
                        final isLoading = ref.watch(aiLoadingProvider);
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length && isLoading) {
                              return const _ChatBubble(isLoading: true);
                            }
                            return _ChatBubble(message: _messages[index]);
                          },
                        );
                      },
                    ),
            ),

            const Divider(
              height: 1,
              thickness: 1,
              color: Color.fromARGB(255, 125, 125, 125),
            ),

            /// INPUT SECTION
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Image Previews
                  Consumer(
                    builder: (context, ref, child) {
                      final images = ref.watch(aiImagesProvider);
                      if (images.isEmpty) return const SizedBox();
                      return Container(
                        height: 80,
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      base64Decode(images[index]),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(aiImagesProvider.notifier)
                                            .update(
                                              (state) =>
                                                  [...state]..removeAt(index),
                                            );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: CustomInputField(
                          controller: _messageController,
                          hintText: selectedMode == 'AI Model'
                              ? 'Enter prompt for AI model...'
                              : 'Enter prompt for RAG bot...',
                          isMultiline: true,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.send,
                          focusedBorderColor: const Color(0xFF2563eb),
                          onFieldSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      // Image Picker Button
                      if (selectedModel.contains('Vision Model'))
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563eb),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.white,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          final isLoading = ref.watch(aiLoadingProvider);
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563eb),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isLoading ? null : _sendMessage,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? images;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.images,
  });
}

class _ChatBubble extends ConsumerWidget {
  final ChatMessage? message;
  final bool isLoading;

  const _ChatBubble({this.message, this.isLoading = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isUser = message?.isUser ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2563eb).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 18,
                color: Color(0xFF2563eb),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF2563eb)
                    : const Color(0xFF1F1F1F),
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF2563eb), Color(0xFF4f46e5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message?.images != null &&
                            message!.images!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: message!.images!.map((img) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(img),
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        if (message?.text != null && message!.text.isNotEmpty)
                          Text(
                            message!.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2563eb).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Color(0xFF2563eb),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
