import 'dart:convert' show json, utf8;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../auth/AppUser.dart';
import '../global/globalConfig.dart';

final AppUser _auth = Get.find();

Future<List<dynamic>> myAPIgetCountriesList(
    {String trnsid = '', String id = '', String isocode = ''}) async {
  try {
    return [
      {
        "id": 117,
        "name": "الكويت",
        "nameen": "Kuwait",
        "namear": "الكويت",
        "order": 1,
        "regioncode": "KW",
        "longitude": 47.4817657470703,
        "latitude": 29.2782192230225,
        "callcode": "965",
        "isocode": "KW",
        "isalt": "F",
        "icon": "https://csp-m-test.mofa.gov.kw/images/KW.png"
      },
      {
        "id": 230,
        "name": "المملكة المتحدة",
        "nameen": "United Kingdom",
        "namear": "المملكة المتحدة",
        "order": 2,
        "regioncode": "GB",
        "longitude": -3.24138927459717,
        "latitude": 55.3979148864746,
        "callcode": "44",
        "isocode": "GB",
        "isalt": "F",
        "icon": "https://csp-m-test.mofa.gov.kw/images/GB.png"
      },
      {
        "id": 231,
        "name": "الولايات المتحدة الأمريكية",
        "nameen": "United States",
        "namear": "الولايات المتحدة الأمريكية",
        "order": 2,
        "regioncode": "US",
        "longitude": -104.941192626953,
        "latitude": 39.7149829864502,
        "callcode": "1",
        "isocode": "US",
        "isalt": "F",
        "icon": "https://csp-m-test.mofa.gov.kw/images/US.png"
      },
      {
        "id": 229,
        "name": "دولة الإمارات العربية المتحدة",
        "nameen": "United Arab Emirates",
        "namear": "دولة الإمارات العربية المتحدة",
        "order": 3,
        "regioncode": "AE",
        "longitude": 53.9800300598145,
        "latitude": 24.3826389312744,
        "callcode": "971",
        "isocode": "AE",
        "isalt": "F",
        "icon": "https://csp-m-test.mofa.gov.kw/images/AE.png"
      },
      {
        "id": 13,
        "name": "استراليا",
        "nameen": "Australia",
        "namear": "استراليا",
        "order": 4,
        "regioncode": "AU",
        "longitude": 135.940254211426,
        "latitude": -32.4554181098938,
        "callcode": "61",
        "isocode": "AU",
        "isalt": "F",
        "icon": "https://csp-m-test.mofa.gov.kw/images/AU.png"
      },
      {
        "id": 82,
        "name": "جمهورية ألمانيا الإتحادية",
        "nameen": "Germany",
        "namear": "جمهورية ألمانيا الإتحادية",
        "order": 4,
        "regioncode": "DE",
        "longitude": 10.4494087696075,
        "latitude": 51.1656227111816,
        "callcode": "49",
        "isocode": "DE",
        "isalt": "F",
        "icon": "https://csp-m-test.mofa.gov.kw/images/DE.png"
      },
      {
        "id": 75,
        "name": "جمهورية فرنسا",
        "nameen": "France",
        "namear": "جمهورية فرنسا",
        "order": 4,
        "regioncode": "FR",
        "longitude": 2.38795065879822,
        "latitude": 46.2291984558105,
        "callcode": "33",
        "isocode": "FR",
        "isalt": "F",
        "icon": "https://csp-m-test.mofa.gov.kw/images/FR.png"
      },
      {
        "id": 21,
        "name": "مملكة بلجيكا",
        "nameen": "Belgium",
        "namear": "مملكة بلجيكا",
        "order": 5,
        "regioncode": "BE",
        "longitude": 4.46993517875671,
        "latitude": 50.4979133605957,
        "callcode": "32",
        "isocode": "BE",
        "isalt": "F",
        "icon": "https://csp-m-test.mofa.gov.kw/images/BE.png"
      }
    ];
  } catch (e) {
    return [];
  }
}

Future<Map<String, String>> myAPIgetbookingsub(serviceid) async {
  try {
    var resp = await http
        .get(Uri.parse(myIntegrationAPILink + "getBookingSubTypes"), headers: {
      "Accept": "application/json",
      "typeid": serviceid,
      'lang': getCurrentLocaleString()
    });

    var result = json.decode(utf8.decode(resp.bodyBytes));

    List apiList = result['items'];

    var apiMap = new Map<String, String>();
    for (var i = 0; i < apiList.length; i++) {
      apiMap.putIfAbsent(
          apiList[i]['id'].toString(), () => apiList[i]['name'].toString());
    }
    return apiMap;
  } catch (e) {
    return {};
  }
}

Future<Map<String, String>> myAPIgetbookingplaces(subtypeid) async {
  try {
    var resp = await http
        .get(Uri.parse(myIntegrationAPILink + "getBookingPlaces"), headers: {
      "Accept": "application/json",
      "subtypeid": subtypeid,
      'lang': getCurrentLocaleString()
    });

    var result = json.decode(utf8.decode(resp.bodyBytes));

    List apiList = result['items'];

    var apiMap = new Map<String, String>();
    for (var i = 0; i < apiList.length; i++) {
      apiMap.putIfAbsent(
          apiList[i]['id'].toString(), () => apiList[i]['name'].toString());
    }
    return apiMap;
  } catch (e) {
    return {};
  }
}

Future<Map<String, dynamic>> myAPIcontractlist({String isdefualt = 'F'}) async {
  // String _savedToken = await getLocalData('token');
  try {
    // var resp =
    //     await http.get(Uri.parse(myAPILink + "getcontractlist"), headers: {
    //   "Accept": "application/json",
    //   "token": _savedToken,
    //   "username": _auth.getUserName(),
    //   "cuscode": _auth.getcuscode().toString(),
    //   'G_LANG': getCurrentLocaleString(),
    //   'isdefault': isdefualt
    // });

    // var result = json.decode(utf8.decode(resp.bodyBytes));

    // List apiList = result['items'];

    // var apiMap = new Map<String, String>();
    // for (var i = 0; i < apiList.length; i++) {
    //   apiMap.putIfAbsent(apiList[i]['contractnumber'].toString(),
    //       () => apiList[i]['property'].toString());
    // }
    return _auth.getContracts();
  } catch (e) {
    return {};
  }
}

Future myAPIcontract() async {
  String _savedToken = await getLocalData('token');
  final AppUser _auth = Get.find();
  try {
    var resp = await http
        .get(Uri.parse(myIntegrationAPILink + "getcontractlist"), headers: {
      "Accept": "application/json",
      "token": _savedToken,
      "username": _auth.getUserName(),
      "cuscode": _auth.getcuscode().toString(),
      'G_LANG': getCurrentLocaleString(),
    });

    var result = json.decode(utf8.decode(resp.bodyBytes));
    return result['items'];
  } catch (e) {
    return [];
  }
}

Future myAPImergeWebLinks() async {
  try {
    var resp = await http
        .get(Uri.parse(myIntegrationAPILink + "getMergeWebLinks"), headers: {
      "Accept": "application/json",
    });

    var result = json.decode(utf8.decode(resp.bodyBytes));
    return result;
  } catch (e) {
    return {};
  }
}

Future getUnitsList() async {
  // call only once to login and get updated user data
  try {
    String _savedToken = await getLocalData('token');
    String _username = await getLocalData('username');
    print('token: ' + _savedToken);
    if (_savedToken == '') {
      return myErrorMap;
    }
    var resp = await http.get(
        Uri.parse(myIntegrationAPILink + "getunitlistbycontract"),
        headers: {
          "Accept": "application/json",
          "ctoken": _savedToken,
          'username': _username,
          "plang": getCurrentLocaleString(),
          "contractno": _auth.selectedContract
        });
    var result = json.decode(utf8.decode(resp.bodyBytes));
    return result;
  } catch (e) {
    return myErrorMap;
  }
}
