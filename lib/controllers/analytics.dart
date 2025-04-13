import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsServices {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getObserver() => FirebaseAnalyticsObserver(
        analytics: analytics,
        routeFilter: (Route<dynamic>? route) {
          if (route != null) {
            if (route.settings.name != 'none' && route.settings.name != null) {
              return true;
            } else {
              return false;
            }
          } else {
            return false;
          }
        },
        onError: (e) {
          print('analytics error : $e');
        },
      );

  logAppOpen() {
    analytics.logAppOpen();
  }

  setAnalyticsAmounts(Map userData) async {
    try {
      Map user = userData['user'] ?? {};
      String userId = user['id'].toString();
      String userName = user['username'].toString();
      // await analytics.setUserId(id: userId);
      await analytics.setDefaultEventParameters({
        'user_id': userId,
        'username': userName,
      });
      // await analytics.setUserProperty(name: 'username', value: userName);
      // final prefs = await SharedPreferences.getInstance();
      // prefs.setBool('isAnalyticsSet', true);
    } catch (e) {
      print(e);
    }
  }

  logEvent({
    required String type,
    String? loginMethod,
    String? transactionId,
    double? purchaseValue,
    String? purchaseDiscountCode,
    String? purchaseItemId,
    String? purchaseCurrency,
    String? selectedItemName,
    String? shareContentType,
    String? shareItemId,
    String? eventName,
    Map<String, Object>? eventParameters,
  }) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    switch (type) {
      case 'login':
        analytics.logLogin(loginMethod: loginMethod);
        break;
      case 'signup':
        analytics.logSignUp(signUpMethod: loginMethod ?? '');
        break;
      case 'buy':
        analytics.logPurchase(
          transactionId: transactionId,
          value: purchaseValue,
          coupon: purchaseDiscountCode,
          affiliation: purchaseItemId,
          currency: purchaseCurrency,
        );
        break;
      case 'selectItem':
        analytics.logSelectItem(itemListName: selectedItemName);
        break;
      case 'share':
        analytics.logShare(
            contentType: shareContentType ?? '',
            itemId: shareItemId ?? '',
            method: 'share');
        break;
      case 'openApp':
        analytics.logAppOpen();
        break;
      default:
        analytics.logEvent(
          name: eventName ?? '',
          parameters: eventParameters,
        );
    }
  }
}
