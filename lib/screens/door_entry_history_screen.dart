import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class DoorEntryHistoryScreen extends StatefulWidget {
  final List<DoorEntryModel> entries;
  const DoorEntryHistoryScreen({super.key, required this.entries});

  @override
  State<DoorEntryHistoryScreen> createState() => _DoorEntryHistoryScreenState();
}

class _DoorEntryHistoryScreenState extends State<DoorEntryHistoryScreen> {
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  List<DoorEntryModel> get _filtered {
    if (_fromTime == null && _toTime == null) return widget.entries;
    return widget.entries.where((e) {
      final timeStr = e.time.length > 5 ? e.time.substring(6) : e.time;
      final parts = timeStr.split(':');
      if (parts.length < 2) return true;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final entryMinutes = hour * 60 + minute;
      if (_fromTime != null) {
        final fromMinutes = _fromTime!.hour * 60 + _fromTime!.minute;
        if (entryMinutes < fromMinutes) return false;
      }
      if (_toTime != null) {
        final toMinutes = _toTime!.hour * 60 + _toTime!.minute;
        if (entryMinutes > toMinutes) return false;
      }
      return true;
    }).toList();
  }

  Map<String, List<DoorEntryModel>> _groupByDate(List<DoorEntryModel> list) {
    final Map<String, List<DoorEntryModel>> grouped = {};
    for (final e in list) {
      final date = e.time.length >= 5 ? e.time.substring(0, 5) : e.time;
      grouped.putIfAbsent(date, () => []).add(e);
    }
    return grouped;
  }

  Future<void> _showReportDialog(DoorEntryModel e) async {
    final reasonCtrl = TextEditingController();
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('관리자에게 신고', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.name, style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(e.phone, style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                  Text(e.email, style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              style: const TextStyle(fontFamily: 'Pretendard'),
              decoration: const InputDecoration(hintText: '신고 사유 입력'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('취소', style: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('신고', style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final token = await AuthService.getToken();
      if (token == null) return;
      final content = '[출입 신고]\n이름: ${e.name}\n전화번호: ${e.phone}\n이메일: ${e.email}\n시간: ${e.time}\n사유: ${reasonCtrl.text.trim()}';
      final ok = await ApiService.createInquiry(token, '신고', content);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? '신고가 접수됐어요' : '신고 접수에 실패했어요', style: const TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
          backgroundColor: ok ? KColors.navy : const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;
    final grouped = _groupByDate(filtered);
    final dates = grouped.keys.toList();
    final totalSuccess = filtered.where((e) => e.isSuccess).length;
    final totalDenied = filtered.length - totalSuccess;

    return Scaffold(
      backgroundColor: isDark ? cs.surface : const Color(0xFFF5F5F3),
      appBar: AppBar(
        backgroundColor: isDark ? cs.surface : const Color(0xFFF5F5F3),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.arrow_back, color: cs.onSurface, size: 18),
          ),
        ),
        title: Text('출입 내역', style: tt.titleMedium),
        centerTitle: true,
      ),
      body: widget.entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
                    child: Icon(Icons.sensor_door_outlined, size: 32, color: cs.onSurface.withValues(alpha: 0.2)),
                  ),
                  const SizedBox(height: 16),
                  Text('출입 기록이 없어요', style: tt.titleSmall),
                  const SizedBox(height: 6),
                  Text('QR 스캔 시 기록이 남아요', style: tt.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              itemCount: dates.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Column(
                    children: [
                      // 요약 카드
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outline)),
                        child: Row(
                          children: [
                            Expanded(child: _StatItem(label: '총 출입', value: '${filtered.length}', color: cs.onSurface, tt: tt)),
                            Container(width: 1, height: 36, color: cs.outline),
                            Expanded(child: _StatItem(label: '입장', value: '$totalSuccess', color: const Color(0xFF16A34A), tt: tt)),
                            Container(width: 1, height: 36, color: cs.outline),
                            Expanded(child: _StatItem(label: '거절', value: '$totalDenied', color: const Color(0xFFDC2626), tt: tt)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 시간 필터
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outline)),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final t = await showTimePicker(context: context, initialTime: _fromTime ?? const TimeOfDay(hour: 0, minute: 0));
                                  if (t != null) setState(() => _fromTime = t);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _fromTime != null ? KColors.primary.withValues(alpha: 0.08) : cs.onSurface.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _fromTime != null ? KColors.primary.withValues(alpha: 0.3) : cs.outline),
                                  ),
                                  child: Text(
                                    _fromTime != null ? _fromTime!.format(context) : '시작 시간',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600, color: _fromTime != null ? KColors.primary : cs.onSurface.withValues(alpha: 0.4)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text('~', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final t = await showTimePicker(context: context, initialTime: _toTime ?? const TimeOfDay(hour: 23, minute: 59));
                                  if (t != null) setState(() => _toTime = t);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _toTime != null ? KColors.primary.withValues(alpha: 0.08) : cs.onSurface.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _toTime != null ? KColors.primary.withValues(alpha: 0.3) : cs.outline),
                                  ),
                                  child: Text(
                                    _toTime != null ? _toTime!.format(context) : '종료 시간',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600, color: _toTime != null ? KColors.primary : cs.onSurface.withValues(alpha: 0.4)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            if (_fromTime != null || _toTime != null) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() { _fromTime = null; _toTime = null; }),
                                child: Icon(Icons.close, size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                }

                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text('해당 시간대 출입 기록이 없어요', style: tt.bodySmall)),
                  );
                }

                final date = dates[i - 1];
                final dayEntries = grouped[date]!;
                final successCount = dayEntries.where((e) => e.isSuccess).length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                        child: Row(
                          children: [
                            Text(date, style: tt.titleSmall),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: KColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                              child: Text('입장 $successCount', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w600, color: KColors.primary)),
                            ),
                            const Spacer(),
                            Text('총 ${dayEntries.length}건', style: tt.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outline)),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dayEntries.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: cs.outline, indent: 64, endIndent: 16),
                          itemBuilder: (_, j) {
                            final e = dayEntries[j];
                            final isSuccess = e.isSuccess;
                            final time = e.time.length > 5 ? e.time.substring(6) : e.time;
                            return InkWell(
                              onLongPress: () => _showReportDialog(e),
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: isSuccess ? const Color(0xFF22C55E).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(isSuccess ? Icons.lock_open_rounded : Icons.lock_rounded, size: 16, color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.name, style: tt.labelLarge),
                                          const SizedBox(height: 2),
                                          Text(e.phone, style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.45), fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(time, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.5))),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isSuccess ? const Color(0xFF22C55E).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isSuccess ? '입장' : '거절',
                                            style: TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w700, color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final TextTheme tt;
  const _StatItem({required this.label, required this.value, required this.color, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontFamily: 'Pretendard', fontSize: 22, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(label, style: tt.bodySmall),
      ],
    );
  }
}
