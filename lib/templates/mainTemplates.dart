import 'package:file_picker/file_picker.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';

class PageTemplate {
  String pageName = '';
  String pageHint = '';
  String firstPage = '';
  String lastPage = '';

  String pageOrder = '';
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<FieldTemplate> fields = [];
  List<AttachmentTemplate> attachments = [];

  PageTemplate(
      {String pageName = '',
      String pageHint = '',
      String firstpage = '',
      String lastPage = '',
      String pageOrder = '',
      required GlobalKey<FormState> formKey,
      required List<FieldTemplate> fields,
      required List<AttachmentTemplate> attachments}) {
    this.pageName = pageName;
    this.pageHint = pageHint;
    this.firstPage = firstpage;
    this.lastPage = lastPage;
    this.pageOrder = pageOrder;
    this.formKey = formKey;
    this.fields = fields;
    this.attachments = attachments;
  }
}

class FieldTemplate {
  String id = '';
  String type = '';
  String label = '';
  String hint = '';
  String isrequired = '';
  Map<dynamic, dynamic> dropdownoptions = {};
  TextEditingController teController = TextEditingController();
  String selectedValue = '';
  String selectedValueText = '';
  String subtype = '';
  int maxlength = 0;
  String dataSource = '';
  String countryID = '';
  String countryFlagText = '';
  TextEditingController countryController = TextEditingController();
  List<ValidatorTemplate> validators = [];
  bool isChecked = false;
  int linesNo = 1;
  MultiSelectController<String> multiCBcontroller =
      MultiSelectController(deSelectPerpetualSelectedItems: false);

  FieldTemplate(
      {String id = '',
      String type = '',
      String label = '',
      String hint = '',
      String isrequired = '',
      required Map<dynamic, dynamic> dropdownoptions,
      required TextEditingController teController,
      String selectedValue = '',
      String selectedValueText = '',
      String subtype = '',
      int maxlength = 0,
      String dataSource = '',
      String countryID = '',
      String countryFlagText = '',
      required TextEditingController countryController,
      required List<ValidatorTemplate> validators,
      bool isChecked = false,
      int linesNo = 1}) {
    this.id = id;
    this.type = type;
    this.label = label;
    this.hint = hint;
    this.isrequired = isrequired;
    this.dropdownoptions = dropdownoptions;
    this.teController = teController;
    this.selectedValue = selectedValue;
    this.selectedValueText = selectedValueText;
    this.subtype = subtype;
    this.maxlength = maxlength;
    this.dataSource = dataSource;
    this.countryID = countryID;
    this.countryFlagText = countryFlagText;
    this.countryController = countryController;
    this.validators = validators;
    this.isChecked = isChecked;
    this.linesNo = linesNo;
  }
}

class ValidatorTemplate {
  String regex;
  String message;

  ValidatorTemplate({required this.regex, required this.message}) {}
}

class AttachmentTemplate {
  String docDesc = 'file';
  FilePickerResult fPResult = FilePickerResult([]);
  XFile? imagePicker;
  bool canBeEmpty = true;
  bool currentlyHasFile = false;
  String id = '';
  bool canBeRemoved = false;
  bool isExtra = false;

  AttachmentTemplate(
      {required id,
      required docDesc,
      isExtra = false,
      canBeEmpty = true,
      canBeRemoved = false}) {
    this.id = id;
    this.docDesc = canBeEmpty ? docDesc : docDesc + ' *';
    this.canBeEmpty = canBeEmpty;
    this.canBeRemoved = canBeRemoved;
    this.isExtra = isExtra;
  }
}
