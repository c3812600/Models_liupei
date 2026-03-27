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

  // 总控状态
  bool isAllOn = false;

  SandTableProvider(this._tcpService);

  /// 切换按钮状态
  void toggleSwitch(String key) {
    if (!switches.containsKey(key)) return;

    switches[key] = !switches[key]!;
    
    // 发送对应指令
    final commandKey = '${key}_${switches[key]! ? 'on' : 'off'}';
    _tcpService.sendHexCommand(commandKey);

    // 状态改变，如果全亮状态被破坏，则取消全亮标识
    _checkAllOnState();
    notifyListeners();
  }

  /// 切换总控（全亮/全暗）
  void toggleMainControl() {
    isAllOn = !isAllOn;

    if (isAllOn) {
      // 备注：全亮时所有灯光开启
      switches.forEach((key, value) {
        switches[key] = true;
      });
      
      _tcpService.sendHexCommand('main_all_on');
    } else {
      // 全暗
      switches.forEach((key, value) {
        switches[key] = false;
      });

      _tcpService.sendHexCommand('main_all_off');
    }

    notifyListeners();
  }

  /// 检查是否所有灯光都处于开启，如果是，则自动勾选总控
  void _checkAllOnState() {
    bool allOn = true;
    for (var isOn in switches.values) {
      if (!isOn) {
        allOn = false;
        break;
      }
    }

    isAllOn = allOn;
  }
}
