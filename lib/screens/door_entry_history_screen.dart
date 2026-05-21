import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';

class DoorEntryHistoryScreen extends StatelessWidget {
  final List<DoorEntryModel> entries;
  const DoorEntryHistoryScreen({super.key, required this.entries});

  Map<String, List<DoorEntryModel>> _groupByDate() {
    final Map<String, List<DoorEntryModel>> grouped = {};
    for (final e in entries) {
      final date = e.time.length >= 5 ? e.time.substring(0, 5) : e.time;
      grouped.putIfAbsent(date, () => []).add(e);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grouped = _groupByDate();
    final dates = grouped.keys.toList();
    final totalSuccess = entries.where((e) => e.isSuccess).length;
    final totalDenied = entries.length - totalSuccess;

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
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back, color: cs.onSurface, size: 18),
          ),
        ),
        title: Text('출입 내역', style: tt.titleMedium),
        centerTitle: true,
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                // 상단 요약 카드
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _StatItem(label: '총 출입', value: '${entries.length}', color: cs.onSurface, tt: tt)),
                          Container(width: 1, height: 36, color: cs.outline),
                          Expanded(child: _StatItem(label: '입장', value: '$totalSuccess', color: const Color(0xFF16A34A), tt: tt)),
                          Container(width: 1, height: 36, color: cs.outline),
                          Expanded(child: _StatItem(label: '거절', value: '$totalDenied', color: const Color(0xFFDC2626), tt: tt)),
                        ],
                      ),
                    ),
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
                      // 날짜 헤더
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                        child: Row(
                          children: [
                            Text(date, style: tt.titleSmall),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: KColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '입장 $successCount',
                                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w600, color: KColors.primary),
                              ),
                            ),
                            const Spacer(),
                            Text('총 ${dayEntries.length}건', style: tt.bodySmall),
                          ],
                        ),
                      ),
                      // 항목 리스트
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.outline),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dayEntries.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: cs.outline, indent: 64, endIndent: 16),
                          itemBuilder: (_, j) {
                            final e = dayEntries[j];
                            final isSuccess = e.isSuccess;
                            final time = e.time.length > 5 ? e.time.substring(6) : e.time;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              child: Row(
                                children: [
                                  // 아이콘
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: isSuccess
                                          ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                                          : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isSuccess ? Icons.lock_open_rounded : Icons.lock_rounded,
                                      size: 16,
                                      color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // 이름 + 전화번호
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(e.name, style: tt.labelLarge),
                                        const SizedBox(height: 2),
                                        Text(
                                          e.phone,
                                          style: tt.bodySmall?.copyWith(
                                            color: cs.onSurface.withValues(alpha: 0.45),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 시간 + 뱃지
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        time,
                                        style: tt.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isSuccess
                                              ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                                              : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isSuccess ? '입장' : '거절',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
