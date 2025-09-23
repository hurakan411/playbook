import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // プロダクトID（App Store Connectで設定する）
  static const String basicPlanId = 'basic_plan_monthly';
  static const String premiumPlanId = 'premium_plan_monthly';
  
  static const Set<String> _productIds = {
    basicPlanId,
    premiumPlanId,
  };

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  String? _currentUserId;

  // 初期化
  Future<void> initialize(String userId) async {
    try {
      _currentUserId = userId;
      // iOS専用の設定
      if (Platform.isIOS) {
        var iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      }

      // 購入状態の監視開始
      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription.cancel(),
        onError: (error) => print('Purchase stream error: $error'),
      );

      // ストアの利用可能性をチェック
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        print('In-app purchase is not available');
        debugPrint('Failed to initialize purchase service: In-app purchase is not available');
        return;
      }

      // プロダクト情報を取得
      await _loadProducts();
      // 未完了の購入を復元
      await _restorePurchases();
    } catch (e) {
      print('Failed to initialize purchase service: $e');
      debugPrint('購入サービス初期化エラー: $e');
    }
  }

  // プロダクト情報を読み込み
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }
      
      if (response.error != null) {
        print('Error loading products: ${response.error}');
        return;
      }

      _products = response.productDetails;
      print('Loaded ${_products.length} products');
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  // 購入状態の更新処理
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchaseUpdate(purchaseDetails);
    }
  }

  // 購入処理のハンドリング
  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    print('Purchase status: ${purchaseDetails.status}');
    
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        _purchasePending = true;
        break;
        
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // 購入成功時の処理
        await _handleSuccessfulPurchase(purchaseDetails);
        break;
        
      case PurchaseStatus.error:
        // エラー時の処理
        print('Purchase error: ${purchaseDetails.error}');
        _purchasePending = false;
        break;
        
      case PurchaseStatus.canceled:
        // キャンセル時の処理
        print('Purchase canceled');
        _purchasePending = false;
        break;
    }

    // 購入の完了処理
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  // 購入成功時の処理
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    print('Purchase successful: ${purchaseDetails.productID}');
    
    try {
      // レシート検証とサーバーへの通知
      await _verifyPurchase(purchaseDetails);
      
      // ローカル状態の更新
      await _updateLocalSubscriptionStatus(purchaseDetails.productID);
      
      _purchasePending = false;
    } catch (e) {
      print('Error handling successful purchase: $e');
      debugPrint('購入完了処理エラー: $e');
    }
  }

  // レシート検証
  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // ここでバックエンドにレシートを送信して検証
      // 実装例：
      // await api.verifyReceipt({
      //   'user_id': _currentUserId,
      //   'product_id': purchaseDetails.productID,
      //   'transaction_id': purchaseDetails.purchaseID,
      //   'receipt_data': purchaseDetails.verificationData.serverVerificationData,
      // });
      
      print('Receipt verification would be implemented here');
    } catch (e) {
      print('Receipt verification failed: $e');
      debugPrint('レシート検証エラー: $e');
      throw e;
    }
  }

  // ローカルのサブスクリプション状態を更新
  Future<void> _updateLocalSubscriptionStatus(String productId) async {
    // SharedPreferencesやローカルDBに保存
    // UserPlanの更新なども行う
    print('Updating local subscription status for: $productId');
  }

  // 購入開始
  Future<bool> startPurchase(String productId) async {
    if (!_isAvailable) {
      print('Store is not available');
      return false;
    }

    final ProductDetails? product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found: $productId'),
    );

    if (product == null) {
      print('Product not found: $productId');
      return false;
    }

    _purchasePending = true;

    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      
      return success;
    } catch (e) {
      print('Purchase failed: $e');
      // ログにもエラー内容を出力
      debugPrint('購入エラー: $e');
      _purchasePending = false;
      return false;
    }
  }

  // 購入復元
  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Restore purchases failed: $e');
      debugPrint('購入復元エラー: $e');
    }
  }

  // 手動での購入復元
  Future<void> restorePurchases() async {
    await _restorePurchases();
  }

  // 利用可能なプロダクト一覧を取得
  List<ProductDetails> get products => _products;
  
  // ストアが利用可能かどうか
  bool get isAvailable => _isAvailable;
  
  // 購入処理中かどうか
  bool get isPurchasePending => _purchasePending;

  // 特定のプロダクトを取得
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  // リソースの解放
  void dispose() {
    _subscription.cancel();
  }
}

// iOS専用のペイメントキューデリゲート
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
