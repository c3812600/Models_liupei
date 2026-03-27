/// 配置文件，用于配置每个状态对应的 HEX 数据
/// 用户可以在此修改各个按钮发送的指令内容
class HexConfig {
  // IP 和端口配置
  static const String serverIp = '192.168.18.119';
  static const int serverPort = 60001;

  // 心跳包配置（如果需要）
  static const String heartbeat = 'FF FF FF FF';

  // 命令字典：定义各个模块的不同状态对应的 HEX 指令
  // 建议将十六进制字符串格式统一为带空格的格式，如 "AA BB 01"
  static const Map<String, String> commands = {
    // ============ 住宅 ============
    'residential_on': 'AA 01 01 01',
    'residential_off': 'AA 01 01 00',

    // ============ 会所 ============
    'clubhouse_on': 'AA 02 01 01',
    'clubhouse_off': 'AA 02 01 00',

    // ============ 办公 ============
    'office_on': 'AA 03 01 01',
    'office_off': 'AA 03 01 00',

    // ============ 轮廓灯 ============
    'outline_light_on': 'AA 05 00 01',
    'outline_light_off': 'AA 05 00 00',

    // ============ 商业 ============
    'commercial_on': 'AA 04 01 01',
    'commercial_off': 'AA 04 01 00',

    // ============ 塔冠 ============
    'tower_crown_on': 'AA 06 00 01',
    'tower_crown_off': 'AA 06 00 00',

    // ============ 景观 ============
    'landscape_on': 'AA 07 00 01',
    'landscape_off': 'AA 07 00 00',

    // ============ 总控 ============
    // 备注：全亮时所有灯光静态常亮
    'main_all_on': 'AA 08 00 01',
    'main_all_off': 'AA 08 00 00',
  };

  /// 获取指定键的 HEX 指令列表（将字符串解析为 bytes）
  static List<int> getCommandBytes(String key) {
    final hexString = commands[key];
    if (hexString == null || hexString.isEmpty) return [];
    
    // 去除空格并将16进制字符串转换为字节列表
    final cleanedHex = hexString.replaceAll(' ', '');
    final List<int> bytes = [];
    for (int i = 0; i < cleanedHex.length; i += 2) {
      if (i + 2 <= cleanedHex.length) {
        bytes.add(int.parse(cleanedHex.substring(i, i + 2), radix: 16));
      }
    }
    return bytes;
  }
}
