// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' show AnchorElement, document;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' show get, delete, post, put;

class APICaller {
  // API Url
  static const String apiBaseUrl =
      "https://rgdoy0o5q0.execute-api.us-east-2.amazonaws.com/submit";
  // Internal vars (for help with variables of endpoints)
  static const String _packageByName = "$apiBaseUrl/package/byName";
  static const String _packageByID = "$apiBaseUrl/package";
  // API Endpoints
  static const String authEndpoint = "$apiBaseUrl/authenticate";
  static const String addEndpoint = "$apiBaseUrl/package";
  static const String packagesEndpoint = "$apiBaseUrl/packages";
  static const String resetEndpoint = "$apiBaseUrl/reset";
  static String packageByNameEndpoint(String name) => '$_packageByName/$name';
  static String packageByIdEndpoint(String id) => '$_packageByID/$id';
  static String packageRateByIdEndpoint(String id) => '$_packageByID/$id/rate';
  static var headers = {"Content-Type": "application/json"};
  // For testing
  static String test = "/";

  static Future<bool> addPackage(
      {required String data, required String code}) async {
    try {
      var requestBody = {"Content": data, "JSProgram": code};

      Uri apiUrl = Uri.parse(addEndpoint);
      var response =
          await post(apiUrl, headers: headers, body: jsonEncode(requestBody));
      if (response.statusCode == 201) {
        // Something
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future<bool> deletePackages(
      {required List<Map<String, dynamic>> packages}) async {
    bool isComplete = true;
    for (Map<String, dynamic> package in packages) {
      try {
        Uri apiUrl = Uri.parse(packageByIdEndpoint(package['ID'].toString()));
        var response = await delete(
          apiUrl,
          headers: headers,
        );
        print(response.statusCode);
        if (response.statusCode == 200) {
          // Something
        }
      } catch (e) {
        print(e);
        isComplete = false;
      }
    }
    return isComplete;
  }

  // static Future<bool> updatePackages(
  //     {required List<Map<String, dynamic>> packages}) async {
  //   bool isComplete = true;
  //   for (Map<String, dynamic> package in packages) {
  //     try {
  //       Uri apiUrl = Uri.parse(packageByIdEndpoint(package['ID']));
  //       var response = await put(
  //         apiUrl,
  //         headers: headers,
  //       );
  //       if (response.statusCode == 200) {
  //         // Something
  //       }
  //     } catch (e) {
  //       print(e);
  //       isComplete = false;
  //     }
  //   }
  //   return isComplete;
  // }

  static Future<bool> factoryReset() async {
    try {
      Uri apiUrl = Uri.parse(resetEndpoint);
      var response = await delete(
        apiUrl,
        headers: headers,
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // Something
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future<int> packageSize(
      {required Map<String, dynamic> package}) async {
    try {
      Uri apiUrl = Uri.parse(packageByIdEndpoint(package['ID']));
      var response = await get(
        apiUrl,
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return (((data['data']['Content'].toString().length) / 4).ceil() * 3);
      }
    } catch (e) {
      print(e);
    }
    return 0;
  }

  static Future<bool> downloadPackage(
      {required Map<String, dynamic> package}) async {
    try {
      Uri apiUrl = Uri.parse(packageByIdEndpoint(package['ID']));
      var response = await get(
        apiUrl,
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final urlString =
            "data:application/x-zip-compressed;base64,${data['data']['Content']}";
        AnchorElement anchorElement = AnchorElement(href: urlString);
        anchorElement.download =
            '${package['Name']}_v${package['Version']}.zip';
        document.body!.append(anchorElement);
        anchorElement.click();
        anchorElement.remove();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
