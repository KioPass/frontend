import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

const String _tossClientKey = 'test_ck_P9BRQmyarYlBePmM9qKaVJ07KzLN';

// ✅ 여기 한 곳만 바꾸면 전체 적용됨
//   로컬 테스트 (같은 WiFi) : http://172.20.10.13:8080
//   ngrok 사용시            : https://abc123.ngrok-free.app
//   배포 서버               : https://실제서버주소
const String kBaseUrl = 'http://43.203.72.37:8080';
const String kTossBase = 'http://43.203.72.37:8080';

class OAuthResult {
  final String status; // login_success | signup_success | error | cancelled
  final String? token;
  final String? errorCode; // '401', '409' 등

  const OAuthResult({required this.status, this.token, this.errorCode});

  bool get isLoginSuccess => status == 'login_success';
  bool get isSignupSuccess => status == 'signup_success';
  bool get isError => status == 'error';
  bool get isCancelled => status == 'cancelled';
}

class BuyerPayment {
  final int id;
  final String date;
  final String time;
  final String storeName;
  final String paymentMethod;
  final int totalAmount;
  final List<Map<String, dynamic>> items;

  const BuyerPayment({
    required this.id,
    required this.date,
    required this.time,
    required this.storeName,
    required this.paymentMethod,
    required this.totalAmount,
    required this.items,
  });

  factory BuyerPayment.fromJson(Map<String, dynamic> e) => BuyerPayment(
        id: (e['id'] as num).toInt(),
        date: e['date'] as String,
        time: e['time'] as String,
        storeName: e['storeName'] as String,
        paymentMethod: e['paymentMethod'] as String,
        totalAmount: (e['totalAmount'] as num).toInt(),
        items: (e['items'] as List)
            .map((i) => {
                  'name': i['name'] as String,
                  'qty': (i['quantity'] as num).toInt(),
                  'price': (i['price'] as num).toInt(),
                })
            .toList(),
      );
}

class SalesSummary {
  final int todayAmount;
  final int yesterdayAmount;
  final int changePercent;
  const SalesSummary(
      {required this.todayAmount,
      required this.yesterdayAmount,
      required this.changePercent});
}

class RecentPayment {
  final int id;
  final String time;
  final String buyerName;
  final String paymentMethod;
  final String itemSummary;
  final int totalAmount;
  const RecentPayment(
      {required this.id,
      required this.time,
      required this.buyerName,
      required this.paymentMethod,
      required this.itemSummary,
      required this.totalAmount});
  factory RecentPayment.fromJson(Map<String, dynamic> e) => RecentPayment(
        id: (e['id'] as num).toInt(),
        time: e['time'] as String,
        buyerName: e['buyerName'] as String,
        paymentMethod: e['paymentMethod'] as String,
        itemSummary: e['itemSummary'] as String,
        totalAmount: (e['totalAmount'] as num).toInt(),
      );
}

class TopProduct {
  final int rank;
  final String productName;
  final int totalCount;
  const TopProduct(
      {required this.rank,
      required this.productName,
      required this.totalCount});
  factory TopProduct.fromJson(Map<String, dynamic> e) => TopProduct(
        rank: (e['rank'] as num).toInt(),
        productName: e['productName'] as String,
        totalCount: (e['totalCount'] as num).toInt(),
      );
}

class ProductItem {
  final int id;
  final String barcode;
  final String name;
  final int price;
  final int stock;
  final String category;
  final bool lowStock;
  final String? imageUrl;

  const ProductItem({
    required this.id,
    required this.barcode,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.lowStock,
    this.imageUrl,
  });

  factory ProductItem.fromJson(Map<String, dynamic> e) {
    final rawUrl = e['imageUrl'] as String?;
    // 로컬 경로(/files/...)를 전체 URL로 변환
    final imageUrl = rawUrl != null && rawUrl.startsWith('/files/')
        ? '$kBaseUrl$rawUrl'
        : rawUrl;
    return ProductItem(
      id: (e['id'] as num).toInt(),
      barcode: e['barcode'] as String,
      name: e['name'] as String,
      price: (e['price'] as num).toInt(),
      stock: (e['stock'] as num).toInt(),
      category: e['category'] as String,
      lowStock: e['lowStock'] as bool,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'name': name,
        'price': price,
        'stock': stock,
        'category': category,
      };
}

class NearbyStore {
  final int id;
  final String storename;
  final String address;

  const NearbyStore({
    required this.id,
    required this.storename,
    required this.address,
  });
}

class MyStoreInfo {
  final int storeId;
  final String storeName;
  final String status;
  const MyStoreInfo({required this.storeId, required this.storeName, required this.status});
}

class SellerApplicationModel {
  final int storeId;
  final String storeName;
  final String address;
  final String userEmail;
  final String userName;
  final String licenseUrl;
  final String reportUrl;
  final String status;
  final String appliedAt;

  const SellerApplicationModel({
    required this.storeId,
    required this.storeName,
    required this.address,
    required this.userEmail,
    required this.userName,
    required this.licenseUrl,
    required this.reportUrl,
    required this.status,
    required this.appliedAt,
  });

  factory SellerApplicationModel.fromJson(Map<String, dynamic> j) => SellerApplicationModel(
        storeId: (j['storeId'] as num).toInt(),
        storeName: j['storeName'] as String? ?? '',
        address: j['address'] as String? ?? '',
        userEmail: j['userEmail'] as String? ?? '',
        userName: j['userName'] as String? ?? '',
        licenseUrl: j['licenseUrl'] as String? ?? '',
        reportUrl: j['reportUrl'] as String? ?? '',
        status: j['status'] as String? ?? 'PENDING',
        appliedAt: j['appliedAt'] as String? ?? '',
      );
}

class StampCardModel {
  final int storeId;
  final String storeName;
  final int stampCount;        // 현재 스탬프 수 (0~9)
  final int availableCoupons;  // 사용 가능한 쿠폰 수
  final int totalEarned;

  const StampCardModel({
    required this.storeId,
    required this.storeName,
    required this.stampCount,
    required this.availableCoupons,
    required this.totalEarned,
  });

  factory StampCardModel.fromJson(Map<String, dynamic> j) => StampCardModel(
        storeId: (j['storeId'] as num).toInt(),
        storeName: j['storeName'] as String? ?? '',
        stampCount: (j['stampCount'] as num? ?? 0).toInt(),
        availableCoupons: (j['availableCoupons'] as num? ?? 0).toInt(),
        totalEarned: (j['totalEarned'] as num? ?? 0).toInt(),
      );
}

class InquiryModel {
  final int id;
  final String userEmail;
  final String userName;
  final String category;
  final String content;
  final String status;
  final String? answer;
  final String createdAt;
  final String? answeredAt;

  const InquiryModel({
    required this.id,
    required this.userEmail,
    required this.userName,
    required this.category,
    required this.content,
    required this.status,
    this.answer,
    required this.createdAt,
    this.answeredAt,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> j) => InquiryModel(
        id: (j['id'] as num).toInt(),
        userEmail: j['userEmail'] as String? ?? '',
        userName: j['userName'] as String? ?? '',
        category: j['category'] as String,
        content: j['content'] as String,
        status: j['status'] as String,
        answer: j['answer'] as String?,
        createdAt: j['createdAt'] as String? ?? '',
        answeredAt: j['answeredAt'] as String?,
      );
}

class TossCheckoutInfo {
  final String checkoutUrl;
  final String orderId;
  const TossCheckoutInfo({required this.checkoutUrl, required this.orderId});
}

class UserProfile {
  final String email;
  final String username;
  final String role; // 'BUYER' or 'SELLER'

  const UserProfile({
    required this.email,
    required this.username,
    required this.role,
  });
}

class ApiService {
  static const String _callbackScheme = 'myapp';

  static Map<String, String> _headers([String? token]) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ── OAuth ──────────────────────────────────────────────────────────────
  static Future<OAuthResult> loginWithKakao() => _oauth('kakao', 'login');
  static Future<OAuthResult> loginWithNaver() => _oauth('naver', 'login');
  static Future<OAuthResult> signupWithKakao() => _oauth('kakao', 'signup');
  static Future<OAuthResult> signupWithNaver() => _oauth('naver', 'signup');

  static Future<OAuthResult> _oauth(String provider, String target) async {
    if (kBaseUrl.isEmpty) {
      return const OAuthResult(status: 'error', errorCode: 'no_server');
    }
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: '$kBaseUrl/user/auth/$provider?target=$target',
        callbackUrlScheme: _callbackScheme,
      );
      final uri = Uri.parse(result);
      return OAuthResult(
        status: uri.queryParameters['status'] ?? 'error',
        token: uri.queryParameters['accesstoken'] ?? uri.queryParameters['token'],
        errorCode: uri.queryParameters['code'],
      );
    } catch (_) {
      return const OAuthResult(status: 'cancelled');
    }
  }

  // ── REST ───────────────────────────────────────────────────────────────
  static Future<UserProfile?> getUserProfile(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/user/profile'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final body = (jsonDecode(res.body) as Map<String, dynamic>)['body']
            as Map<String, dynamic>;
        return UserProfile(
          email: body['email'] as String,
          username: body['username'] as String,
          role: body['role'] as String,
        );
      }
    } catch (_) {}
    return null;
  }

  static Future<MyStoreInfo?> getMyStore(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/store/my'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final body = (jsonDecode(res.body) as Map<String, dynamic>)['body'];
        if (body == null) return null;
        return MyStoreInfo(
          storeId: (body['storeId'] as num).toInt(),
          storeName: body['storeName'] as String? ?? '',
          status: body['status'] as String? ?? 'PENDING',
        );
      }
    } catch (_) {}
    return null;
  }

  // ── 상품 ───────────────────────────────────────────────────────────────
  static Future<List<String>> getCategories(
      {required String token, required int storeId}) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/store/$storeId/products/categories'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final body = (jsonDecode(res.body) as Map<String, dynamic>)['body'];
        return (body as List).map((e) => e as String).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<ProductItem>> getProducts(
      {required String token, required int storeId}) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/store/$storeId/products'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as Map<String, dynamic>)['body'] as List;
        return list.map((e) => ProductItem.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<ProductItem?> getProductByBarcode(
      {required String token, required int storeId, required String barcode}) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/store/$storeId/products?barcode=$barcode'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as Map<String, dynamic>)['body'] as List;
        if (list.isNotEmpty) return ProductItem.fromJson(list.first);
      }
    } catch (_) {}
    return null;
  }

  static Future<ProductItem?> createProduct(
      {required String token,
      required int storeId,
      required Map<String, dynamic> data}) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/store/$storeId/products'),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      if (res.statusCode == 200) {
        final body = (jsonDecode(res.body) as Map<String, dynamic>)['body'];
        return ProductItem.fromJson(body);
      }
    } catch (_) {}
    return null;
  }

  static Future<ProductItem?> updateProduct(
      {required String token,
      required int storeId,
      required int productId,
      required Map<String, dynamic> data}) async {
    try {
      final res = await http.put(
        Uri.parse('$kBaseUrl/api/store/$storeId/products/$productId'),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      if (res.statusCode == 200) {
        final body = (jsonDecode(res.body) as Map<String, dynamic>)['body'];
        return ProductItem.fromJson(body);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> deleteProduct(
      {required String token, required int storeId, required int productId}) async {
    try {
      final res = await http.delete(
        Uri.parse('$kBaseUrl/api/store/$storeId/products/$productId'),
        headers: _headers(token),
      );
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ── 결제 ───────────────────────────────────────────────────────────────
  static Future<bool> createPayment({
    required String token,
    required int storeId,
    required String storeName,
    required String paymentMethod,
    required int totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/store/$storeId/payments'),
        headers: _headers(token),
        body: jsonEncode({
          'storeName': storeName,
          'paymentMethod': paymentMethod,
          'totalAmount': totalAmount,
          'items': items,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<SalesSummary?> getSalesSummary(
      {required String token, required int storeId}) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/store/$storeId/sales/summary'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final body = (jsonDecode(res.body) as Map<String, dynamic>)['body']
            as Map<String, dynamic>;
        return SalesSummary(
          todayAmount: (body['todayAmount'] as num).toInt(),
          yesterdayAmount: (body['yesterdayAmount'] as num).toInt(),
          changePercent: (body['changePercent'] as num).toInt(),
        );
      }
    } catch (_) {}
    return null;
  }

  static Future<List<RecentPayment>> getRecentPayments(
      {required String token, required int storeId, String? period}) async {
    try {
      final url = period != null
          ? '$kBaseUrl/api/store/$storeId/payments/recent?period=$period'
          : '$kBaseUrl/api/store/$storeId/payments/recent';
      final res = await http.get(
        Uri.parse(url),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final list =
            (jsonDecode(res.body) as Map<String, dynamic>)['body'] as List;
        return list.map((e) => RecentPayment.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<BuyerPayment>> getBuyerPayments(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/user/payments'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final list =
            (jsonDecode(res.body) as Map<String, dynamic>)['body'] as List;
        return list.map((e) => BuyerPayment.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<TopProduct>> getTopProducts(
      {required String token, required int storeId}) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/store/$storeId/sales/top'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final list =
            (jsonDecode(res.body) as Map<String, dynamic>)['body'] as List;
        return list.map((e) => TopProduct.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ── 상품 이미지 ────────────────────────────────────────────────────────
  static Future<String?> uploadProductImage({
    required String token,
    required int storeId,
    required int productId,
    required String imagePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$kBaseUrl/api/store/$storeId/products/$productId/image'),
      )
        ..headers.addAll({'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'})
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));
      final streamed = await request.send();
      if (streamed.statusCode == 200) {
        final body = jsonDecode(await streamed.stream.bytesToString())
            as Map<String, dynamic>;
        return body['body'] as String?;
      }
    } catch (_) {}
    return null;
  }

  // ── 토스 결제 (JS SDK HTML 페이지 방식) ──────────────────────────────
  static Future<TossCheckoutInfo?> requestTossPayment({
    required int amount,
    required String orderName,
    required String tossMethod,
  }) async {
    final orderId = 'kiopass${DateTime.now().millisecondsSinceEpoch}';
    final method = tossMethod == '카드' ? '카드' : '간편결제';

    final uri = Uri.parse('$kTossBase/toss/payment').replace(queryParameters: {
      'amount': amount.toString(),
      'orderId': orderId,
      'orderName': orderName,
      'method': method,
      'successUrl': '$kTossBase/api/payments/toss/callback',
      'failUrl': '$kTossBase/api/payments/toss/fail',
    });

    return TossCheckoutInfo(checkoutUrl: uri.toString(), orderId: orderId);
  }

  static Future<bool> confirmTossPayment({
    required String token,
    required String paymentKey,
    required String orderId,
    required int amount,
    required int storeId,
    required String storeName,
    required List<Map<String, dynamic>> items,
    bool couponUsed = false,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/payments/toss/confirm'),
        headers: _headers(token),
        body: jsonEncode({
          'paymentKey': paymentKey,
          'orderId': orderId,
          'amount': amount,
          'storeId': storeId,
          'storeName': storeName,
          'items': items,
          'couponUsed': couponUsed,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ── 판매자 신청 관리 (관리자) ────────────────────────────────────────
  static Future<List<SellerApplicationModel>> getSellerApplications(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/admin/seller-applications'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as Map<String, dynamic>)['body'] as List;
        return list.map((e) => SellerApplicationModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> approveSellerApplication(String token, int storeId) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/admin/seller-applications/$storeId/approve'),
        headers: _headers(token),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> rejectSellerApplication(String token, int storeId) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/admin/seller-applications/$storeId/reject'),
        headers: _headers(token),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── 판매자 신청 상태 조회 (일반 사용자) ───────────────────────────────
  static Future<String?> getMyApplicationStatus(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/store/my'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final body = (jsonDecode(res.body) as Map<String, dynamic>)['body'];
        if (body == null) return null;
        return body['status'] as String?;
      }
    } catch (_) {}
    return null;
  }

  // ── 고객센터 문의 ─────────────────────────────────────────────────────
  static Future<List<InquiryModel>> getMyInquiries(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/inquiries/my'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as Map<String, dynamic>)['body'] as List;
        return list.map((e) => InquiryModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> createInquiry(String token, String category, String content) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/inquiries'),
        headers: _headers(token),
        body: jsonEncode({'category': category, 'content': content}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── 관리자 ──────────────────────────────────────────────────────────
  // ── 도어 출입 ─────────────────────────────────────────────────────────
  static Future<bool> verifyDoorEntry(String token, int storeId, String storeName) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/door/verify'),
        headers: _headers(token),
        body: jsonEncode({'storeId': storeId, 'storeName': storeName}),
      );
      if (res.statusCode == 200) {
        final body = (jsonDecode(res.body) as Map<String, dynamic>)['body'];
        return body['open'] == true;
      }
    } catch (_) {}
    return false;
  }

  static Future<List<InquiryModel>> getAdminInquiries(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/admin/inquiries'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as Map<String, dynamic>)['body'] as List;
        return list.map((e) => InquiryModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ── 스탬프 / 쿠폰 ─────────────────────────────────────────────────────
  static Future<List<StampCardModel>> getMyCoupons(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/stamps/my'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as Map<String, dynamic>)['body'] as List;
        return list.map((e) => StampCardModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<StampCardModel?> getStampCard(String token, int storeId) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/api/stamps/my/$storeId'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final body = (jsonDecode(res.body) as Map<String, dynamic>)['body'];
        return StampCardModel.fromJson(body as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  static Future<StampCardModel?> useCoupon(String token, int storeId) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/stamps/use/$storeId'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final body = (jsonDecode(res.body) as Map<String, dynamic>)['body'];
        return StampCardModel.fromJson(body as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> deleteInquiry(String token, int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$kBaseUrl/api/inquiries/$id'),
        headers: _headers(token),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> adminDeleteInquiry(String token, int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$kBaseUrl/api/admin/inquiries/$id'),
        headers: _headers(token),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> answerInquiry(String token, int id, String answer) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/admin/inquiries/$id/answer'),
        headers: _headers(token),
        body: jsonEncode({'answer': answer}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveDeviceToken(String token, String fcmToken, String platform) async {
    try {
      await http.post(
        Uri.parse('$kBaseUrl/api/user/device-token'),
        headers: _headers(token),
        body: jsonEncode({'token': fcmToken, 'platform': platform}),
      );
    } catch (_) {}
  }

  static Future<bool> setupAdmin(String email, String secret) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/admin/setup'),
        headers: {'Content-Type': 'application/json', 'ngrok-skip-browser-warning': 'true'},
        body: jsonEncode({'email': email, 'secret': secret}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteAccount(String token) async {
    try {
      final res = await http.delete(
        Uri.parse('$kBaseUrl/api/user'),
        headers: _headers(token),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<NearbyStore>> getNearbyStores({
    required String token,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final res = await http.get(
        Uri.parse(
            '$kBaseUrl/api/store/nearby?latitude=$latitude&longitude=$longitude'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final list =
            (jsonDecode(res.body) as Map<String, dynamic>)['body'] as List;
        return list
            .map((e) => NearbyStore(
                  id: (e['id'] as num).toInt(),
                  storename: e['storename'] as String,
                  address: e['address'] as String,
                ))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> upgradeToSeller({
    required String token,
    required String storename,
    required String address,
    required String bizImagePath,
    required String licenseImagePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$kBaseUrl/api/user/upgrade'),
      )
        ..headers.addAll({'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'})
        ..files.add(http.MultipartFile.fromBytes(
          'info',
          utf8.encode(jsonEncode({'storename': storename, 'address': address})),
          contentType: MediaType('application', 'json'),
        ))
        ..files.add(
            await http.MultipartFile.fromPath('businessLicense', bizImagePath))
        ..files.add(await http.MultipartFile.fromPath(
            'operationReport', licenseImagePath));

      final streamed = await request.send();
      return streamed.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
