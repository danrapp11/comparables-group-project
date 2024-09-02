import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestResult
{
  bool ok;
  dynamic data;
  RequestResult(this.ok, this.data);

  //num get length => null;
}

const PROTOCOL = "http";
const DOMAIN = "130.85.230.76:8000";

Future<RequestResult> http_get(String route, [dynamic data]) async
{
  var dataStr = jsonEncode(data);
  var url = "$PROTOCOL://$DOMAIN/$route?data=$dataStr";
  print(url);
  var result = await http.get(Uri.parse(url));
  print(result);
  print(result.body);
  print(jsonDecode(result.body));
  return RequestResult(true, jsonDecode(result.body));
}
Future<RequestResult> http_post(String route, [dynamic data]) async
{
  var url = "$PROTOCOL://$DOMAIN/$route";
  var dataStr = jsonEncode(data);
  var result = await http.post(Uri.parse(url), body: dataStr, headers:{"Content-Type":"application/json"});
  return RequestResult(true, jsonDecode(result.body));
}