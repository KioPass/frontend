import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../app_theme.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'main_screen.dart';

class SellerVerifyScreen extends StatefulWidget {
  const SellerVerifyScreen({super.key});

  @override
  State<SellerVerifyScreen> createState() => _SellerVerifyScreenState();
}

class _SellerVerifyScreenState extends State<SellerVerifyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _bizImage;
  XFile? _licenseImage;

  bool get _canSubmit =>
      _nameController.text.isNotEmpty &&
      _addressController.text.isNotEmpty &&
      _bizImage != null &&
      _licenseImage != null;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isBiz) async {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // 카메라 / 갤러리 선택 바텀시트
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),

              // 카메라
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  if (img != null) setState(() => isBiz ? _bizImage = img : _licenseImage = img);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A52) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF3182F6), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('카메라로 촬영', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                          Text('지금 바로 서류를 촬영해요', style: tt.bodySmall),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.25), size: 20),
                    ],
                  ),
                ),
              ),

              Divider(height: 1, color: cs.outline, indent: 24, endIndent: 24),

              // 갤러리
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (img != null) setState(() => isBiz ? _bizImage = img : _licenseImage = img);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A52) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.photo_library_rounded, color: Color(0xFF03B26C), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('갤러리에서 선택', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                          Text('저장된 사진을 불러와요', style: tt.bodySmall),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.25), size: 20),
                    ],
                  ),
                ),
              ),

              // 취소 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: cs.onSurface.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('취소', style: TextStyle(fontFamily: 'Pretendard', color: cs.onSurface.withValues(alpha: 0.5), fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 앱바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('판매자 서류 인증', style: tt.displayLarge),
                    const SizedBox(height: 8),
                    Text('정확하고 안전한 매장 운영을 위해\n매장 정보와 증빙 서류를 입력해주세요', style: tt.bodyMedium?.copyWith(height: 1.6)),

                    const SizedBox(height: 24),

                    // 안내 박스
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: cs.onSurface.withValues(alpha: 0.4), size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text('서류 검토 후 1~2 영업일 내 승인 완료돼요', style: tt.bodySmall)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 상호명
                    _buildLabel(context, '상호명'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      style: tt.bodyLarge,
                      decoration: const InputDecoration(hintText: '사업자등록증 상의 상호명 입력'),
                    ),

                    const SizedBox(height: 20),

                    // 매장 주소
                    _buildLabel(context, '매장 주소'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      onChanged: (_) => setState(() {}),
                      style: tt.bodyLarge,
                      decoration: const InputDecoration(hintText: '매장 도로명 주소 입력'),
                    ),

                    const SizedBox(height: 28),

                    // 사업자등록증
                    _buildUploadSection(
                      context,
                      label: '사업자등록증 사본',
                      description: '사업자 등록번호와 대표자명이 잘 보이게 찍어주세요',
                      image: _bizImage,
                      onTap: () => _pickImage(true),
                      onRemove: () => setState(() => _bizImage = null),
                    ),

                    const SizedBox(height: 24),

                    // 영업신고증
                    _buildUploadSection(
                      context,
                      label: '영업신고증 사본',
                      description: '지자체(구청 등)에서 발급받은 영업신고증을 올려주세요',
                      image: _licenseImage,
                      onTap: () => _pickImage(false),
                      onRemove: () => setState(() => _licenseImage = null),
                    ),

                    const SizedBox(height: 40),

                    // 제출 버튼
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _canSubmit ? 1.0 : 0.4,
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _canSubmit
                              ? () async {
                                  // 상호명 저장
                                  await AuthService.saveStoreName(_nameController.text);
                                  if (!mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MainScreen()),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: KColors.primary.withValues(alpha: 0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('서류 제출 및 인증하기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(label, style: tt.titleSmall),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFFFE4E4), borderRadius: BorderRadius.circular(6)),
          child: const Text('필수', style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildUploadSection(
    BuildContext context, {
    required String label,
    required String description,
    required XFile? image,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final uploaded = image != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, label),
        const SizedBox(height: 4),
        Text(description, style: tt.bodySmall),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            height: uploaded ? 180 : 100,
            decoration: BoxDecoration(
              color: uploaded
                  ? Colors.transparent
                  : cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: uploaded ? KColors.primary : cs.outline,
                width: uploaded ? 1.5 : 1,
              ),
            ),
            child: uploaded
                ? Stack(
                    children: [
                      // 실제 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.file(
                          File(image!.path),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // 삭제 버튼
                      Positioned(
                        top: 8, right: 8,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      // 재촬영 버튼
                      Positioned(
                        bottom: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('재촬영', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: cs.onSurface.withValues(alpha: 0.3), size: 28),
                      const SizedBox(height: 8),
                      Text('터치하여 사진 업로드', style: tt.bodySmall),
                      const SizedBox(height: 2),
                      Text('카메라 촬영 또는 갤러리 선택', style: tt.bodySmall?.copyWith(fontSize: 11)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}