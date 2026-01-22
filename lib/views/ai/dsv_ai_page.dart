import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:dsv360/repositories/ai_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dsv360/core/constants/app_colors.dart';

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

    final currentModels = selectedMode == 'AI Model' ? _aiModels : _ragBots;

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
        actions: [],
      ),
      // backgroundColor: const Color(0xFF0F0F11),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.0),

            /// HEADER SECTION
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563eb), Color(0xFF4f46e5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Talk to DSV AI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose AI model or RAG bot — Qwen text, coder, or vision',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// MODE SELECTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: _ModeButton(
                          label: 'AI Model',
                          isSelected: selectedMode == 'AI Model',
                          onTap: () {
                            ref.read(aiModeProvider.notifier).state =
                                'AI Model';
                            ref.read(aiModelProvider.notifier).state =
                                _aiModels.first;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModeButton(
                          label: 'RAG Bot',
                          isSelected: selectedMode == 'RAG Bot',
                          onTap: () {
                            ref.read(aiModeProvider.notifier).state = 'RAG Bot';
                            ref.read(aiModelProvider.notifier).state =
                                _ragBots.first;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// MODEL DROPDOWN
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: DropdownButton<String>(
                      value: selectedModel,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        color: Color(0xFF2563eb),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF2563eb),
                      ),
                      items: currentModels.map((model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(
                            model,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1F1F1F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(aiModelProvider.notifier).state = value;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFF2A2A2A)),

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
                      // Image Picker Button
                      if (selectedModel.contains('Vision Model'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F1F1F),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2563eb).withOpacity(0.3),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Color(0xFF2563eb),
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      Expanded(
                        child: CustomInputField(
                          controller: _messageController,
                          hintText: selectedMode == 'AI Model'
                              ? 'Enter prompt for selected AI model...'
                              : 'Enter prompt for selected RAG bot...',
                          isMultiline: true,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.send,
                          focusedBorderColor: const Color(0xFF2563eb),
                          onFieldSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final isLoading = ref.watch(aiLoadingProvider);
                          return Container(
                            width: 54,
                            height: 54,
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

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF2563eb)
                    : Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
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
