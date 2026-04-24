import 'package:flutter/material.dart';
import '../app_theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int? _openFaqIndex;
  final TextEditingController _inquiryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _inquiryKey = GlobalKey();
  bool _isSubmitted = false;
  String? _selectedCategory;

  // 더미 문의 내역
  final List<Map<String, dynamic>> _myInquiries = [
    {'category': '결제', 'content': '결제가 두 번 됐는데 환불 가능한가요?', 'date': '2026.04.18', 'status': '답변완료', 'answer': '안녕하세요, 키오패스입니다. 중복 결제 확인 후 환불 처리해드리겠습니다. 1~2 영업일 내 처리됩니다.'},
    {'category': '스캔', 'content': '바코드가 계속 인식이 안 돼요', 'date': '2026.04.15', 'status': '답변완료', 'answer': '카메라 권한을 다시 확인해주세요. 설정 > 키오패스 > 카메라 허용으로 변경해주시면 됩니다.'},
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {'icon': Icons.receipt_long_outlined, 'label': '결제', 'color': const Color(0xFF3182F6), 'bg': const Color(0xFFEFF6FF), 'category': '결제'},
    {'icon': Icons.qr_code_scanner_rounded, 'label': '스캔', 'color': const Color(0xFF03B26C), 'bg': const Color(0xFFF0FDF4), 'category': '스캔'},
    {'icon': Icons.storefront_outlined, 'label': '매장', 'color': KColors.primary, 'bg': const Color(0xFFFFF0ED), 'category': '매장'},
    {'icon': Icons.account_circle_outlined, 'label': '계정', 'color': const Color(0xFF8B5CF6), 'bg': const Color(0xFFF5F3FF), 'category': '계정'},
    {'icon': Icons.more_horiz_rounded, 'label': '기타', 'color': const Color(0xFF6B7280), 'bg': const Color(0xFFF3F4F6), 'category': '기타'},
  ];

  final List<String> _categories = ['결제', '스캔', '매장', '계정', '기타'];

  final List<Map<String, String>> _faqs = [
    {'q': '바코드가 인식이 안 돼요.', 'a': '카메라 렌즈가 깨끗한지 확인해주세요. 바코드를 네모 칸 안에 정확히 맞추고, 밝은 환경에서 시도해보세요.'},
    {'q': '주변 매장이 목록에 안 나와요.', 'a': '위치 권한이 허용되어 있는지 확인해주세요. 설정 → 개인정보 보호 → 위치 서비스 → 키오패스에서 허용으로 변경해주세요.'},
    {'q': '결제가 완료됐는데 내역이 없어요.', 'a': '결제 완료 후 내역 반영까지 최대 5분이 소요될 수 있어요. 앱을 재시작하거나 잠시 후 다시 확인해주세요.'},
    {'q': '판매자 계정으로 전환이 안 돼요.', 'a': '서류 인증이 완료되어야 판매자 모드를 사용할 수 있어요. 인증 처리에는 1~2 영업일이 소요돼요.'},
    {'q': '결제 취소는 어떻게 하나요?', 'a': '결제 내역 화면에서 해당 내역을 탭한 후 취소 요청을 할 수 있어요. 결제 후 24시간 이내에만 취소가 가능해요.'},
    {'q': '카카오/네이버 연동이 안 돼요.', 'a': '해당 앱이 설치되어 있는지 확인해주세요. 설치 후에도 안 되면 앱을 재시작하거나 재설치해보세요.'},
  ];

  @override
  void dispose() {
    _inquiryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToInquiry(String? category) {
    setState(() => _selectedCategory = category);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _inquiryKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, alignment: 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── SliverAppBar ──
          SliverAppBar(
            expandedHeight: 180,
            collapsedHeight: 60,
            pinned: true,
            backgroundColor: cs.surface,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: cs.surface,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          const Text('평일 09:00 ~ 18:00 운영 중', style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('무엇을\n도와드릴까요?', style: tt.displayLarge?.copyWith(height: 1.2, letterSpacing: -1.2)),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              title: const SizedBox.shrink(),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 빠른 문의 ──
                Container(
                  color: cs.surface,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('빠른 문의', style: tt.titleSmall),
                      const SizedBox(height: 14),
                      Row(
                        children: _quickActions.map((action) {
                          final color = action['color'] as Color;
                          final bg = action['bg'] as Color;
                          final category = action['category'] as String;
                          final isSelected = _selectedCategory == category;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _scrollToInquiry(category),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? color.withValues(alpha: 0.12) : (isDark ? cs.onSurface.withValues(alpha: 0.05) : bg),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent, width: 1.5),
                                ),
                                child: Column(
                                  children: [
                                    Icon(action['icon'] as IconData, color: color, size: 22),
                                    const SizedBox(height: 6),
                                    Text(
                                      action['label'] as String,
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        color: isSelected ? color : cs.onSurface.withValues(alpha: 0.6),
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── FAQ ──
                Container(
                  color: cs.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                        child: Row(
                          children: [
                            Text('자주 묻는 질문', style: tt.titleSmall),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: KColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text('${_faqs.length}', style: const TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      ...List.generate(_faqs.length, (i) {
                        final isOpen = _openFaqIndex == i;
                        return Column(
                          children: [
                            Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                            GestureDetector(
                              onTap: () => setState(() => _openFaqIndex = isOpen ? null : i),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Q', style: TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 13, fontWeight: FontWeight.w900)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(_faqs[i]['q']!, style: tt.bodyLarge?.copyWith(color: isOpen ? KColors.primary : cs.onSurface, fontWeight: FontWeight.w600)),
                                        ),
                                        AnimatedRotation(
                                          turns: isOpen ? 0.5 : 0,
                                          duration: const Duration(milliseconds: 200),
                                          child: Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurface.withValues(alpha: 0.4), size: 20),
                                        ),
                                      ],
                                    ),
                                    if (isOpen) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('A', style: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.35), fontSize: 13, fontWeight: FontWeight.w900)),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(_faqs[i]['a']!, style: tt.bodyMedium?.copyWith(height: 1.7))),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── 내 문의 내역 ──
                if (_myInquiries.isNotEmpty)
                  Container(
                    color: cs.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                          child: Row(
                            children: [
                              Text('내 문의 내역', style: tt.titleSmall),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: KColors.navy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                                child: Text('${_myInquiries.length}', style: TextStyle(fontFamily: 'Pretendard', color: KColors.navy, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                        ...List.generate(_myInquiries.length, (i) {
                          final inq = _myInquiries[i];
                          final isDone = inq['status'] == '답변완료';
                          return Column(
                            children: [
                              Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                              Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                  childrenPadding: EdgeInsets.zero,
                                  title: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6)),
                                        child: Text(inq['category'], style: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(inq['content'], style: tt.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Text(inq['date'], style: tt.bodySmall),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDone ? const Color(0xFF22C55E).withValues(alpha: 0.1) : KColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            inq['status'],
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              color: isDone ? const Color(0xFF16A34A) : KColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  children: isDone
                                      ? [
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: cs.onSurface.withValues(alpha: 0.04),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: cs.outline),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('A', style: TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 13, fontWeight: FontWeight.w900)),
                                                const SizedBox(width: 8),
                                                Expanded(child: Text(inq['answer'], style: tt.bodySmall?.copyWith(height: 1.6))),
                                              ],
                                            ),
                                          ),
                                        ]
                                      : [],
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // ── 1:1 문의 ──
                Container(
                  key: _inquiryKey,
                  color: cs.surface,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('1:1 문의', style: tt.titleSmall),
                          const Spacer(),
                          Text('영업일 1~2일 내 답변', style: tt.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isSubmitted)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(color: KColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.check_rounded, color: KColors.primary, size: 28),
                                ),
                                const SizedBox(height: 12),
                                Text('문의가 접수됐어요', style: tt.titleSmall),
                                const SizedBox(height: 4),
                                Text('빠르게 확인 후 답변 드릴게요', style: tt.bodySmall),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => setState(() { _isSubmitted = false; _inquiryController.clear(); _selectedCategory = null; }),
                                  child: const Text('다시 문의하기', style: TextStyle(fontFamily: 'Pretendard', color: KColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        Text('문의 유형', style: tt.labelLarge),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _categories.map((cat) {
                            final selected = _selectedCategory == cat;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedCategory = cat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected ? KColors.primary : cs.onSurface.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: selected ? KColors.primary : cs.outline),
                                ),
                                child: Text(cat, style: TextStyle(fontFamily: 'Pretendard', color: selected ? Colors.white : cs.onSurface.withValues(alpha: 0.6), fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),
                        Text('문의 내용', style: tt.labelLarge),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outline)),
                          child: TextField(
                            controller: _inquiryController,
                            maxLines: 5,
                            onChanged: (_) => setState(() {}),
                            style: tt.bodyLarge,
                            decoration: InputDecoration(
                              hintText: '문의 내용을 자세히 적어주세요',
                              hintStyle: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.3), fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _selectedCategory != null && _inquiryController.text.trim().isNotEmpty
                                ? () => setState(() => _isSubmitted = true)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KColors.navy,
                              disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.08),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: cs.onSurface.withValues(alpha: 0.3),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('문의 접수하기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}