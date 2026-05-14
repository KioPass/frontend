import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:kpostal/kpostal.dart';
import 'dart:io';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'main_screen.dart';

class SellerVerifyScreen extends StatefulWidget {
  const SellerVerifyScreen({super.key});

  @override
  State<SellerVerifyScreen> createState() => _SellerVerifyScreenState();
}

class _SellerVerifyScreenState extends State<SellerVerifyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();
  final TextEditingController _bizNumberController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);

  XFile? _bizImage;
  XFile? _licenseImage;
  bool _isOcrLoading = false;
  bool _isSubmitting = false;
  String? _bizVerifyStatus;
  String? _bizVerifyMessage;

  bool get _canSubmit =>
      _nameController.text.isNotEmpty &&
      _addressController.text.isNotEmpty &&
      _bizNumberController.text.isNotEmpty &&
      _bizImage != null &&
      _licenseImage != null &&
      _bizVerifyStatus == 'verified' &&
      !_isSubmitting;

  Future<void> _submit() async {
    final token = await AuthService.getToken();
    if (token == null) {
      _showError('인증 정보가 없어요. 다시 로그인해주세요.');
      return;
    }
    final fullAddress = _detailAddressController.text.isNotEmpty
        ? '${_addressController.text} ${_detailAddressController.text}'
        : _addressController.text;

    setState(() => _isSubmitting = true);
    try {
      final success = await ApiService.upgradeToSeller(
        token: token,
        storename: _nameController.text,
        address: fullAddress,
        bizImagePath: _bizImage!.path,
        licenseImagePath: _licenseImage!.path,
      );
      if (!mounted) return;
      if (success) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _PendingDialog(storeName: _nameController.text),
        );
      } else {
        _showError('서류 제출에 실패했어요. 다시 시도해주세요.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Pretendard')),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _bizNumberController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  bool _isValidBizNumber(String number) {
    final cleaned = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 10) return false;
    final checkArr = [1, 3, 7, 1, 3, 7, 1, 3, 5];
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleaned[i]) * checkArr[i];
    }
    sum += (int.parse(cleaned[8]) * 5) ~/ 10;
    return (10 - (sum % 10)) % 10 == int.parse(cleaned[9]);
  }

  String _formatBizNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length <= 3) return cleaned;
    if (cleaned.length <= 5) return '${cleaned.substring(0, 3)}-${cleaned.substring(3)}';
    return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 5)}-${cleaned.substring(5, cleaned.length.clamp(0, 10))}';
  }

  // ML Kit OCR - 사업자등록번호만 추출
  Future<void> _extractBizNumber(XFile imageFile) async {
    if (!mounted) return;
    setState(() { _isOcrLoading = true; _bizVerifyStatus = null; });
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final bizNumRegex = RegExp(r'\d{3}-?\d{2}-?\d{5}');
      String? foundNumber;

      for (final block in recognizedText.blocks) {
        final match = bizNumRegex.firstMatch(block.text);
        if (match != null) {
          foundNumber = match.group(0);
          break;
        }
      }

      if (!mounted) return;

      if (foundNumber != null) {
        final formatted = _formatBizNumber(foundNumber);
        _bizNumberController.text = formatted;
        await _verifyBizNumber(formatted);
      } else {
        setState(() {
          _isOcrLoading = false;
          _bizVerifyStatus = 'failed';
          _bizVerifyMessage = '사업자등록번호를 찾지 못했어요\n직접 입력해주세요';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isOcrLoading = false;
        _bizVerifyStatus = 'failed';
        _bizVerifyMessage = 'OCR 처리 중 오류가 발생했어요\n직접 입력해주세요';
      });
    }
  }

  Future<void> _verifyBizNumber(String number) async {
    if (!mounted) return;
    setState(() { _isOcrLoading = true; });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final isValid = _isValidBizNumber(number);
    setState(() {
      _isOcrLoading = false;
      _bizVerifyStatus = isValid ? 'verified' : 'failed';
      _bizVerifyMessage = isValid
          ? '유효한 사업자등록번호예요'
          : '유효하지 않은 사업자등록번호예요\n다시 확인해주세요';
    });
  }

  Future<void> _pickImage(bool isBiz) async {
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
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36, height: 4,
                decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
                  if (img != null) {
                    setState(() => isBiz ? _bizImage = img : _licenseImage = img);
                    if (isBiz) await _extractBizNumber(img);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E3A52) : const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF3182F6), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('카메라로 촬영', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        Text('지금 바로 서류를 촬영해요', style: tt.bodySmall),
                      ]),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.25), size: 20),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: cs.outline, indent: 24, endIndent: 24),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
                  if (img != null) {
                    setState(() => isBiz ? _bizImage = img : _licenseImage = img);
                    if (isBiz) await _extractBizNumber(img);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E3A52) : const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.photo_library_rounded, color: Color(0xFF03B26C), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('갤러리에서 선택', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        Text('저장된 사진을 불러와요', style: tt.bodySmall),
                      ]),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.25), size: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SizedBox(
                  width: double.infinity, height: 50,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(backgroundColor: cs.onSurface.withValues(alpha: 0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
                        color: KColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: KColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: KColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text('사업자등록증 사진을 올리면\n사업자번호를 자동으로 인식하고 검증해요', style: tt.bodySmall?.copyWith(height: 1.5))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 사업자등록증 업로드
                    _buildUploadSection(
                      context,
                      label: '사업자등록증 사본',
                      description: '사업자 등록번호와 대표자명이 잘 보이게 찍어주세요',
                      image: _bizImage,
                      onTap: () => _pickImage(true),
                      onRemove: () => setState(() {
                        _bizImage = null;
                        _bizVerifyStatus = null;
                        _bizNumberController.clear();
                      }),
                    ),

                    // OCR 로딩 / 번호 입력
                    const SizedBox(height: 16),
                    _buildLabel(context, '사업자등록번호'),
                    const SizedBox(height: 8),
                    if (_isOcrLoading)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outline)),
                        child: Row(
                          children: [
                            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: KColors.primary, strokeWidth: 2)),
                            const SizedBox(width: 12),
                            Text('사업자등록번호 인식 중...', style: tt.bodyMedium),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _bizNumberController,
                                  onChanged: (v) {
                                    final formatted = _formatBizNumber(v);
                                    if (formatted != v) {
                                      _bizNumberController.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
                                    }
                                    setState(() { _bizVerifyStatus = null; });
                                  },
                                  keyboardType: TextInputType.number,
                                  style: tt.bodyLarge,
                                  decoration: InputDecoration(
                                    hintText: '000-00-00000',
                                    suffixIcon: _bizVerifyStatus == 'verified'
                                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20)
                                        : _bizVerifyStatus == 'failed'
                                            ? const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 20)
                                            : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () { if (_bizNumberController.text.isNotEmpty) _verifyBizNumber(_bizNumberController.text); },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(color: KColors.navy, borderRadius: BorderRadius.circular(12)),
                                  child: const Text('검증', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                          if (_bizVerifyStatus != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _bizVerifyStatus == 'verified' ? Icons.check_circle_rounded : Icons.info_rounded,
                                  color: _bizVerifyStatus == 'verified' ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _bizVerifyMessage ?? '',
                                  style: TextStyle(fontFamily: 'Pretendard', color: _bizVerifyStatus == 'verified' ? const Color(0xFF16A34A) : const Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                    const SizedBox(height: 28),

                    // 상호명
                    _buildLabel(context, '상호명'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      style: tt.bodyLarge,
                      decoration: InputDecoration(
                        hintText: '사업자등록증 상의 상호명 입력',
                        suffixIcon: _nameController.text.isNotEmpty
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 매장 주소
                    _buildLabel(context, '매장 주소'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KpostalView(
                              callback: (Kpostal result) {
                                setState(() {
                                  _addressController.text = result.roadAddress.isNotEmpty
                                      ? result.roadAddress
                                      : result.address;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _addressController.text.isNotEmpty ? KColors.primary : cs.outline,
                            width: _addressController.text.isNotEmpty ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: _addressController.text.isNotEmpty ? KColors.primary : cs.onSurface.withValues(alpha: 0.35), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _addressController.text.isNotEmpty ? _addressController.text : '주소 검색',
                                style: TextStyle(fontFamily: 'Pretendard', color: _addressController.text.isNotEmpty ? cs.onSurface : cs.onSurface.withValues(alpha: 0.35), fontSize: 15, fontWeight: _addressController.text.isNotEmpty ? FontWeight.w500 : FontWeight.w400),
                              ),
                            ),
                            if (_addressController.text.isNotEmpty)
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20)
                            else
                              Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.3), size: 20),
                          ],
                        ),
                      ),
                    ),
                    if (_addressController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _detailAddressController,
                        onChanged: (_) => setState(() {}),
                        style: tt.bodyLarge,
                        decoration: const InputDecoration(hintText: '상세주소 입력 (동/호수 등)'),
                      ),
                    ],

                    const SizedBox(height: 28),

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
                          onPressed: _canSubmit ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: KColors.primary.withValues(alpha: 0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('서류 제출 및 인증하기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
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

  Widget _buildUploadSection(BuildContext context, {required String label, required String description, required XFile? image, required VoidCallback onTap, required VoidCallback onRemove}) {
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
              color: uploaded ? Colors.transparent : cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: uploaded ? KColors.primary : cs.outline, width: uploaded ? 1.5 : 1),
            ),
            child: uploaded
                ? Stack(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.file(File(image!.path), width: double.infinity, height: 180, fit: BoxFit.cover)),
                      Positioned(top: 8, right: 8, child: GestureDetector(onTap: onRemove, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 16)))),
                      Positioned(bottom: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14), SizedBox(width: 4), Text('재촬영', style: TextStyle(fontFamily: 'Pretendard', color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))]))),
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

class _PendingDialog extends StatelessWidget {
  final String storeName;
  const _PendingDialog({required this.storeName});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 32),
            ),
            const SizedBox(height: 16),
            Text('서류 제출 완료!', style: tt.titleMedium),
            const SizedBox(height: 8),
            Text(
              '관리자 심사 후 영업일 1~2일 내\n판매자 계정으로 전환됩니다.',
              style: tt.bodyMedium?.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text('($storeName)', style: tt.bodySmall),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // dialog
                  Navigator.pop(context); // verify screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('확인', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}