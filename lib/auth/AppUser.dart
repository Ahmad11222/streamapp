import 'dart:convert' show json, utf8;
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../global/globalConfig.dart';

class AppUser extends GetxController {
  var _userLoggedIn = false;
  var selectedContract = null;
  var _userData = {};

  getUserID() {
    return _userData['userid'];
  }

  getUserName() async {
    return _userData['username'];
  }

  getCusCode() {
    return _userData['cuscode'];
  }

  getUserFullName() {
    return _userData['fullname'] ?? '';
  }

  getEmail() {
    return _userData['email'] ?? '';
  }

  getMobileNo() {
    return _userData['mobileno'] ?? '';
  }

  getContactNo() {
    return _userData['contactno'] ?? '';
  }

  isMainAccount() {
    return _userData['ismain'] ?? '';
  }

  getPerentID() {
    return _userData['perentid'] ?? '';
  }

  getTypeDesc() {
    return _userData['usertypedesc'] ?? '';
  }

  getEmergencyContact() {
    return _userData['emergencycontact'] ?? '';
  }

  getDefaultContractID() {
    return selectedContract;
  }

  getColor({required String colorType}) {
    try {
      String mycolor = '';
      if (colorType == 'main') {
        mycolor = 'E178C5';
      } else if (colorType == 'sub') {
        mycolor = '5E1675';
      } else {
        mycolor = 'F1EF99';
      }

      return int.parse('ff' + mycolor, radix: 16);
    } catch (e) {
      return int.parse('ff' + 'ACE2E1', radix: 16);
    }
  }

  getcuscode() {
    return _userData['cuscode'] ?? '';
  }

  getLogStat() {
    return _userLoggedIn;
  }

  List<dynamic> getPages() => _userData['pages'] ?? [];

  Map<String, dynamic> getContracts() => _userData['contracts'] ?? {};

  void logOut() {
    _userLoggedIn = false;
    _userData = {};
  }

  Future<Map<String, dynamic>> getDataAndLogin() async {
    // call only once to login and get updated user data
    try {
      String _savedToken = await getLocalData('token');
      String _savedUsername = await getLocalData('username');
      print('token: ' + _savedToken);
      if (_savedToken == '') {
        return myErrorMap;
      }
      var resp =
          await http.get(Uri.parse(myMainAPILink + "getuserdata"), headers: {
        "Accept": "application/json",
        "ctoken": _savedToken,
        "lang": getCurrentLocaleString(),
        'username': _savedUsername,
      });
      var result = json.decode(utf8.decode(resp.bodyBytes));
      log(result.toString());
      if (result['successFlag'] == 'T') {
        _userData = result;

        _userLoggedIn = true;
        selectedContract = result['contracts'].keys.first ?? '';
      }
      return result;
    } catch (e) {
      return myErrorMap;
    }
  }
}
