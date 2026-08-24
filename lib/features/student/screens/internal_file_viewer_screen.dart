import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/learning_content_service.dart';
import '../widgets/internal_web_html_viewer_stub.dart'
    if (dart.library.html) '../widgets/internal_web_html_viewer_web.dart';

class InternalFileViewerScreen extends StatefulWidget {
  const InternalFileViewerScreen({
    super.key,
    required this.item,
    required this.isArabic,
  });

  final LearningItem item;
  final bool isArabic;

  @override
  State<InternalFileViewerScreen> createState() => _InternalFileViewerScreenState();
}

class _InternalFileViewerScreenState extends State<InternalFileViewerScreen> {
  WebViewController? _controller;
  bool _loading = true;
  bool _hasViewerError = false;
  int _webRefreshKey = 0;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _loading = false;
      return;
    }

    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF7FAFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _loading = false;
                _hasViewerError = true;
              });
            }
          },
        ),
      );

    _controller = controller;
    _loadController();
  }

  void _loadController() {
    final WebViewController? controller = _controller;
    if (controller == null) return;

    final String directUrl = _nativeDirectUrl(widget.item);
    if (directUrl.isNotEmpty) {
      final Uri? uri = Uri.tryParse(directUrl);
      if (uri != null) {
        controller.loadRequest(uri);
        return;
      }
    }

    controller.loadHtmlString(_htmlFor(widget.item), baseUrl: 'https://idrisschool.com/');
  }

  String _webDirectUrl(LearningItem item) {
    final String url = item.primaryUrl.trim();
    final String preview = item.previewUrl.trim().isNotEmpty ? item.previewUrl.trim() : _previewFor(item);

    // Flutter Web/FlutLab must not iframe raw PDFs or server viewer PDFs;
    // it uses the generated PDF.js/video HTML below so the file does not show
    // as a gray broken document icon.
    if (item.isPdf || item.isVideo || item.isImage) return '';

    if (_isYoutube(url)) return _youtubeEmbed(url);

    if (item.isOffice) {
      if (_isHttpUrl(preview) && preview.contains('view.officeapps.live.com')) return preview;
      if (_isHttpUrl(url)) return 'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(url)}';
    }

    if (_isHttpUrl(preview)) return preview;
    if (_isHttpUrl(url)) return url;
    return '';
  }

  String _nativeDirectUrl(LearningItem item) {
    final String url = item.primaryUrl.trim();
    final String preview = item.previewUrl.trim().isNotEmpty ? item.previewUrl.trim() : _previewFor(item);

    if (_isYoutube(url)) return _youtubeEmbed(url);

    // PDF stays inside the app but must use the server viewer with PDF.js as
    // the default renderer. Android WebView does not render raw PDFs reliably.
    if (item.isPdf && _isHttpUrl(preview)) return preview;

    if (item.isOffice) {
      if (_isHttpUrl(preview) && preview.contains('view.officeapps.live.com')) return preview;
      if (_isHttpUrl(url)) return 'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(url)}';
    }

    // Videos/images are loaded through our generated HTML so controls, errors
    // and CORS handling stay consistent in Android/iOS and in FlutLab preview.
    return '';
  }

  String _htmlFor(LearningItem item) {
    final String titleText = item.title(widget.isArabic).trim().isEmpty
        ? (widget.isArabic ? 'عرض المحتوى' : 'Content viewer')
        : item.title(widget.isArabic).trim();
    final String descriptionText = item.description(widget.isArabic).trim();
    final String title = _escape(titleText);
    final String description = _escape(descriptionText);
    final String url = item.primaryUrl.trim();
    final String preview = item.previewUrl.trim().isNotEmpty ? item.previewUrl.trim() : _previewFor(item);
    final bool isVideo = item.isVideo || item.contentType == 'videos' || item.contentType == 'online_recordings';
    final bool isImage = item.isImage;
    final bool isPdf = item.isPdf;
    final bool isOffice = item.isOffice;

    final String headerDescription = descriptionText.isEmpty
        ? ''
        : '<div class="description">${description.replaceAll('\n', '<br>')}</div>';

    String body;
    if (url.isEmpty && preview.isEmpty) {
      body = '<section class="info-card"><h2>$title</h2>$headerDescription</section>';
    } else if (_isYoutube(url)) {
      body = _iframeBody(_youtubeEmbed(url));
    } else if (isVideo && _isHttpUrl(url)) {
      body = _videoBody(url, _videoFallbackFor(item, preview));
    } else if (isPdf && (_isHttpUrl(url) || _isHttpUrl(preview))) {
      body = _pdfJsBody(url.isNotEmpty ? url : preview, preview);
    } else if (isImage && _isHttpUrl(url)) {
      body = '<img class="image" src="${_escape(url)}" alt="$title" />';
    } else if (isOffice && _isHttpUrl(url)) {
      body = _officeBody(url);
    } else if (_isHttpUrl(preview)) {
      body = _iframeBody(preview);
    } else if (_isHttpUrl(url)) {
      body = _iframeBody(url);
    } else {
      body = '<section class="info-card"><h2>$title</h2>$headerDescription</section>';
    }

    return '''<!DOCTYPE html>
<html lang="${widget.isArabic ? 'ar' : 'en'}" dir="${widget.isArabic ? 'rtl' : 'ltr'}">
<head>
<base href="https://idrisschool.com/">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover">
<style>
  html,body{margin:0;height:100%;background:#f7faff;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Tahoma,sans-serif;color:#081832;overflow:hidden;}
  .wrap{height:100%;display:flex;flex-direction:column;}
  .bar{padding:12px 14px;background:#ffffff;border-bottom:1px solid rgba(8,24,50,.08);font-weight:800;font-size:14px;line-height:1.35;}
  .description{margin-top:6px;color:#475569;font-size:12px;font-weight:600;line-height:1.6;white-space:normal;}
  .viewer{flex:1;position:relative;display:flex;align-items:center;justify-content:center;overflow:hidden;background:linear-gradient(135deg,#f7faff,#eef6ff);}
  iframe{width:100%;height:100%;border:0;background:#fff;display:block;}
  video{width:100%;height:100%;background:#000;outline:none;display:block;}
  .image{max-width:100%;max-height:100%;object-fit:contain;display:block;}
  .info-card{width:min(92%,720px);padding:24px;margin:18px;border-radius:24px;background:#fff;box-shadow:0 12px 30px rgba(8,24,50,.08);}
  .info-card h2{margin:0 0 10px;font-size:20px;line-height:1.35;color:#081832;}
  .notice{position:absolute;left:14px;right:14px;bottom:14px;padding:12px 14px;border-radius:16px;background:#fff;color:#334155;box-shadow:0 10px 28px rgba(8,24,50,.12);font-size:12px;font-weight:800;line-height:1.55;text-align:center;}
  .video-actions{position:absolute;left:14px;right:14px;top:14px;display:flex;gap:8px;justify-content:center;z-index:5;pointer-events:auto;}
  .video-actions button{border:0;border-radius:999px;background:#0b5bd3;color:#fff;padding:8px 12px;font-size:12px;font-weight:900;box-shadow:0 8px 22px rgba(8,24,50,.18);}
  .pdf-shell{width:100%;height:100%;display:flex;flex-direction:column;background:#e5e7eb;}
  .pdf-tools{display:flex;gap:7px;align-items:center;justify-content:center;flex-wrap:wrap;padding:8px;background:#fff;border-bottom:1px solid #dbe3ef;font-size:12px;font-weight:900;}
  .pdf-tools button{border:0;border-radius:999px;background:#0b5bd3;color:#fff;padding:7px 11px;font-weight:900;}
  .pdf-tools button:disabled{background:#94a3b8;}
  .pdf-stage{flex:1;overflow:auto;text-align:center;padding:10px;}
  .loader{font-size:13px;font-weight:900;color:#475569;padding:20px;text-align:center;}
  canvas{max-width:100%;height:auto;background:#fff;box-shadow:0 10px 22px rgba(8,24,50,.18);border-radius:6px;}
</style>
</head>
<body><div class="wrap"><div class="bar">$title$headerDescription</div><main class="viewer">$body</main></div></body></html>''';
  }

  String _iframeBody(String rawUrl) {
    final String src = _escape(rawUrl.trim());
    return '<iframe src="$src" allow="autoplay; encrypted-media; fullscreen; picture-in-picture; clipboard-read; clipboard-write" allowfullscreen></iframe>';
  }

  String _videoBody(String rawUrl, String fallbackUrl) {
    final String src = _escape(rawUrl.trim());
    final String fallback = fallbackUrl.trim();
    final bool hasFallback = _isHttpUrl(fallback) && fallback != rawUrl.trim();
    final String safeFallback = _escape(fallback);
    final String loading = widget.isArabic ? 'جاري تجهيز الفيديو...' : 'Preparing video...';
    final String failed = widget.isArabic
        ? 'الفيديو المباشر ما بدأ. سيتم تجربة مشغل Google Drive داخل التطبيق.'
        : 'The direct video did not start. Trying the Google Drive player inside the app.';
    final String retry = widget.isArabic ? 'تجربة التشغيل المباشر' : 'Try direct video';
    final String drive = widget.isArabic ? 'مشغل Google Drive' : 'Google Drive player';
    final String manual = widget.isArabic
        ? 'لو الفيديو ما اشتغل، اضغط زر مشغل Google Drive أو تحديث.'
        : 'If the video does not start, use Google Drive player or refresh.';
    final String fallbackFrame = hasFallback
        ? '<iframe id="driveFrame" src="$safeFallback" style="display:none" allow="autoplay; encrypted-media; fullscreen; picture-in-picture" allowfullscreen></iframe>'
        : '';
    final String fallbackButtons = hasFallback
        ? '<div class="video-actions"><button id="driveBtn" type="button">${_escape(drive)}</button><button id="retryBtn" type="button">${_escape(retry)}</button></div>'
        : '';
    return '''<video id="video" controls playsinline webkit-playsinline preload="metadata" src="$src"></video>$fallbackFrame
<div id="videoNotice" class="notice">${_escape(loading)}</div>$fallbackButtons
<script>
(function(){
  const v=document.getElementById('video');
  const n=document.getElementById('videoNotice');
  const f=document.getElementById('driveFrame');
  const driveBtn=document.getElementById('driveBtn');
  const retryBtn=document.getElementById('retryBtn');
  let switched=false;
  function hide(){n.style.display='none';}
  function showMessage(msg){n.textContent=msg;n.style.display='block';}
  function showDirect(){
    switched=false;
    if(f) f.style.display='none';
    v.style.display='block';
    try{v.load();}catch(e){}
    showMessage(${jsonEncode(loading)});
  }
  function showFallback(auto){
    if(!f){showMessage(${jsonEncode(manual)});return;}
    switched=true;
    try{v.pause();}catch(e){}
    v.style.display='none';
    f.style.display='block';
    showMessage(auto ? ${jsonEncode(failed)} : ${jsonEncode(drive)});
    setTimeout(function(){ hide(); }, 2600);
  }
  if(driveBtn) driveBtn.onclick=function(){showFallback(false);};
  if(retryBtn) retryBtn.onclick=showDirect;
  v.addEventListener('loadedmetadata', hide);
  v.addEventListener('canplay', hide);
  v.addEventListener('playing', hide);
  v.addEventListener('error', function(){showFallback(true);});
  setTimeout(function(){ if(!switched && v.readyState===0) showFallback(true); }, 9000);
})();
</script>''';
  }

  String _officeBody(String rawUrl) {
    final String office = 'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(rawUrl.trim())}';
    return _iframeBody(office);
  }

  String _pdfJsBody(String rawUrl, String previewUrl) {
    final String fileUrl = rawUrl.trim();
    final String google = 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(fileUrl)}';
    final String loading = widget.isArabic ? 'جاري تحميل ملف PDF...' : 'Loading PDF...';
    final String failed = widget.isArabic
        ? 'تعذر عرض PDF عبر PDF.js. جرّب تحديث الصفحة أو عارض Google.'
        : 'PDF.js could not display the file. Try refresh or Google Viewer.';
    final String prev = widget.isArabic ? 'السابق' : 'Prev';
    final String next = widget.isArabic ? 'التالي' : 'Next';
    final String googleLabel = widget.isArabic ? 'عارض Google' : 'Google Viewer';
    final String pageLabel = widget.isArabic ? 'صفحة' : 'Page';
    final String ofLabel = widget.isArabic ? 'من' : 'of';

    return '''<div class="pdf-shell">
  <div class="pdf-tools">
    <button id="prevBtn" type="button">${_escape(prev)}</button>
    <span id="pageInfo">${_escape(pageLabel)} 1</span>
    <button id="nextBtn" type="button">${_escape(next)}</button>
    <button id="googleBtn" type="button">${_escape(googleLabel)}</button>
  </div>
  <div class="pdf-stage"><div id="status" class="loader">${_escape(loading)}</div><canvas id="pdfCanvas"></canvas><iframe id="googleFrame" src="${_escape(google)}" style="display:none" allowfullscreen></iframe></div>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
<script>
(function(){
  const fileUrl=${jsonEncode(fileUrl)};
  const failed=${jsonEncode(failed)};
  const pageWord=${jsonEncode(pageLabel)};
  const ofWord=${jsonEncode(ofLabel)};
  const status=document.getElementById('status');
  const canvas=document.getElementById('pdfCanvas');
  const ctx=canvas.getContext('2d');
  const info=document.getElementById('pageInfo');
  const prev=document.getElementById('prevBtn');
  const next=document.getElementById('nextBtn');
  const googleFrame=document.getElementById('googleFrame');
  let pdf=null,page=1,total=1,rendering=false,pending=null;
  function showGoogle(){ canvas.style.display='none'; status.style.display='none'; googleFrame.style.display='block'; googleFrame.style.width='100%'; googleFrame.style.height='100%'; }
  document.getElementById('googleBtn').onclick=showGoogle;
  function update(){ info.textContent=pageWord+' '+page+' '+ofWord+' '+total; prev.disabled=page<=1; next.disabled=page>=total; }
  function render(num){
    if(!pdf) return;
    if(rendering){ pending=num; return; }
    rendering=true; status.style.display='block'; status.textContent=${jsonEncode(loading)};
    pdf.getPage(num).then(function(p){
      const base=p.getViewport({scale:1});
      const stage=document.querySelector('.pdf-stage');
      const width=Math.max(280,stage.clientWidth-24);
      const scale=Math.min(2.4,Math.max(.7,width/base.width));
      const vp=p.getViewport({scale:scale});
      canvas.width=Math.floor(vp.width); canvas.height=Math.floor(vp.height);
      return p.render({canvasContext:ctx,viewport:vp}).promise;
    }).then(function(){
      status.style.display='none'; rendering=false; update();
      if(pending!==null){const x=pending; pending=null; render(x);}
    }).catch(function(e){ console.error(e); status.textContent=failed; rendering=false; });
  }
  prev.onclick=function(){ if(page>1){page--;render(page);} };
  next.onclick=function(){ if(page<total){page++;render(page);} };
  try{
    pdfjsLib.GlobalWorkerOptions.workerSrc='https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';
    pdfjsLib.getDocument({url:fileUrl,withCredentials:false,disableRange:false,disableStream:false}).promise.then(function(doc){pdf=doc;total=doc.numPages||1;update();render(page);}).catch(function(e){ console.error(e); status.textContent=failed; });
  } catch(e){ console.error(e); status.textContent=failed; }
})();
</script>''';
  }

  String _videoFallbackFor(LearningItem item, String previewUrl) {
    final String driveId = item.driveFileId.trim().isNotEmpty ? item.driveFileId.trim() : _extractDriveFileId(item.primaryUrl.trim());
    if (driveId.isNotEmpty) {
      return 'https://drive.google.com/file/d/${Uri.encodeComponent(driveId)}/preview';
    }
    if (_isHttpUrl(previewUrl) && previewUrl.trim() != item.primaryUrl.trim()) return previewUrl.trim();
    return '';
  }

  String _previewFor(LearningItem item) {
    final String url = item.primaryUrl.trim();
    if (url.isEmpty) return '';

    // Server viewer is preferred when the API already supplied one because it
    // keeps private Google Drive files protected by the platform session token.
    if (item.previewUrl.trim().isNotEmpty) return item.previewUrl.trim();

    final String driveId = item.driveFileId.trim().isNotEmpty ? item.driveFileId.trim() : _extractDriveFileId(url);
    if (driveId.isNotEmpty) {
      return 'https://drive.google.com/file/d/${Uri.encodeComponent(driveId)}/preview';
    }

    if (item.isPdf) {
      return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}';
    }

    if (item.isOffice) {
      return 'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(url)}';
    }
    return url;
  }

  String _extractDriveFileId(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return '';
    final String queryId = uri.queryParameters['id'] ?? '';
    if (queryId.isNotEmpty) return queryId;
    final List<String> parts = uri.pathSegments;
    for (int i = 0; i < parts.length - 1; i++) {
      if (parts[i] == 'd' && parts[i + 1].trim().isNotEmpty) return parts[i + 1];
    }
    return '';
  }

  bool _isYoutube(String url) {
    final String lower = url.toLowerCase();
    return lower.contains('youtube.com/watch') || lower.contains('youtu.be/') || lower.contains('youtube.com/embed/');
  }

  bool _isHttpUrl(String url) {
    final String lower = url.toLowerCase();
    return lower.startsWith('https://') || lower.startsWith('http://');
  }

  String _youtubeEmbed(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.host.contains('youtu.be')) {
      final String id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      return id.isEmpty ? url : 'https://www.youtube.com/embed/$id';
    }
    if (uri.path.contains('/embed/')) return url;
    final String id = uri.queryParameters['v'] ?? '';
    return id.isEmpty ? url : 'https://www.youtube.com/embed/$id';
  }

  String _escape(String value) => const HtmlEscape().convert(value);

  void _refresh() {
    setState(() {
      _loading = !kIsWeb;
      _hasViewerError = false;
      if (kIsWeb) _webRefreshKey++;
    });

    if (!kIsWeb) _loadController();
  }

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final String webUrl = _webDirectUrl(widget.item);
    final Widget viewer = kIsWeb
        ? InternalWebHtmlViewer(key: ValueKey<int>(_webRefreshKey), html: _htmlFor(widget.item), url: webUrl.isEmpty ? null : webUrl)
        : WebViewWidget(controller: _controller!);

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.navy950,
          elevation: 0,
          title: Text(
            widget.item.title(widget.isArabic),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: r.sp(16), fontWeight: FontWeight.w900),
          ),
          actions: [
            IconButton(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: widget.isArabic ? 'تحديث' : 'Refresh',
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(child: viewer),
            if (_hasViewerError)
              Positioned(
                left: r.s(14),
                right: r.s(14),
                bottom: r.s(14),
                child: Container(
                  padding: EdgeInsets.all(r.s(12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(r.radius(18)),
                    boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.08), blurRadius: r.s(18), offset: Offset(0, r.s(8)))],
                  ),
                  child: Text(
                    widget.isArabic
                        ? 'لو الملف ما ظهر اضغط تحديث. تم تحويل PDF إلى PDF.js والفيديو إلى مشغل داخلي مباشر.'
                        : 'If the file does not appear, tap refresh. PDF now uses PDF.js and video uses an internal player.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.navy700, fontSize: r.sp(12.5), fontWeight: FontWeight.w800, height: 1.5),
                  ),
                ),
              ),
            if (_loading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x88F7FAFF),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
