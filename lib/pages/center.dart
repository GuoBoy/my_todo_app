import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_todo_app/request/api.dart';
import 'package:my_todo_app/store/controller.dart';

class CenterPage extends StatelessWidget {
  CenterPage({Key? key}) : super(key: key);

  final TextEditingController serverAddrCont = TextEditingController();
  final copied = false.obs;

  @override
  Widget build(BuildContext context) {
    StoreController sc = Get.find();
    // 更新server addr
    serverAddrCont.text = sc.serverAddr.value;

    return Scaffold(
        appBar: AppBar(
          title: const Text("个人中心"),
        ),
        body: Column(children: [
          // 是否登录了
          Obx(() => sc.logined.value
              ? Column(
                  // 已登陆
                  children: [
                    Text('username: ${sc.username}'),
                    Text('password: ${"*" * sc.password.value.length}'),
                    Text(
                      'token: ${sc.token}',
                      maxLines: 2,
                      style: const TextStyle(overflow: TextOverflow.ellipsis),
                    ),
                    Text('last_update_time:${sc.lastUpdateTime}'),
                    ElevatedButton(
                        onPressed: sc.loginOut, child: const Text("退出登录")),
                  ],
                )
              : Padding(
                  // 未登录
                  padding: const EdgeInsets.only(top: 50, bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Get.toNamed("/login");
                          },
                          child: const Text("登录")),
                      ElevatedButton(
                          onPressed: () {
                            Get.toNamed("/register");
                          },
                          child: const Text("注册")),
                    ],
                  ),
                )),
          // 服务器设置
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(width: 1), bottom: BorderSide(width: 1))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: serverAddrCont,
                  decoration: const InputDecoration(
                      hintText: "输入服务器地址",
                      prefix: Text(
                        "服务器地址：",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          sc.setServerAddr(serverAddrCont.text);
                          Get.snackbar("提示", "修改成功");
                        },
                        child: const Text("修改")),
                    ElevatedButton(
                        onPressed: () async {
                          var message = "服务器异常";
                          if (await testServer(serverAddrCont.text)) {
                            message = "服务器正常";
                          }
                          Get.snackbar("测试结果", message);
                        },
                        child: const Text("测试连接")),
                    ElevatedButton(
                        onPressed: () {
                          serverAddrCont.text = "";
                        },
                        child: const Text("重置")),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: serverAddrCont.text));
                        copied.value = true;
                        Timer(const Duration(seconds: 3),
                            () => copied.value = false);
                      },
                      icon: Obx(
                          () => Icon(copied.value ? Icons.check : Icons.share)),
                    )
                  ],
                )
              ],
            ),
          )
        ]));
  }
}
