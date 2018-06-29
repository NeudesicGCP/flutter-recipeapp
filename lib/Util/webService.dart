import 'dart:io';
import 'dart:convert';
import 'dart:async';

class WebService {

  static final String serviceURL = "natasha.gonecoding.io";
  
  /// Load a json file from a specified directory in the service URL
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      var httpClient = new HttpClient();
      var url = new Uri.http(serviceURL, endpoint);
      var request = await httpClient.getUrl(url);
      var response = await request.close();
      response.timeout(new Duration(seconds: 10));
      var responseBody = await response.transform(UTF8.decoder).join();
      print("Response: $responseBody");
      Map data = JSON.decode(responseBody) as Map<String, dynamic>;
      return data;
    }
    catch (e) {
      print("Exception: $e");
    }
    return null;
  }
}