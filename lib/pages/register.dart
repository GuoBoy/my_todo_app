import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo_app/request/api.dart';
import 'package:my_todo_app/store/controller.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);

  final TextEditingController usernameCont = TextEditingController();
  final TextEditingController passwordCont = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    StoreController sc = Get.find();
    GlobalApi gapi = Get.find();

    return Scaffold(
        appBar: AppBar(
          title: const Text("注册"),
        ),
        body: Center(
            child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(children: [
                  TextFormField(
                    controller: usernameCont,
                    decoration: const InputDecoration(
                        hintText: "输入用户名", prefixIcon: Icon(Icons.person)),
                    validator: (String? v) => v == "" ? "不对" : null,
                  ),
                  TextFormField(
                    controller: passwordCont,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: "输入密码", prefixIcon: Icon(Icons.lock)),
                    validator: (String? v) => v == "" ? "不对" : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var ua = usernameCont.text;
                              var pd = passwordCont.text;
                              Response resp = await gapi.register({
                                'username': ua,
                                'password': pd,
                              });
                              var res = resp.body;
                              if (!resp.hasError && res['code'] == 200) {
                                Get.snackbar("", "注册成功");
                                sc.setUserInfo(ua, pd, res['token'], 1);
                                Timer(const Duration(seconds: 1), () {
                                  Get.offAllNamed("/");
                                });
                              } else {
                                Get.snackbar("", "注册失败");
                              }
                            }
                          },
                          child: const Text("注册")),
                      OutlinedButton(
                          onPressed: () {
                            Get.toNamed("/login");
                          },
                          child: const Text("登录"))
                    ],
                  )
                ]))));
  }
}
