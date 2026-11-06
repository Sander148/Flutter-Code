import 'package:flutter/material.dart';

import 'habi_colors.dart';
import 'habi_nav_bar.dart';

class _SentMessage {
  const _SentMessage({required this.topic, required this.text});

  final String topic;
  final String text;
}

// Messages sent in this session.
// TODO (backend): send these to the support team and load the replies.
final List<_SentMessage> _sent = [];

/// Support: ask customer service or ask about the app.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key, required this.userName});

  final String userName;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const _topics = [
    'Using the app',
    'My account',
    'A job I posted',
    'A job I applied for',
    'Training',
    'Something else',
  ];

  static const _faqs = [
    [
      'How do I apply for a job?',
      'Open a job from Home or the Jobs tab, then tap Apply Now and confirm.',
    ],
    [
      'How do I post a job?',
      'Tap the round HABI button in the bottom bar and fill in the form.',
    ],
    [
      'How do I edit or delete my job?',
      'On a job you posted, tap the three dots and choose Edit or Delete.',
    ],
  ];

  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();
  String _topic = _topics.first;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _sent.insert(
        0,
        _SentMessage(topic: _topic, text: _message.text.trim()),
      );
      _message.clear();
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Message sent. Our team will reply soon.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: HabiColors.navyLight,
        ),
      );
  }

  InputDecoration _dec(String label, {String? hint}) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(color: HabiColors.cream.withAlpha(170)),
      floatingLabelStyle: const TextStyle(color: HabiColors.gold),
      hintStyle: TextStyle(color: HabiColors.cream.withAlpha(110)),
      filled: true,
      fillColor: HabiColors.navy.withAlpha(200),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(HabiColors.cream.withAlpha(70)),
      focusedBorder: border(HabiColors.gold),
      errorBorder: border(const Color(0xFFE5766B)),
      focusedErrorBorder: border(const Color(0xFFE5766B)),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: HabiColors.navy.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HabiColors.cream.withAlpha(60)),
      );

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabiColors.navy,
      appBar: AppBar(
        backgroundColor: HabiColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Support',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/habi_bg.jpg', fit: BoxFit.cover),
          Container(color: HabiColors.navy.withAlpha(225)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We are here to help you succeed.',
                    style: TextStyle(
                      fontSize: 14,
                      color: HabiColors.cream.withAlpha(210),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildForm(),
                  if (_sent.isNotEmpty) ...[
                    _heading('Your messages'),
                    for (final m in _sent) _buildSent(m),
                  ],
                  _heading('Common questions'),
                  _buildFaqs(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HabiNavBar(userName: widget.userName),
    );
  }

  Widget _buildForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.support_agent, color: HabiColors.gold),
                SizedBox(width: 10),
                Text(
                  'Ask our team',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _topic,
              isExpanded: true,
              dropdownColor: HabiColors.navyMid,
              iconEnabledColor: HabiColors.cream,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _dec('Topic'),
              items: [
                for (final t in _topics)
                  DropdownMenuItem(value: t, child: Text(t)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _topic = v);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _message,
              minLines: 4,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white),
              cursorColor: HabiColors.gold,
              decoration: _dec('Your message', hint: 'How can we help?'),
              validator: (v) {
                if ((v?.trim().length ?? 0) < 10) {
                  return 'Please write at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _send,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE2BB6C),
                  foregroundColor: HabiColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Send Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSent(_SentMessage m) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  m.topic,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: HabiColors.goldDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Waiting for reply',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            m.text,
            style: TextStyle(
              fontSize: 14,
              color: HabiColors.cream.withAlpha(220),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqs() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: _cardDecoration,
        child: Column(
          children: [
            for (final faq in _faqs)
              ExpansionTile(
                iconColor: HabiColors.gold,
                collapsedIconColor: HabiColors.cream,
                textColor: Colors.white,
                collapsedTextColor: Colors.white,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(
                  faq[0],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  Text(
                    faq[1],
                    style: TextStyle(
                      fontSize: 14,
                      color: HabiColors.cream.withAlpha(220),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}