/// 配置文件，用于配置每个状态对应的 HEX 数据
/// 用户可以在此修改各个按钮发送的指令内容
class HexConfig {
  // IP 和端口配置
  static const String serverIp = '192.168.10.1';
  static const int serverPort = 60001;

  // 心跳包配置（如果需要）
  static const String heartbeat = 'FF FF FF FF';

  // 命令字典：定义各个模块的不同状态对应的 HEX 指令
  // 建议将十六进制字符串格式统一为带空格的格式，如 "AA BB 01"
  static const Map<String, String> commands = {
    // ============ 住宅 ============
    'residential_on': 'FE 10 00 03 00 02 04 00 04 00 05 01 6F',
    'residential_off': 'FE 10 00 08 00 02 04 00 04 00 05 40 DC',

    // ============ 会所 ============
    'clubhouse_on': 'FE 10 00 0D 00 02 04 00 04 00 05 80 E3',
    'clubhouse_off': 'FE 10 00 12 00 02 04 00 04 00 05 C1 AF',

    // ============ 办公 ============
    'office_on': 'FE 10 00 17 00 02 04 00 04 00 05 01 90',
    'office_off': 'FE 10 00 17 00 02 04 00 04 00 05 01 90',

    // ============ 石材柱灯槽 ============
    'outline_light_on': 'FE 10 00 21 00 02 04 00 04 00 05 82 AE',
    'outline_light_off': 'FE 10 00 26 00 02 04 00 04 00 05 C3 48',

    // ============ 裙房 ============
    'commercial_on': 'FE 10 00 2B 00 02 04 00 04 00 05 02 D1',
    'commercial_off': 'FE 10 00 2B 00 02 04 00 04 00 05 02 D1',

    // ============ 塔冠 ============
    'tower_crown_on': 'FE 10 00 30 00 02 04 00 04 00 05 42 6E',
    'tower_crown_off': 'FE 10 00 30 00 02 04 00 04 00 05 42 6E',

    // ============ 首层景观 ============
    'landscape_on': 'FE 10 00 35 00 02 04 00 04 00 05 82 51',
    'landscape_off': 'FE 10 00 35 00 02 04 00 04 00 05 82 51',

    // ============ 总控 ============
    // 备注：全亮时所有灯光静态常亮
    'main_all_on': 'FE 10 00 3A 00 02 04 00 04 00 05 C2 11',
    'main_all_off': 'FE 10 00 3A 00 02 04 00 04 00 05 C2 11',
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
