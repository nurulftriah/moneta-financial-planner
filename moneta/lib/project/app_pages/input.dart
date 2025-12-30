import 'dart:core';
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:day_night_time_picker/day_night_time_picker.dart';

import 'package:flutter/material.dart';

import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:money_assistant_2608/project/classes/alert_dialog.dart';
import 'package:money_assistant_2608/project/classes/app_bar.dart';
import 'package:money_assistant_2608/project/classes/category_item.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/classes/custom_toast.dart';
import 'package:money_assistant_2608/project/classes/input_model.dart';

import 'package:money_assistant_2608/project/classes/saveOrSaveAndDeleteButtons.dart';
import 'package:money_assistant_2608/project/database_management/shared_preferences_services.dart';
import 'package:money_assistant_2608/project/database_management/firestore_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:provider/provider.dart';

import 'package:money_assistant_2608/project/classes/receipt_scanner_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../provider.dart';
import 'expense_category.dart';
import 'income_category.dart';

late CategoryItem defaultCategory;
var selectedTime = TimeOfDay.now();
var selectedDate = DateTime.now();
InputModel model = InputModel();
late TextEditingController _amountController;
FocusNode? amountFocusNode, descriptionFocusNode;

class AddInput extends StatefulWidget {
  @override
  _AddInputState createState() => _AddInputState();
}

class _AddInputState extends State<AddInput> {
  static final _formKey1 = GlobalKey<FormState>(debugLabel: '_formKey1'),
      _formKey2 = GlobalKey<FormState>(debugLabel: '_formKey2');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasFocus || !currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: DefaultTabController(
          initialIndex: 0,
          length: 2,
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(210, 234, 251, 1), // blue1
                    Color.fromRGBO(230, 242, 252, 1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  InExAppBar(true),
                  Expanded(
                    child: TabBarView(
                      children: [
                        AddEditInput(
                          type: 'Expense',
                          formKey: _formKey2,
                        ),
                        AddEditInput(
                          type: 'Income',
                          formKey: _formKey1,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    )
        // )
        ;
  }
}

class AddEditInput extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final InputModel? inputModel;
  final String? type;
  final IconData? categoryIcon;
  const AddEditInput({
    required this.formKey,
    this.inputModel,
    this.type,
    this.categoryIcon,
  });
  @override
  Widget build(BuildContext context) {
    if (this.inputModel != null) {
      model = this.inputModel!;
      defaultCategory = categoryItem(this.categoryIcon!, model.category!);
      // Provider.of<ChangeModelType>(context, listen: false)
      //     .changeModelType(this.inputModel!.type!);
    } else {
      model = InputModel(
        type: this.type,
      );
      defaultCategory = categoryItem(Icons.category_outlined, 'Category');
      // Provider.of<ChangeModelType>(context, listen: false)
      //     .changeModelType(this.type!);
    }
    return ChangeNotifierProvider<ChangeCategoryA>(
        create: (context) => ChangeCategoryA(),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          children: [
            AmountCard(),
            SizedBox(height: 16.h),
            CategoryCard(),
            SizedBox(height: 16.h),
            DescriptionCard(),
            SizedBox(height: 16.h),
            DateCard(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: this.inputModel != null
                  ? SaveAndDeleteButton(
                      saveAndDeleteInput: true,
                      formKey: this.formKey,
                    )
                  : SaveButton(true, null, true),
            )
          ],
        ));
  }
}

class AmountCard extends StatefulWidget {
  @override
  _AmountCardState createState() => _AmountCardState();
}

class _AmountCardState extends State<AmountCard> {
  bool _isScanning = false;
  final ReceiptScannerService _scannerService = ReceiptScannerService();

  @override
  void initState() {
    super.initState();
    amountFocusNode = FocusNode();
    _amountController = TextEditingController(
      text: model.id == null ? '' : format(model.amount!),
    );
  }

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<void> _showScanOptions() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(getTranslated(context, 'Camera') ?? 'Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _scanReceipt(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(getTranslated(context, 'Gallery') ?? 'Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _scanReceipt(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _scanReceipt(ImageSource source) async {
    // Request permission based on source
    // ImagePicker handles gallery permission automatically on newer Androids
    // For camera, we still need explicit permission
    if (source == ImageSource.camera) {
      var status = await Permission.camera.request();
      if (!status.isGranted) {
        customToast(
            context,
            getTranslated(context, 'Camera permission required') ??
                'Camera permission required');
        return;
      }
    }

    setState(() => _isScanning = true);
    try {
      final image =
          await _scannerService.pickImage(source); // Using passed source
      if (image != null) {
        final data = await _scannerService.scanReceipt(image);

        // Update UI with scanned data
        if (data['amount'] != null) {
          double amount = data['amount'];
          _amountController.text = format(amount);
          model.amount = amount;
        }

        if (data['date'] != null) {
          model.date = data['date'];
        }

        if (data['description'] != null) {
          model.description = data['description'];
          _DescriptionCardState.descriptionController.text =
              data['description'];
        }

        customToast(
            context,
            getTranslated(context, 'Receipt scanned successfully') ??
                'Receipt scanned successfully');
      }
    } catch (e) {
      print('Scan error: $e');
      customToast(
          context,
          getTranslated(context, 'Failed to scan receipt') ??
              'Failed to scan receipt');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color colorMain = model.type == 'Income' ? green : red;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${getTranslated(context, 'Amount')}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (model.type ==
                          'Expense') // Only show for expense usually
                        GestureDetector(
                          onTap: _isScanning ? null : _showScanOptions,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: blue3.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                _isScanning
                                    ? SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : Icon(Icons.camera_alt,
                                        size: 16.sp, color: blue3),
                                SizedBox(width: 4.w),
                                Text(
                                  _isScanning
                                      ? (getTranslated(
                                              context, 'Scanning...') ??
                                          'Scanning...')
                                      : (getTranslated(
                                              context, 'Scan Receipt') ??
                                          'Scan Receipt'),
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: blue3,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // ... rest of TextFormField code ...
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    readOnly: false,
                    showCursor: true,
                    maxLines: null,
                    minLines: 1,
                    onTap: () {},
                    cursorColor: colorMain,
                    style: GoogleFonts.poppins(
                        color: colorMain,
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5),
                    focusNode: amountFocusNode,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: GoogleFonts.poppins(
                          color: colorMain.withOpacity(0.3),
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5),
                      icon: Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: Icon(
                          Icons.monetization_on,
                          size: 45.sp,
                          color: colorMain,
                        ),
                      ),
                      suffixIcon: _amountController.text.length > 0
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 24.sp,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                _amountController.clear();
                              })
                          : SizedBox(),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeCategoryA>(builder: (_, changeCategoryA, __) {
      changeCategoryA.categoryItemA ??= defaultCategory;
      var categoryItem = changeCategoryA.categoryItemA;
      model.category = categoryItem!.text;
      return ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () async {
                  CategoryItem newCategoryItem = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => model.type == 'Income'
                            ? IncomeCategory()
                            : ExpenseCategory()),
                  );
                  changeCategoryA.changeCategory(newCategoryItem);
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: (model.type == 'Income' ? green : red)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          iconData(categoryItem),
                          size: 28.sp,
                          color: model.type == 'Income' ? green : red,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          getTranslated(context, categoryItem.text) ??
                              categoryItem.text,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class DescriptionCard extends StatefulWidget {
  @override
  _DescriptionCardState createState() => _DescriptionCardState();
}

class _DescriptionCardState extends State<DescriptionCard> {
  static late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    descriptionFocusNode = FocusNode();
    descriptionController =
        TextEditingController(text: model.description ?? '');
  }

  // @override
  // void dispose(){
  //   descriptionFocusNode!.dispose();
  //   super.dispose();
  // }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
        nextFocus: false,
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        actions: [
          KeyboardActionsItem(
              focusNode: descriptionFocusNode!,
              toolbarButtons: [
                (node) {
                  return SizedBox(
                    width: 1.sw,
                    child: Padding(
                        padding: EdgeInsets.only(left: 5.w, right: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(amountFocusNode);
                              },
                              child: SizedBox(
                                height: 35.h,
                                width: 60.w,
                                child: Icon(Icons.keyboard_arrow_up,
                                    size: 25.sp, color: Colors.blueGrey),
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: () {
                            //     node.unfocus();
                            //     Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //             builder: (context) => model.type == 'Income'
                            //                 ? IncomeCategory()
                            //                 : ExpenseCategory()));
                            //   },
                            //   child: Text(
                            //     getTranslated(context, 'Choose Category')!,
                            //     style: TextStyle(
                            //         fontSize: 16.sp,
                            //         fontWeight: FontWeight.bold,
                            //         color: Colors.blueGrey),
                            //   ),
                            // ),
                            GestureDetector(
                                onTap: () => node.unfocus(),
                                child: Text(
                                  getTranslated(context, "Done")!,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ))
                          ],
                        )),
                  );
                },
              ])
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: KeyboardActions(
            overscroll: 0,
            disableScroll: true,
            tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
            autoScroll: false,
            config: _buildConfig(context),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: TextFormField(
                controller: descriptionController,
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                keyboardAppearance: Brightness.light,
                onTap: () {},
                cursorColor: Color.fromRGBO(89, 176, 222, 1),
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.4,
                ),
                focusNode: descriptionFocusNode,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: getTranslated(context, 'Description'),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontStyle: FontStyle.italic,
                    color: Colors.black38,
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: descriptionController.text.length > 0
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20.sp,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            descriptionController.clear();
                          })
                      : SizedBox(),
                  icon: Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: Icon(
                      Icons.description_outlined,
                      size: 28.sp,
                      color: Color.fromRGBO(89, 176, 222, 1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DateCard extends StatefulWidget {
  const DateCard();
  @override
  _DateCardState createState() => _DateCardState();
}

class _DateCardState extends State<DateCard> {
  @override
  Widget build(BuildContext context) {
    if (model.date == null) {
      model.date = DateFormat('dd/MM/yyyy').format(selectedDate);
      model.time = selectedTime.format(context);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showMaterialDatePicker(
                      headerColor: blue3,
                      headerTextColor: Colors.black,
                      backgroundColor: white,
                      buttonTextColor: Color.fromRGBO(80, 157, 253, 1),
                      cancelText: getTranslated(context, 'CANCEL'),
                      confirmText: getTranslated(context, 'OK') ?? 'OK',
                      maxLongSide: 450.w,
                      maxShortSide: 300.w,
                      title: getTranslated(context, 'Select a date'),
                      context: context,
                      firstDate: DateTime(1990, 1, 1),
                      lastDate: DateTime(2050, 12, 31),
                      selectedDate: DateFormat('dd/MM/yyyy').parse(model.date!),
                      onChanged: (value) => setState(() {
                        selectedDate = value;
                        model.date = DateFormat('dd/MM/yyyy').format(value);
                      }),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color:
                              Color.fromRGBO(89, 176, 222, 1).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.event,
                          size: 24.sp,
                          color: Color.fromRGBO(89, 176, 222, 1),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        DateFormat(sharedPrefs.dateFormat).format(
                            DateFormat('dd/MM/yyyy').parse(model.date!)),
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).push(
                      showPicker(
                          cancelText:
                              getTranslated(context, 'Cancel') ?? 'Cancel',
                          okText: getTranslated(context, 'Ok') ?? 'Ok',
                          unselectedColor: grey,
                          dialogInsetPadding: EdgeInsets.symmetric(
                              horizontal: 50.w, vertical: 30.0.h),
                          elevation: 12,
                          context: context,
                          value: Time(
                              hour: selectedTime.hour,
                              minute: selectedTime.minute),
                          is24HrFormat: true,
                          onChange: (value) => setState(() {
                                selectedTime = TimeOfDay(
                                    hour: value.hour, minute: value.minute);
                                model.time = selectedTime.format(context);
                              })),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color:
                              Color.fromRGBO(89, 176, 222, 1).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.access_time,
                          size: 24.sp,
                          color: Color.fromRGBO(89, 176, 222, 1),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        model.time!,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void saveInputFunc(BuildContext context, bool saveFunction) {
  model.amount = _amountController.text.isEmpty
      ? 0
      : double.parse(_amountController.text.replaceAll(',', ''));
  model.description = _DescriptionCardState.descriptionController.text;
  if (saveFunction) {
    FirestoreServices.addTransaction(model);
    _amountController.clear();
    if (_DescriptionCardState.descriptionController.text.length > 0) {
      _DescriptionCardState.descriptionController.clear();
    }
    customToast(context, 'Data has been saved');
  } else {
    FirestoreServices.updateTransaction(model);
    Navigator.pop(context);
    customToast(
        context,
        getTranslated(context, 'Transaction has been updated') ??
            'Transaction has been updated');
  }
}

Future<void> deleteInputFunction(
  BuildContext context,
) async {
  void onDeletion() {
    FirestoreServices.deleteTransaction(model.id!);
    Navigator.pop(context);
    customToast(context, 'Transaction has been deleted');
  }

  Platform.isIOS
      ? await iosDialog(
          context,
          'Are you sure you want to delete this transaction?',
          'Delete',
          onDeletion)
      : await androidDialog(
          context,
          'Are you sure you want to delete this transaction?',
          'Delete',
          onDeletion);
}
