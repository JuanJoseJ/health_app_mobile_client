import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:health_app_mobile_client/util/fitbit_strings.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class FitBitDataService {
  FitBitStrings fitBitStrings = FitBitStrings();
  String accessToken = '';
  String refreshToken = '';
  StreamSubscription? sub;

  String generateCodeVerifier() {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    final verifierChars =
        List.generate(128, (_) => charset[random.nextInt(charset.length)])
            .join();

    return verifierChars;
  }

  String generateCodeChallenge(String verifier) {
    var bytes = utf8.encode(verifier);
    var digest = sha256.convert(bytes);
    return base64Url
        .encode(digest.bytes)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
  }

  void openFitbitAuthorization(String verifier) async {
    final clientId = fitBitStrings.clientId;
    final List<String> scopes = fitBitStrings.scopes;
    final String scopeString = scopes.join(' ');
    final codeChallenge = generateCodeChallenge(verifier);
    final Uri authorizationUrl = Uri.parse(
      'https://www.fitbit.com/oauth2/authorize'
      '?response_type=code'
      '&client_id=$clientId'
      '&code_challenge=$codeChallenge'
      '&code_challenge_method=S256'
      '&scope=${Uri.encodeComponent(scopeString)}'
      // The following line states that a login must be done by the user
      // A better aproach would be to asossiate an account with a user token,
      // but as we are only using the client authN, that is not possible.
      // A back-end server would be required. 
      '&prompt=login',
    );

    if (!await launchUrl(authorizationUrl,
        mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $authorizationUrl');
    }
  }

  Future<Map<String, dynamic>> exchangeAuthorizationCodeForTokens({
    required String authorizationCode,
    required String clientId,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    final Uri tokenEndpoint = Uri.parse('https://api.fitbit.com/oauth2/token');
    Map<String, dynamic> result = {};

    final response = await http.post(
      tokenEndpoint,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'code': authorizationCode,
        'code_verifier': codeVerifier,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      // Successfully exchanged authorization code for tokens
      result = json.decode(response.body);
    } else {
      // Include error handling, for example, by setting an 'error' key in the result
      result['error'] =
          'Failed to exchange authorization code for tokens. Status code: ${response.statusCode}';
      result['details'] = json.decode(response.body);
    }
    return result;
  }

  Future<void> initLinkListener(String verifier) async {
    Completer<void> completer = Completer();
    // Cancel the previous subscription if it exists
    sub?.cancel();

    sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.queryParameters.containsKey('code')) {
        final authorizationCode = uri.queryParameters['code'];
        final tokens = await exchangeAuthorizationCodeForTokens(
            authorizationCode: authorizationCode!,
            clientId: fitBitStrings.clientId,
            codeVerifier: verifier,
            redirectUri: fitBitStrings.redirectUri);
        if (tokens.containsKey('access_token')) {
          setTokens(
              accessToken: tokens['access_token'],
              refreshToken: tokens['refresh_token']);
          if (!completer.isCompleted) {
            completer.complete(); // Ensure completer is only completed once
          }
        } else {
          if (!completer.isCompleted) {
            completer.completeError(
                "Error exchanging code for tokens: ${tokens['error']}");
          }
        }
      }
    }, onError: (err) {
      if (!completer.isCompleted) {
        completer.completeError(err);
      }
    });

    return completer.future; // Return the future
  }

  void setTokens({required String accessToken, required String refreshToken}) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  Future<dynamic> _fetchData(String endPoint) async {
    final Uri endPointUri = Uri.parse(endPoint);

    final response = await http.get(
      endPointUri,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("!!!!!!!!!!!!!!!!!!!!!!!!! FETCH !!!!!!!!!!!!!!!!!!!!!");
      print(data);
      return data;
    } else {
      print("An error occurred at fetch: ${response.body}");
      throw (response.body);
    }
  }

  Future<dynamic> fetchSleepData(DateTime startDate,
      {DateTime? endDate}) async {
    String start = DateFormat("yyyy-MM-dd").format(startDate);
    String? end;
    if (endDate == null) {
      end = DateFormat("yyyy-MM-dd")
          .format(startDate.add(const Duration(hours: 24)));
    } else {
      end = DateFormat("yyyy-MM-dd").format(endDate);
    }
    String endPoint =
        "https://api.fitbit.com//1.2/user/-/sleep/date/$start/$end.json";

    try {
      return await _fetchData(endPoint);
    } catch (e) {
      print("An error occurred at fetch sleep: $e");
      rethrow;
    }
  }
}
