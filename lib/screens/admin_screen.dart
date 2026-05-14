import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<InquiryModel> _allInquiries = [];
  List<SellerApplicationModel> _applications = [];
  bool _loading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    _token = await AuthService.getToken();
    if (_token == null) {
      setState(() => _loading = false);
      return;
    }
    final results = await Future.wait([
      ApiService.getAdminInquiries(_token!),
      ApiService.getSellerApplications(_token!),
    ]);
    if (mounted) setState(() {
      _allInquiries = results[0] as List<InquiryModel>;
      _applications = results[1] as List<SellerApplicationModel>;
      _loading = false;
    });
  }

  List<InquiryModel> get _filteredInquiries {
    switch (_tabController.index) {
      case 1: return _allInquiries.where((e) => e.status == '답변대기').toList();
      case 2: return _allInquiries.where((e) => e.status == '답변완료').toList();
      default: return _allInquiries;
    }
  }

  int get _pendingCount => _allInquiries.where((e) => e.status == '답변대기').length;
  int get _pendingApplicationCount => _applications.where((e) => e.status == 'PENDING').length;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 앱바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('문의 관리', style: tt.titleMedium),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                        child: const Text('관리자', style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  if (_pendingCount > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: KColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text('미답변 $_pendingCount', style: const TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),

            // 탭바
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))]),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w500),
                labelColor: cs.onSurface,
                unselectedLabelColor: cs.onSurface.withValues(alpha: 0.4),
                tabs: [
                  const Tab(text: '전체'),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('답변대기'),
                        if (_pendingCount > 0) ...[
                          const SizedBox(width: 2),
                          Container(
                            width: 14, height: 14,
                            decoration: const BoxDecoration(color: KColors.primary, shape: BoxShape.circle),
                            child: Center(child: Text('$_pendingCount', style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900))),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: '답변완료'),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('판매자'),
                        if (_pendingApplicationCount > 0) ...[
                          const SizedBox(width: 2),
                          Container(
                            width: 14, height: 14,
                            decoration: const BoxDecoration(color: Color(0xFF8B5CF6), shape: BoxShape.circle),
                            child: Center(child: Text('$_pendingApplicationCount', style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900))),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _tabController.index == 3
                      ? _buildApplicationsTab()
                      : _filteredInquiries.isEmpty
                          ? _buildEmpty(context)
                          : RefreshIndicator(
                              onRefresh: _loadAll,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                                itemCount: _filteredInquiries.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (_, i) => _InquiryCard(
                                  inquiry: _filteredInquiries[i],
                                  token: _token!,
                                  onAnswered: _loadAll,
                                  onDeleted: _loadAll,
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsTab() {
    if (_applications.isEmpty) return _buildEmpty(context);
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: _applications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ApplicationCard(
          application: _applications[i],
          token: _token!,
          onUpdated: _loadAll,
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), shape: BoxShape.circle),
            child: Icon(Icons.inbox_outlined, color: cs.onSurface.withValues(alpha: 0.3), size: 30),
          ),
          const SizedBox(height: 12),
          Text('문의가 없어요', style: tt.titleSmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}

class _InquiryCard extends StatefulWidget {
  final InquiryModel inquiry;
  final String token;
  final VoidCallback onAnswered;
  final VoidCallback onDeleted;

  const _InquiryCard({required this.inquiry, required this.token, required this.onAnswered, required this.onDeleted});

  @override
  State<_InquiryCard> createState() => _InquiryCardState();
}

class _InquiryCardState extends State<_InquiryCard> {
  bool _expanded = false;
  final TextEditingController _answerController = TextEditingController();
  bool _submitting = false;
  bool _deleting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _deleteInquiry() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('문의 삭제', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700)),
        content: const Text('이 문의를 삭제할까요?', style: TextStyle(fontFamily: 'Pretendard')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소', style: TextStyle(fontFamily: 'Pretendard'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제', style: TextStyle(fontFamily: 'Pretendard', color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _deleting = true);
    final ok = await ApiService.adminDeleteInquiry(widget.token, widget.inquiry.id);
    if (!mounted) return;
    setState(() => _deleting = false);

    if (ok) {
      widget.onDeleted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제에 실패했어요.')));
    }
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) return;
    setState(() => _submitting = true);

    final ok = await ApiService.answerInquiry(widget.token, widget.inquiry.id, _answerController.text.trim());
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      widget.onAnswered();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('답변 등록에 실패했어요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isPending = widget.inquiry.status == '답변대기';

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPending ? KColors.primary.withValues(alpha: 0.3) : cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6)),
                        child: Text(widget.inquiry.category, style: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPending ? KColors.primary.withValues(alpha: 0.1) : const Color(0xFF22C55E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.inquiry.status,
                          style: TextStyle(fontFamily: 'Pretendard', color: isPending ? KColors.primary : const Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Spacer(),
                      _deleting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : GestureDetector(
                              onTap: _deleteInquiry,
                              child: Icon(Icons.delete_outline_rounded, size: 20, color: cs.onSurface.withValues(alpha: 0.35)),
                            ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurface.withValues(alpha: 0.4), size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.inquiry.content, style: tt.bodyLarge, maxLines: _expanded ? null : 2, overflow: _expanded ? null : TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 13, color: cs.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                      Text(widget.inquiry.userName.isNotEmpty ? widget.inquiry.userName : widget.inquiry.userEmail, style: tt.bodySmall),
                      const SizedBox(width: 10),
                      Text(widget.inquiry.createdAt, style: tt.bodySmall),
                    ],
                  ),
                ],
              ),
            ),

            if (_expanded) ...[
              Divider(height: 1, color: cs.outline),

              if (!isPending && widget.inquiry.answer != null)
                Container(
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('A', style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFF16A34A), fontSize: 13, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 6),
                          Text('답변 완료', style: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.4), fontSize: 11)),
                          if (widget.inquiry.answeredAt != null) ...[
                            const SizedBox(width: 6),
                            Text(widget.inquiry.answeredAt!, style: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.4), fontSize: 11)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.inquiry.answer!, style: tt.bodyMedium?.copyWith(height: 1.6)),
                    ],
                  ),
                ),

              if (isPending)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('답변 작성', style: tt.labelLarge),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outline),
                        ),
                        child: TextField(
                          controller: _answerController,
                          maxLines: 4,
                          onChanged: (_) => setState(() {}),
                          style: tt.bodyMedium,
                          decoration: InputDecoration(
                            hintText: '고객에게 답변할 내용을 입력해주세요',
                            hintStyle: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.3), fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _answerController.text.trim().isNotEmpty && !_submitting ? _submitAnswer : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KColors.primary,
                            disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.08),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _submitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('답변 등록', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 판매자 신청 카드 ───────────────────────────────────────────────────
class _ApplicationCard extends StatefulWidget {
  final SellerApplicationModel application;
  final String token;
  final VoidCallback onUpdated;

  const _ApplicationCard({required this.application, required this.token, required this.onUpdated});

  @override
  State<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<_ApplicationCard> {
  bool _expanded = false;
  bool _processing = false;

  Future<void> _approve() async {
    setState(() => _processing = true);
    final ok = await ApiService.approveSellerApplication(widget.token, widget.application.storeId);
    if (!mounted) return;
    setState(() => _processing = false);
    if (ok) {
      widget.onUpdated();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('판매자 승인 완료! 재로그인 시 적용됩니다.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('승인에 실패했어요.')));
    }
  }

  Future<void> _reject() async {
    setState(() => _processing = true);
    final ok = await ApiService.rejectSellerApplication(widget.token, widget.application.storeId);
    if (!mounted) return;
    setState(() => _processing = false);
    if (ok) {
      widget.onUpdated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('거절에 실패했어요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final status = widget.application.status;
    final isPending = status == 'PENDING';
    final isApproved = status == 'APPROVED';

    Color statusColor = isPending
        ? const Color(0xFFF59E0B)
        : isApproved
            ? const Color(0xFF16A34A)
            : const Color(0xFFEF4444);
    String statusLabel = isPending ? '심사중' : isApproved ? '승인됨' : '거절됨';

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPending ? const Color(0xFFF59E0B).withValues(alpha: 0.4) : cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(statusLabel, style: TextStyle(fontFamily: 'Pretendard', color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(widget.application.storeName, style: tt.titleSmall, overflow: TextOverflow.ellipsis)),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurface.withValues(alpha: 0.4), size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 13, color: cs.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                      Text(widget.application.userName.isNotEmpty ? widget.application.userName : widget.application.userEmail, style: tt.bodySmall),
                      const SizedBox(width: 10),
                      Icon(Icons.location_on_outlined, size: 13, color: cs.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(widget.application.address, style: tt.bodySmall, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(widget.application.appliedAt, style: tt.bodySmall),
                ],
              ),
            ),

            if (_expanded) ...[
              Divider(height: 1, color: cs.outline),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('제출 서류', style: tt.labelLarge),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _DocButton(
                          label: '사업자등록증',
                          icon: Icons.description_outlined,
                          url: widget.application.licenseUrl,
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _DocButton(
                          label: '영업신고증',
                          icon: Icons.article_outlined,
                          url: widget.application.reportUrl,
                        )),
                      ],
                    ),
                    if (isPending) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                onPressed: _processing ? null : _reject,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFEF4444)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('거절', style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _processing ? null : _approve,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _processing
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('승인', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 서류 보기 버튼 ─────────────────────────────────────────────────────
class _DocButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String url;

  const _DocButton({required this.label, required this.icon, required this.url});

  String get _fullUrl {
    if (url.startsWith('http')) return url;
    return '$kBaseUrl$url';
  }

  void _open(BuildContext context) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('파일이 없어요.')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _DocViewerDialog(label: label, url: _fullUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: KColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: KColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: KColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label, style: tt.bodySmall?.copyWith(color: KColors.primary, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            ),
            Icon(Icons.open_in_new_rounded, size: 13, color: KColors.primary.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _DocViewerDialog extends StatelessWidget {
  final String label;
  final String url;

  const _DocViewerDialog({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              child: Row(
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cs.outline),
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    headers: const {'ngrok-skip-browser-warning': 'true'},
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('이미지를 불러올 수 없어요', style: TextStyle(fontFamily: 'Pretendard', color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
