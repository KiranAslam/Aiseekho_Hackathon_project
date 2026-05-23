import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_chrome.dart';
import 'healthcare_flow_controller.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  final _messageController = TextEditingController();
  final _locationController = TextEditingController(
    text: AppConfig.defaultCity,
  );
  late final stt.SpeechToText _speech;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _speech.stop();
    _messageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceInput() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _listening = false);
      }
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) {
          return;
        }
        if (status == 'done' || status == 'notListening') {
          setState(() => _listening = false);
        }
      },
      onError: (error) {
        if (!mounted) {
          return;
        }
        setState(() => _listening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice input failed: ${error.errorMsg}')),
        );
      },
    );

    if (!available) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input is unavailable on this device.'),
        ),
      );
      return;
    }

    if (mounted) {
      setState(() => _listening = true);
    }

    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      ),
      onResult: (result) {
        if (!mounted || result.recognizedWords.trim().isEmpty) {
          return;
        }
        _messageController.text = result.recognizedWords;
        _messageController.selection = TextSelection.collapsed(
          offset: _messageController.text.length,
        );
      },
    );
  }

  void _submit() {
    final message = _messageController.text.trim();
    if (message.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Describe the healthcare issue in a little more detail.',
          ),
        ),
      );
      return;
    }
    ref
        .read(healthcareFlowProvider.notifier)
        .analyze(
          message: message,
          location: _locationController.text.trim().isEmpty
              ? AppConfig.defaultCity
              : _locationController.text.trim(),
        );
    context.go('/processing');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthcareFlowProvider);
    return AppScaffold(
      title: AppConfig.appName,
      actions: [
        IconButton(
          tooltip: 'Hospital intelligence',
          onPressed: () => context.push('/analytics'),
          icon: const Icon(Icons.insights_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What care do you need right now?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Type in English, Urdu, or Roman Urdu. Rahe-Sehat will coordinate the backend AI agents.',
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _messageController,
                  minLines: 5,
                  maxLines: 7,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Describe your healthcare problem...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 92),
                      child: Icon(Icons.chat_bubble_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'City or current area',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _messageController.text =
                              'Emergency chest pain, need nearest available hospital now.';
                          _submit();
                        },
                        icon: const Icon(
                          Icons.emergency_rounded,
                          color: AppColors.danger,
                        ),
                        label: const Text('Emergency'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      tooltip: _listening ? 'Stop voice input' : 'Voice input',
                      onPressed: _toggleVoiceInput,
                      style: IconButton.styleFrom(
                        backgroundColor: _listening
                            ? AppColors.danger.withValues(alpha: 0.18)
                            : null,
                        foregroundColor: _listening ? AppColors.danger : null,
                      ),
                      icon: Icon(
                        _listening ? Icons.stop_rounded : Icons.mic_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Analyze Request',
                  icon: Icons.psychology_alt_rounded,
                  loading: state.isAnalyzing,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _SuggestionChip(label: 'Chest pain'),
              _SuggestionChip(label: 'Fever'),
              _SuggestionChip(label: 'Accident'),
              _SuggestionChip(label: 'Child specialist'),
              _SuggestionChip(label: 'Saans ka masla'),
            ],
          ),
          const SizedBox(height: 20),
          if (state.error != null)
            StateMessage(
              title: 'Backend connection needed',
              message: state.error!,
              icon: Icons.cloud_off_rounded,
            ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
      label: Text(label),
      side: BorderSide.none,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.55),
    );
  }
}
