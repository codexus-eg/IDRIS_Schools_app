import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_user_session.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/learning_content_service.dart';
import '../services/online_discussion_service.dart';
import 'internal_file_viewer_screen.dart';

class OnlineDiscussionScreen extends StatefulWidget {
  const OnlineDiscussionScreen({super.key, required this.isArabic, required this.session});

  final bool isArabic;
  final AppUserSession session;

  @override
  State<OnlineDiscussionScreen> createState() => _OnlineDiscussionScreenState();
}

class _OnlineDiscussionScreenState extends State<OnlineDiscussionScreen> {
  final OnlineDiscussionService _service = OnlineDiscussionService();
  final TextEditingController _postController = TextEditingController();
  late Future<List<OnlineDiscussionPost>> _future;
  bool _sending = false;
  PlatformFile? _postFile;

  @override
  void initState() {
    super.initState();
    _future = _service.fetch(session: widget.session);
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _refresh() {
    final Future<List<OnlineDiscussionPost>> nextFuture = _service.fetch(session: widget.session);
    if (!mounted) return;
    setState(() {
      _future = nextFuture;
    });
  }

  Future<void> _pickPostFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) setState(() => _postFile = result.files.first);
  }

  Future<void> _sendPost() async {
    final String body = _postController.text.trim();
    if (body.isEmpty && _postFile == null) return;
    setState(() => _sending = true);
    try {
      await _service.addPost(session: widget.session, body: body, file: _postFile);
      _postController.clear();
      setState(() => _postFile = null);
      _refresh();
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.replaceFirst('Bad state: ', ''))));
  }

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.navy950,
          title: Text(widget.isArabic ? 'المناقشات' : 'Discussion'),
          actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded))],
        ),
        body: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: EdgeInsets.all(r.pagePadding),
            children: [
              _PostComposer(
                isArabic: widget.isArabic,
                controller: _postController,
                sending: _sending,
                file: _postFile,
                onPick: _pickPostFile,
                onRemoveFile: () => setState(() => _postFile = null),
                onSend: _sendPost,
              ),
              SizedBox(height: r.s(14)),
              FutureBuilder<List<OnlineDiscussionPost>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()));
                  if (snapshot.hasError) return _MessageCard(message: widget.isArabic ? 'تعذر تحميل المناقشات.' : 'Unable to load discussion.');
                  final List<OnlineDiscussionPost> posts = snapshot.data ?? [];
                  if (posts.isEmpty) return _MessageCard(message: widget.isArabic ? 'لا توجد منشورات حالياً.' : 'No posts yet.');
                  return Column(children: posts.map((post) => _PostCard(isArabic: widget.isArabic, session: widget.session, post: post, service: _service, onChanged: _refresh, onError: _showError)).toList());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostComposer extends StatelessWidget {
  const _PostComposer({required this.isArabic, required this.controller, required this.sending, required this.file, required this.onPick, required this.onRemoveFile, required this.onSend});
  final bool isArabic;
  final TextEditingController controller;
  final bool sending;
  final PlatformFile? file;
  final VoidCallback onPick;
  final VoidCallback onRemoveFile;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(r.s(14)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(24)), boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.05), blurRadius: r.s(18), offset: Offset(0, r.s(8)))], border: Border.all(color: AppColors.primaryBlue.withOpacity(.06))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(isArabic ? 'اكتب منشور جديد' : 'Create a new post', style: TextStyle(color: AppColors.navy950, fontSize: r.sp(15), fontWeight: FontWeight.w900)),
        SizedBox(height: r.s(10)),
        TextField(controller: controller, minLines: 3, maxLines: 6, decoration: InputDecoration(hintText: isArabic ? 'اكتب سؤالك أو مشاركتك...' : 'Write your question or post...', filled: true, fillColor: const Color(0xFFF7FAFF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18)), borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(.08))))),
        if (file != null) ...[
          SizedBox(height: r.s(8)),
          Chip(label: Text(file!.name, overflow: TextOverflow.ellipsis), onDeleted: onRemoveFile),
        ],
        SizedBox(height: r.s(10)),
        Row(children: [
          OutlinedButton.icon(onPressed: sending ? null : onPick, icon: const Icon(Icons.attach_file_rounded), label: Text(isArabic ? 'إرفاق' : 'Attach')),
          const Spacer(),
          ElevatedButton.icon(onPressed: sending ? null : onSend, icon: sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded), label: Text(isArabic ? 'نشر' : 'Post')),
        ]),
      ]),
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({required this.isArabic, required this.session, required this.post, required this.service, required this.onChanged, required this.onError});
  final bool isArabic;
  final AppUserSession session;
  final OnlineDiscussionPost post;
  final OnlineDiscussionService service;
  final VoidCallback onChanged;
  final ValueChanged<String> onError;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  final TextEditingController _replyController = TextEditingController();
  PlatformFile? _replyFile;
  bool _sending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _pickReplyFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) setState(() => _replyFile = result.files.first);
  }

  Future<void> _sendReply() async {
    final String body = _replyController.text.trim();
    if (body.isEmpty && _replyFile == null) return;
    setState(() => _sending = true);
    try {
      await widget.service.addComment(session: widget.session, postId: widget.post.id, body: body, file: _replyFile);
      _replyController.clear();
      setState(() => _replyFile = null);
      widget.onChanged();
    } catch (e) {
      widget.onError('$e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _openAttachment(String title, String url, String mime, String name) {
    if (url.trim().isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => InternalFileViewerScreen(item: LearningItem(id: 0, titleAr: title, titleEn: title, descriptionAr: name, descriptionEn: name, fileUrl: url, videoUrl: '', coverUrl: '', createdAt: '', contentType: 'online_discussion', mimeType: mime, originalName: name), isArabic: widget.isArabic)));
  }

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: r.s(14)),
      padding: EdgeInsets.all(r.s(14)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(24)), border: Border.all(color: AppColors.primaryBlue.withOpacity(.06)), boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.05), blurRadius: r.s(18), offset: Offset(0, r.s(8)))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(backgroundColor: AppColors.primaryBlue.withOpacity(.12), child: Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: r.s(18))),
          SizedBox(width: r.s(8)),
          Expanded(child: Text(widget.post.authorName, style: TextStyle(color: AppColors.navy950, fontSize: r.sp(14), fontWeight: FontWeight.w900))),
          Text(widget.post.createdAt, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(10.5), fontWeight: FontWeight.w700)),
        ]),
        if (widget.post.subjectName.isNotEmpty) Padding(padding: EdgeInsets.only(top: r.s(5)), child: Text(widget.post.subjectName, style: TextStyle(color: AppColors.schoolRed, fontSize: r.sp(12), fontWeight: FontWeight.w800))),
        SizedBox(height: r.s(10)),
        Text(widget.post.body, style: TextStyle(color: AppColors.navy900, fontSize: r.sp(14), height: 1.6, fontWeight: FontWeight.w600)),
        if (widget.post.attachmentUrl.isNotEmpty) Padding(padding: EdgeInsets.only(top: r.s(10)), child: OutlinedButton.icon(onPressed: () => _openAttachment(widget.post.subjectName.isEmpty ? 'Discussion attachment' : widget.post.subjectName, widget.post.attachmentUrl, widget.post.attachmentMime, widget.post.attachmentName), icon: const Icon(Icons.attachment_rounded), label: Text(widget.post.attachmentName.isEmpty ? (widget.isArabic ? 'فتح المرفق' : 'Open attachment') : widget.post.attachmentName))),
        if (widget.post.comments.isNotEmpty) ...[
          SizedBox(height: r.s(12)),
          ...widget.post.comments.map((c) => _CommentTile(comment: c, isArabic: widget.isArabic, onOpen: () => _openAttachment('Comment attachment', c.attachmentUrl, c.attachmentMime, c.attachmentName))),
        ],
        SizedBox(height: r.s(12)),
        TextField(controller: _replyController, minLines: 1, maxLines: 4, decoration: InputDecoration(hintText: widget.isArabic ? 'اكتب رد...' : 'Write a reply...', filled: true, fillColor: const Color(0xFFF7FAFF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(16)), borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(.08))))),
        if (_replyFile != null) Padding(padding: EdgeInsets.only(top: r.s(7)), child: Chip(label: Text(_replyFile!.name), onDeleted: () => setState(() => _replyFile = null))),
        SizedBox(height: r.s(8)),
        Row(children: [
          TextButton.icon(onPressed: _sending ? null : _pickReplyFile, icon: const Icon(Icons.attach_file_rounded), label: Text(widget.isArabic ? 'إرفاق' : 'Attach')),
          const Spacer(),
          ElevatedButton(onPressed: _sending ? null : _sendReply, child: Text(widget.isArabic ? 'رد' : 'Reply')),
        ]),
      ]),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.isArabic, required this.onOpen});
  final OnlineDiscussionComment comment;
  final bool isArabic;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      margin: EdgeInsets.only(top: r.s(8)),
      padding: EdgeInsets.all(r.s(10)),
      decoration: BoxDecoration(color: const Color(0xFFF7FAFF), borderRadius: BorderRadius.circular(r.radius(16))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(comment.authorName, style: TextStyle(color: AppColors.navy950, fontSize: r.sp(12.5), fontWeight: FontWeight.w900))), Text(comment.createdAt, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(10)))]),
        if (comment.body.isNotEmpty) Padding(padding: EdgeInsets.only(top: r.s(5)), child: Text(comment.body, style: TextStyle(color: AppColors.navy900, fontSize: r.sp(12.5), height: 1.5, fontWeight: FontWeight.w600))),
        if (comment.attachmentUrl.isNotEmpty) TextButton.icon(onPressed: onOpen, icon: const Icon(Icons.attachment_rounded), label: Text(comment.attachmentName.isEmpty ? (isArabic ? 'مرفق' : 'Attachment') : comment.attachmentName)),
      ]),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(width: double.infinity, padding: EdgeInsets.all(r.s(20)), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(22))), child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(14), fontWeight: FontWeight.w800)));
  }
}
