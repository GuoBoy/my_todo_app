import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo_app/request/api.dart';
import 'package:my_todo_app/store/controller.dart';

class EditTodo extends StatefulWidget {
  const EditTodo({Key? key}) : super(key: key);

  @override
  State<EditTodo> createState() => _EditTodoState();
}

class _EditTodoState extends State<EditTodo> {
  final TextEditingController _contentController = TextEditingController();
  var id = -1;
  var editing = true;

  @override
  void initState() {
    super.initState();
    var args = Get.arguments;
    if (args != null) {
      id = args['id'];
      _contentController.text = args['detail'];
      editing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    StoreController sc = Get.find();
    GlobalApi gapi = Get.find();

    return Scaffold(
        appBar: AppBar(
          title: Text('${id == -1 ? "新建便签" : "修改便签"} ${editing ? '*' : ''}'),
          actions: [
            IconButton(
              onPressed: () async {
                var content = _contentController.text;
                if (content.isEmpty) {
                  return;
                }
                var message = "保存失败";
                if (id == -1) {
                  // 新建
                  var resp =
                      await gapi.addToDoItem(FormData({'detail': content}));

                  var res = resp.body;
                  if (!resp.hasError && res['code'] == 200) {
                    setState(() {
                      id = res['id'];
                      editing = false;
                    });
                    // 更新列表和状态
                    var items = sc.todoItems.value;
                    items.add({
                      'id': res['id'],
                      'update': res['update'],
                      'detail': content,
                      'hashcode': res['hashcode']
                    });
                    items.sort(((a, b) => b['update'].compareTo(a['update'])));
                    sc.setTodoItems(items, res['last_update_time']);
                    message = "保存成功";
                  }
                } else {
                  // 修改
                  var resp = await gapi.updateToDoItem(
                      FormData({'detail': content}), id);
                  if (!resp.hasError && resp.body['code'] == 200) {
                    var res = resp.body;
                    setState(() {
                      editing = false;
                    });
                    var items = sc.todoItems.value;
                    for (var i = 0; i < items.length; i++) {
                      if (items[i].id == id) {
                        items[i] = {
                          'id': id,
                          'update': res['update'],
                          'detail': content,
                          'hashcode': res['hashcode']
                        };
                        break;
                      }
                    }
                    items.sort(((a, b) => b['update'].compareTo(a['update'])));
                    sc.setTodoItems(items, res['last_update_time']);
                    message = "保存成功";
                  }
                }
                Get.snackbar("提示", message);
              },
              icon: const Icon(Icons.save),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
          child: TextField(
            controller: _contentController,
            maxLines: 18,
            maxLength: 9999,
            decoration: const InputDecoration(hintText: "输入待办"),
            onChanged: (_) {
              setState(() {
                editing = true;
              });
            },
          ),
        ));
  }
}
