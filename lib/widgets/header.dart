import 'package:flutter/material.dart';

AppBar header(BuildContext context,
    {bool isAppTitle = false, String titleText, bool removeBackButton = false}) {//인자에 isAppTitle이 True이면 titleText 인자를 받아온다
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,//이를 통해 회원가입 시(닉네임 입력 시) 돌아가기 버튼을 없엔다.
    title: Text(      
      isAppTitle ? "FlutterShare" : titleText,
      style: TextStyle(
          color: Colors.white,
          fontFamily: isAppTitle ? "Signatra" : "",
          fontSize: isAppTitle ? 50.0 : 22.0),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
