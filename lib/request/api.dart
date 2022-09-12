import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:my_todo_app/store/controller.dart';

const whiteList = ['login', 'register'];

class GlobalApi extends GetConnect {
  StoreController sc = Get.find();

  void beforeRequest() {
    httpClient.baseUrl = sc.serverAddr.value;
    httpClient.addRequestModifier((Request request) {
      request.headers['Authorization'] = sc.token.value;
      return request;
    });
  }

  // 登录
  Future<Response> login(Map<String, String> data) {
    beforeRequest();
    return post('api/login', data);
  }

  // 注册
  Future<Response> register(Map<String, String> data) {
    beforeRequest();
    return post("api/register", data);
  }

  // 测试服务器连接
  // Future<Response> testServer(String addr) {
  //   return get(addr);
  // }

  // 添加item
  Future<Response> addToDoItem(FormData data) {
    beforeRequest();
    return post("api/todo", data);
  }

  // 删除待办
  Future<Response> delToDoItem(int tid) {
    beforeRequest();
    return delete("api/todo/$tid");
  }

  // 更新便签
  Future<Response> updateToDoItem(FormData data, int tid) {
    beforeRequest();
    return post("api/todo/$tid", data);
  }

  // 获取所有todo
  Future<Response> getAllToDoItem() {
    beforeRequest();
    return get("api/todo");
  }

  // 检查是否需要更新便签
  Future<Response> checkItemUpdate() {
    beforeRequest();
    return get("api/todo/checkUpdate/${sc.lastUpdateTime}");
  }
}

Future<bool> testServer(String url) async {
  try {
    var res = await GetConnect().get(url);
    if (!res.hasError && res.body['code'] == 200) {
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}
