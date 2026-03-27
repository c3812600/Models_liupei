import 'package:flutter/foundation.dart';
import '../services/tcp_service.dart';

/// 表示一个具有动态/静态互锁逻辑的控制行
class DoubleSwitchState {
  bool isDynamicOn;
  bool isStaticOn;

  DoubleSwitchState({this.isDynamicOn = false, this.isStaticOn = false});
}

/// 沙盘控制状态管理
class SandTableProvider extends ChangeNotifier {
  final TcpService _tcpService;

  // 各模块的状态 (动态和静态)
  final Map<String, DoubleSwitchState> doubleSwitches = {
    'residential': DoubleSwitchState(),
    'clubhouse': DoubleSwitchState(),
    'office': DoubleSwitchState(),
    'commercial': DoubleSwitchState(),
  };

  // 单开关模块的状态
  final Map<String, bool> singleSwitches = {
    'outline_light': false,
    'tower_crown': false,
    'landscape': false,
  };

  // 总控状态
  bool isAllOn = false;

  SandTableProvider(this._tcpService);

  /// 切换动态按钮状态
  void toggleDynamic(String key) {
    final state = doubleSwitches[key];
    if (state == null) return;

    // 如果静态已开启，动态是否失效？(根据"互锁"逻辑，互为失效)
    if (state.isStaticOn) return;

    state.isDynamicOn = !state.isDynamicOn;
    
    // 发送对应指令
    final commandKey = '${key}_dynamic_${state.isDynamicOn ? 'on' : 'off'}';
    _tcpService.sendHexCommand(commandKey);

    // 状态改变，如果全亮状态被破坏，则取消全亮标识
    _checkAllOnState();
    notifyListeners();
  }

  /// 切换静态按钮状态
  void toggleStatic(String key) {
    final state = doubleSwitches[key];
    if (state == null) return;

    // 根据需求：按动态时静态按钮失效
    if (state.isDynamicOn) return;

    state.isStaticOn = !state.isStaticOn;

    // 发送对应指令
    final commandKey = '${key}_static_${state.isStaticOn ? 'on' : 'off'}';
    _tcpService.sendHexCommand(commandKey);

    // 状态改变，如果全亮状态被破坏，则取消全亮标识
    _checkAllOnState();
    notifyListeners();
  }

  /// 切换单开关按钮状态
  void toggleSingle(String key) {
    if (!singleSwitches.containsKey(key)) return;

    singleSwitches[key] = !singleSwitches[key]!;
    
    // 发送对应指令
    final commandKey = '${key}_${singleSwitches[key]! ? 'on' : 'off'}';
    _tcpService.sendHexCommand(commandKey);

    // 状态改变，如果全亮状态被破坏，则取消全亮标识
    _checkAllOnState();
    notifyListeners();
  }

  /// 切换总控（全亮/全暗）
  void toggleMainControl() {
    isAllOn = !isAllOn;

    if (isAllOn) {
      // 备注：全亮时所有灯光静态常亮
      // 更新所有 UI 状态为静态开启，动态关闭，单开关全开
      doubleSwitches.forEach((key, state) {
        state.isDynamicOn = false;
        state.isStaticOn = true;
      });
      singleSwitches.forEach((key, value) {
        singleSwitches[key] = true;
      });
      
      _tcpService.sendHexCommand('main_all_on');
    } else {
      // 全暗
      doubleSwitches.forEach((key, state) {
        state.isDynamicOn = false;
        state.isStaticOn = false;
      });
      singleSwitches.forEach((key, value) {
        singleSwitches[key] = false;
      });

      _tcpService.sendHexCommand('main_all_off');
    }

    notifyListeners();
  }

  /// 检查是否所有灯光都处于“静态常亮”+ 单开关全开，如果是，则自动勾选总控
  void _checkAllOnState() {
    bool allStaticOn = true;
    for (var state in doubleSwitches.values) {
      if (!state.isStaticOn || state.isDynamicOn) {
        allStaticOn = false;
        break;
      }
    }

    bool allSingleOn = true;
    for (var isOn in singleSwitches.values) {
      if (!isOn) {
        allSingleOn = false;
        break;
      }
    }

    isAllOn = (allStaticOn && allSingleOn);
  }
}
