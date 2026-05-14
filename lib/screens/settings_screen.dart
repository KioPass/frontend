import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _paymentNoti = true;
  bool _eventNoti = false;
  bool _stockNoti = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                  Text('설정', style: tt.titleMedium),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    _section(context, '화면', [
                      _themeItem(context),
                    ]),
                    const SizedBox(height: 20),
                    _section(context, '알림', [
                      _toggleItem(context, Icons.notifications_rounded, '푸시 알림', '모든 알림을 받아요', _pushEnabled, (v) => setState(() { _pushEnabled = v; if (!v) { _paymentNoti = false; _eventNoti = false; _stockNoti = false; } })),
                      _toggleItem(context, Icons.receipt_outlined, '결제 알림', '결제 완료 시 알림', _paymentNoti && _pushEnabled, _pushEnabled ? (v) => setState(() => _paymentNoti = v) : null),
                      _toggleItem(context, Icons.campaign_outlined, '이벤트 알림', '혜택 및 이벤트 소식', _eventNoti && _pushEnabled, _pushEnabled ? (v) => setState(() => _eventNoti = v) : null),
                      _toggleItem(context, Icons.inventory_2_outlined, '재고 부족 알림', '재고 10개 이하 알림', _stockNoti && _pushEnabled, _pushEnabled ? (v) => setState(() => _stockNoti = v) : null),
                    ]),
                    const SizedBox(height: 20),
                    _section(context, '앱 정보', [
                      _infoItem(context, Icons.info_outline_rounded, '버전', '1.0.0'),
                      _infoItem(context, Icons.update_rounded, '최근 업데이트', '2026.01.01'),
                    ]),
                    const SizedBox(height: 20),
                    _section(context, '계정', [
                      _actionItem(context, Icons.delete_outline_rounded, '캐시 삭제', cs.onSurface.withValues(alpha: 0.5), () => _cacheDialog(context)),
                      _actionItem(context, Icons.person_off_outlined, '회원 탈퇴', const Color(0xFFEF4444), () => _withdrawDialog(context)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String label, List<Widget> items) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 10), child: Text(label, style: tt.bodySmall)),
        Container(
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outline)),
          child: Column(
            children: items.asMap().entries.map((e) => Column(
              children: [
                if (e.key != 0) Divider(height: 1, color: cs.outline, indent: 20, endIndent: 20),
                e.value,
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _themeItem(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        final options = [
          {'label': '시스템', 'mode': ThemeMode.system, 'icon': Icons.brightness_auto_rounded},
          {'label': '라이트', 'mode': ThemeMode.light, 'icon': Icons.wb_sunny_rounded},
          {'label': '다크', 'mode': ThemeMode.dark, 'icon': Icons.nightlight_rounded},
        ];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.contrast_rounded, color: cs.onSurface.withValues(alpha: 0.5), size: 20),
              const SizedBox(width: 12),
              Text('화면 모드', style: tt.bodyLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((opt) {
                    final selected = mode == opt['mode'];
                    return GestureDetector(
                      onTap: () => themeNotifier.value = opt['mode'] as ThemeMode,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? KColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              opt['icon'] as IconData,
                              size: 14,
                              color: selected ? Colors.white : cs.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              opt['label'] as String,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : cs.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _toggleItem(BuildContext context, IconData icon, String label, String desc, bool value, void Function(bool)? onChanged) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: cs.onSurface.withValues(alpha: onChanged != null ? 0.5 : 0.25), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodyLarge?.copyWith(color: cs.onSurface.withValues(alpha: onChanged != null ? 1 : 0.4))),
                Text(desc, style: tt.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: KColors.primary, trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? KColors.primary.withValues(alpha: 0.3) : cs.onSurface.withValues(alpha: 0.1))),
        ],
      ),
    );
  }

  Widget _infoItem(BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: cs.onSurface.withValues(alpha: 0.5), size: 20),
          const SizedBox(width: 12),
          Text(label, style: tt.bodyLarge),
          const Spacer(),
          Text(value, style: tt.bodySmall),
        ],
      ),
    );
  }

  Widget _actionItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontFamily: 'Pretendard', color: color, fontSize: 16, fontWeight: FontWeight.w400)),
            const Spacer(),
            Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha: 0.25), size: 20),
          ],
        ),
      ),
    );
  }

  void _cacheDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, color: cs.onSurface.withValues(alpha: 0.4), size: 40),
              const SizedBox(height: 12),
              Text('캐시를 삭제할까요?', style: tt.titleMedium),
              const SizedBox(height: 6),
              Text('저장된 임시 데이터가 삭제돼요', style: tt.bodySmall),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: SizedBox(height: 46, child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('취소', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700))))),
                  const SizedBox(width: 10),
                  Expanded(child: SizedBox(height: 46, child: ElevatedButton(onPressed: () async { final prefs = await SharedPreferences.getInstance(); await prefs.clear(); if (!context.mounted) return; Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('캐시가 삭제됐어요', style: TextStyle(fontFamily: 'Pretendard')), behavior: SnackBarBehavior.floating)); }, style: ElevatedButton.styleFrom(backgroundColor: KColors.navy, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('삭제', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700))))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _withdrawDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person_off_outlined, color: Color(0xFFEF4444), size: 26),
              ),
              const SizedBox(height: 12),
              Text('정말 탈퇴하시겠어요?', style: tt.titleMedium),
              const SizedBox(height: 6),
              Text('모든 데이터가 삭제되며\n복구가 불가능해요', style: tt.bodySmall?.copyWith(height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: SizedBox(height: 46, child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('취소', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700))))),
                  const SizedBox(width: 10),
                  Expanded(child: SizedBox(height: 46, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('탈퇴', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700))))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}