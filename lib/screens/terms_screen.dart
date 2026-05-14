import 'package:flutter/material.dart';
import '../app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                  Text('이용약관', style: tt.titleMedium),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outline)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section(context, '제1조 (목적)', '본 약관은 키오패스(이하 "회사")가 제공하는 바코드 스캔 쇼핑 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.'),
                      _section(context, '제2조 (정의)', '① "서비스"란 회사가 제공하는 바코드 스캔 기반 쇼핑 플랫폼 및 관련 제반 서비스를 의미합니다.\n② "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 말합니다.'),
                      _section(context, '제3조 (약관의 효력 및 변경)', '① 본 약관은 서비스를 이용하고자 하는 모든 이용자에게 적용됩니다.\n② 회사는 합리적인 사유가 발생할 경우 관련 법령에 위배되지 않는 범위 내에서 본 약관을 변경할 수 있습니다.'),
                      _section(context, '제4조 (서비스 이용)', '① 서비스 이용은 회사의 업무상 또는 기술상 특별한 지장이 없는 한 연중무휴 1일 24시간을 원칙으로 합니다.\n② 회사는 서비스를 일정 범위로 분할하여 각 범위별로 이용 가능한 시간을 별도로 정할 수 있으며, 이 경우 그 내용을 사전에 공지합니다.'),
                      _section(context, '제5조 (개인정보 보호)', '① 회사는 이용자의 개인정보를 보호하기 위해 개인정보처리방침을 수립하고 이를 준수합니다.\n② 회사는 이용자의 동의 없이 개인정보를 제3자에게 제공하지 않습니다.'),
                      _section(context, '제6조 (결제 및 환불)', '① 서비스를 통한 결제는 카카오페이, 토스페이, 신용카드 등을 통해 이루어집니다.\n② 결제 취소 및 환불은 관련 법령 및 각 결제 수단의 정책에 따릅니다.'),
                      _section(context, '제7조 (책임 제한)', '① 회사는 천재지변, 전쟁 등 불가항력적 사유로 인한 서비스 중단에 대해 책임을 지지 않습니다.\n② 회사는 이용자의 귀책사유로 인한 서비스 이용 장애에 대해 책임을 지지 않습니다.'),
                      const SizedBox(height: 16),
                      Text('시행일: 2026년 1월 1일', style: tt.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(title, style: tt.titleSmall),
        ),
        Text(body, style: tt.bodyMedium?.copyWith(height: 1.7)),
      ],
    );
  }
}