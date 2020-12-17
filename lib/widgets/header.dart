import 'package:flutter/material.dart';

AppBar header({bool isAppTitle =false,String titleText, removeBackButton =false}) {
  return AppBar(
     automaticallyImplyLeading: removeBackButton ? false : true,
    elevation: 0,
    backgroundColor: Colors.white,
    title: Text(
      
      isAppTitle ?
      'FlutterSocial': titleText,style: TextStyle(
      color: Colors.black,
      fontFamily: isAppTitle?'Signatra': '',
      fontSize: isAppTitle? 50:22,

    ),
    ),
    centerTitle: true,
  );
}
