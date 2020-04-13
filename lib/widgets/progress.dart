import 'package:flutter/material.dart';

Container circularProgress() {
  //뱅글뱅글 돌아가는 로딩표시 아이콘
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}

Container linearProgress() {
  //선 모양으로 쭉 쭉 나아가는 로딩표시
  return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.purple),
      ));
}
