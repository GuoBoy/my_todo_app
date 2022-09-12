import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StoreController extends GetxController {
  final box = GetStorage();
  var username = "".obs;
  var password = "".obs;
  // var uid = 0.obs;
  var token = "".obs;
  var lastUpdateTime = 1.obs;
  var logined = false.obs;
  final todoItems = RxList<dynamic>();

  setUserInfo(String ua, String pd, String tk, int lt) {
    if (ua.isNotEmpty && pd.isNotEmpty) {
      username.value = ua;
      password.value = pd;
      // uid.value = userid;
      token.value = tk;
      lastUpdateTime.value = lt;
      logined.value = true;
      // 写入登录信息
      box.write("username", ua);
      box.write("password", pd);
      box.write("token", tk);
      box.write("last_update_time", lt);
    }
  }

  loginOut() {
    username.value = "";
    password.value = "";
    // uid.value = 0;
    token.value = "";
    lastUpdateTime.value = 1;
    logined.value = false;
    // 清除登录信息
    box.write("username", "");
    box.write("password", "");
    // box.write("uid", 0);
    box.remove("token");
    box.write("last_update_time", 1);
    todoItems.value = [];
    box.remove("todo_items");
  }

  var serverAddr = "".obs;

  setServerAddr(String addr) {
    if (addr.isNotEmpty) {
      if (!addr.startsWith("http")) {
        addr = 'http://$addr';
      }
      if (!addr.endsWith("/")) {
        // serverAddr.value = serverAddr.value.substring(0, serverAddr.value.length-1);
        addr = '$addr/';
      }
      serverAddr.value = addr;
      box.write("server_addr", addr);
    }
  }

  setTodoItems(List<dynamic> tis, int ltime) {
    todoItems.value = [];
    todoItems.value = tis;
    box.write("todo_items", tis);
    lastUpdateTime.value = ltime;
    box.write("last_update_time", ltime);
  }

  delTodoItemById(int id, int lt) {
    var res = todoItems.where((element) => element['id'] != id).toList();
    setTodoItems(res, lt);
  }

  // 初始化
  @override
  void onInit() {
    super.onInit();
    // 初始化登录信息
    var ua = box.read("username") ?? "";
    var pd = box.read("password") ?? "";
    // var userid = box.read("uid") ?? 0;
    var tk = box.read("token") ?? "";
    if (!(ua.isEmpty || pd.isEmpty || tk.isEmpty)) {
      username.value = ua;
      password.value = pd;
      // uid.value = userid;
      token.value = tk;
      logined.value = true;
      lastUpdateTime.value = box.read("last_update_time") ?? 1;
      todoItems.value = box.read("todo_items") ?? [];
    }
    // server
    serverAddr.value = box.read("server_addr") ?? "http://192.168.31.127:80/";
  }
}
