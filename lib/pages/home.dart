import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:my_todo_app/request/api.dart';
import 'package:my_todo_app/store/controller.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StoreController sc = Get.find();

    return Container(
        child: sc.logined.value
            ? const LoginedHome()
            : Center(
                child: TextButton(
                onPressed: () {
                  Get.toNamed("/login");
                },
                child: const Text("还没有登录哈！点我去登陆~"),
              )));
  }
}

refreshToDoItem() {
  StoreController sc = Get.find();
  if (!sc.logined.value) {
    try {
      Get.defaultDialog(
          title: "提示",
          middleText: "还没有登录！",
          onConfirm: () {
            Get.offAndToNamed("/login");
          },
          onCancel: Get.back);
    } catch (_) {}
  } else {
    GlobalApi gapi = Get.find();
    // 检查是否需要完全刷新
    gapi.checkItemUpdate().then((value) {
      if (!value.hasError && value.body['code'] == 302) {
        var ltime = value.body['ltime'];
        gapi.getAllToDoItem().then((resp) {
          if (!resp.hasError &&
              resp.body['code'] == 200 &&
              resp.body['length'] != 0) {
            sc.setTodoItems(resp.body['data'], ltime);
          }
        });
      } else {
        Get.snackbar("", "已是最新版本~");
      }
    });
  }
}

class LoginedHome extends StatefulWidget {
  const LoginedHome({Key? key}) : super(key: key);

  @override
  State<LoginedHome> createState() => _LoginedHomeState();
}

class _LoginedHomeState extends State<LoginedHome>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // refreshToDoItem();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    StoreController sc = Get.find();
    print(sc.todoItems.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text("待办列表"),
        actions: [
          IconButton(
              onPressed: () {
                refreshToDoItem();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      // 下拉刷新
      body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              refreshToDoItem();
            });
          },
          // item列表
          child: Obx(() => sc.todoItems.isNotEmpty
              ? ListView.builder(
                  itemBuilder: (context, index) => ToDoItemView(
                    myself: sc.todoItems[index],
                  ),
                  itemCount: sc.todoItems.length,
                )
              : TextButton(
                  onPressed: () {
                    Get.toNamed("/edit");
                  },
                  child: const Text("还没有，点我新建~")))),
      // 去新建
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed("/edit");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ToDoItemView extends StatelessWidget {
  const ToDoItemView({Key? key, required this.myself}) : super(key: key);
  final Map<String, dynamic> myself;

  @override
  Widget build(BuildContext context) {
    GlobalApi gapi = Get.find();
    StoreController sc = Get.find();
    return Column(children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  myself['detail'],
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
                Text(
                  myself['update'],
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    Get.toNamed("/edit", arguments: myself);
                  },
                  child: const Icon(Icons.edit)),
              ElevatedButton(
                  onPressed: () async {
                    var message = "删除失败";
                    Response resp = await gapi.delToDoItem(myself['id']);
                    if (!resp.hasError && resp.body['code'] == 200) {
                      sc.delTodoItemById(
                          myself['id'], resp.body['last_update_time']);
                      message = "删除成功";
                    }
                    Get.snackbar("提示", message);
                  },
                  child: const Icon(Icons.delete)),
            ],
          )
        ],
      ),
      const Divider()
    ]);
  }
}
