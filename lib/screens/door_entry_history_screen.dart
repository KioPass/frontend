import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';

class DoorEntryHistoryScreen extends StatelessWidget {
  final List<DoorEntryModel> entries;
  const DoorEntryHistoryScreen({super.key, required this.entries});

  Map<String, List<DoorEntryModel>> _groupByDate() {
    final Map<String, List<DoorEntryModel>> grouped = {};
    for (final e in entries) {
      final date = e.time.length >= 5 ? e.time.substring(0, 5) : e.time; // "MM.dd"
      grouped.putIfAbsent(date, () => []).add(e);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final grouped = _groupByDate();
    final dates = grouped.keys.toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20),
          ),
        ),
        title: Text('출입 전체 내역', style: tt.titleMedium),
        centerTitle: true,
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensor_door_outlined, size: 48, color: cs.onSurface.withValues(alpha: 0.15)),
                  const SizedBox(height: 12),
                  Text('출입 기록이 없어요', style: tt.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: dates.length,
              itemBuilder: (_, i) {
                final date = dates[i];
                final dayEntries = grouped[date]!;
                final successCount = dayEntries.where((e) => e.isSuccess).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 날짜 헤더
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
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
                              '입장 $successCount건',
                              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w600, color: KColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 해당 날짜 항목들
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
                        separatorBuilder: (_, __) => Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                        itemBuilder: (_, j) {
                          final e = dayEntries[j];
                          final isSuccess = e.isSuccess;
                          final time = e.time.length > 5 ? e.time.substring(6) : e.time; // "HH:mm"
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 34, height: 34,
                                  decoration: BoxDecoration(
                                    color: isSuccess
                                        ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                                        : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isSuccess ? Icons.lock_open_rounded : Icons.lock_rounded,
                                    size: 15,
                                    color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.name, style: tt.labelLarge),
                                      const SizedBox(height: 2),
                                      Text(e.phone, style: tt.bodySmall),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(time, style: tt.bodySmall),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                                          fontWeight: FontWeight.w600,
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
                );
              },
            ),
    );
  }
}
