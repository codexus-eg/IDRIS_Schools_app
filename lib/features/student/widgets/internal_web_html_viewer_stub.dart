import 'package:flutter/material.dart';

class InternalWebHtmlViewer extends StatelessWidget {
  const InternalWebHtmlViewer({
    super.key,
    required this.html,
    this.url,
  });

  final String html;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
