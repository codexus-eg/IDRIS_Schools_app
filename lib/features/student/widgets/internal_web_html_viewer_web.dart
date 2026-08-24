// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

class InternalWebHtmlViewer extends StatefulWidget {
  const InternalWebHtmlViewer({
    super.key,
    required this.html,
    this.url,
  });

  final String html;
  final String? url;

  @override
  State<InternalWebHtmlViewer> createState() => _InternalWebHtmlViewerState();
}

class _InternalWebHtmlViewerState extends State<InternalWebHtmlViewer> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'idris-internal-html-viewer-${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final html.IFrameElement iframe = html.IFrameElement()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block'
        ..allow = 'autoplay; fullscreen; encrypted-media; picture-in-picture; clipboard-read; clipboard-write'
        ..setAttribute('allowfullscreen', 'true')
        ..setAttribute('referrerpolicy', 'no-referrer-when-downgrade');

      final String directUrl = (widget.url ?? '').trim();
      if (directUrl.isNotEmpty) {
        iframe.src = directUrl;
      } else {
        iframe.srcdoc = widget.html;
      }

      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
