import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:piwigo_ng/model/SortModel.dart';
import 'API.dart';

Future<Map<String,dynamic>> fetchCollections({int page, SortModel sorting}) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.collections.getList",
    "per_page": "100",
    "page": "0",
  };
  if(page != null) queries["page"] = page.toString();
  if(sorting != null) queries["order"] = sorting.sortOrder;

  try {
    Response response = await API().dio.get('ws.php', queryParameters: queries);

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch(e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}

Future<Map<String,dynamic>> fetchCollectionImages(int page, {String collectionID, SortModel sorting}) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.collections.getImages",
    "per_page": "100",
    "col_id": collectionID,
    "page": page.toString(),
  };
  if(sorting != null) queries["order"] = sorting.sortOrder;

  try {
    Response response = await API().dio.get('ws.php', queryParameters: queries);

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch(e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}
