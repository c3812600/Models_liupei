import 'package:flutter/foundation.dart';
import '../services/tcp_service.dart';

/// 沙盘控制状态管理
class SandTableProvider extends ChangeNotifier {
  final TcpService _tcpService;

  // 各模块的开关状态
  final Map<String, bool> switches = {
    'residential': false,
    'clubhouse': false,
    'office': false,
    'outline_light': false,
    'commercial': false,
    'tower_crown': false,
    'landscape': false,
  };

  // 记录每个模块是否处于完全“关”的状态（总控“全暗”时会被标记为 true）
  final Map<String, bool> isTurnedOff = {
    'residential': false,
    'clubhouse': false,
    'office': false,
    'outline_light': false,
    'commercial': false,
    'tower_crown': false,
    'landscape': false,
  };

  // 总控状态
  bool isAllOn = false;

  SandTableProvider(this._tcpService);

  /// 切换按钮状态
  void toggleSwitch(String key) {
    if (_tcpService.connectionState != ConnectionStateEnum.connected) return;
    if (!switches.containsKey(key)) return;

    isTurnedOff[key] = false;
    isAllOn = false;

    switches[key] = !switches[key]!;
    
    // 发送对应指令
    final commandKey = '${key}_${switches[key]! ? 'on' : 'off'}';
    _tcpService.sendHexCommand(commandKey);

    _checkAllOnState();
    notifyListeners();
  }

  /// 直接设置按钮具体状态 (用于双按钮分离: 动态=true, 静态=false)
  void setSwitchState(String key, bool isOn) {
    if (_tcpService.connectionState != ConnectionStateEnum.connected) return;
    if (!switches.containsKey(key)) return;

    isTurnedOff[key] = false;
    isAllOn = false;
    switches[key] = isOn;
    
    final commandKey = '${key}_${isOn ? 'on' : 'off'}';
    _tcpService.sendHexCommand(commandKey);

    _checkAllOnState();
    notifyListeners();
  }

  /// 切换总控（全亮/全暗）
  void toggleMainControl() {
    if (_tcpService.connectionState != ConnectionStateEnum.connected) return;
    isAllOn = !isAllOn;

    if (isAllOn) {
      // 全亮
      switches.forEach((key, value) {
        switches[key] = true;
        isTurnedOff[key] = false;
      });
      
      _tcpService.sendHexCommand('main_all_on');
    } else {
      // 全暗
      switches.forEach((key, value) {
        switches[key] = false;
        isTurnedOff[key] = true;
      });

      _tcpService.sendHexCommand('main_all_off');
    }

    notifyListeners();
  }

  void _checkAllOnState() {
    for (var isOn in switches.values) {
      if (!isOn) {
        isAllOn = false;
        return;
      }
    }
  }
}
