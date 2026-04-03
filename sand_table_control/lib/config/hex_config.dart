/// 配置文件，用于配置每个状态对应的 HEX 数据
/// 用户可以在此修改各个按钮发送的指令内容
class HexConfig {
  // IP 和端口配置
  static const String serverIp = '192.168.18.119';
  static const int serverPort = 2756;

  // 心跳包配置（如果需要）
  static const String heartbeat = 'FF FF FF FF';

  // 命令字典：定义各个模块的不同状态对应的 HEX 指令
  // 建议将十六进制字符串格式统一为带空格的格式，如 "AA BB 01"
  static const Map<String, String> commands = {
    // ============ 住宅 ============
    'residential_on': 'FE 10 00 03 00 02 04 00 04 00 0A 41 6B',
    'residential_off': 'FE 10 00 08 00 02 04 00 04 00 0A 00 D8',

    // ============ 会所 ============
    'clubhouse_on': 'FE 10 00 0D 00 02 04 00 04 00 0A C0 E7',
    'clubhouse_off': 'FE 10 00 12 00 02 04 00 04 00 0A 81 AB',

    // ============ 办公 ============
    'office_on': 'FE 10 00 17 00 02 04 00 04 00 0A 41 94',
    'office_off': 'FE 10 00 1C 00 02 04 00 04 00 0A 00 27',

    // ============ 石材柱灯 ============
    'outline_light_on': 'FE 10 00 21 00 02 04 00 04 00 0A C2 AA',
    'outline_light_off': 'FE 10 00 26 00 02 04 00 04 00 0A 83 4C',

    // ============ 商业 ============
    'commercial_on': 'FE 05 00 08 FF 00 19 F7',
    'commercial_off': 'FE 05 00 08 00 00 58 07',

    // ============ 塔冠 ============
    'tower_crown_on': 'FE 05 00 09 FF 00 48 37',
    'tower_crown_off': 'FE 05 00 09 00 00 09 C7',

    // ============ 景观 ============
    'landscape_on': 'FE 05 00 0A FF 00 B8 37',
    'landscape_off': 'FE 05 00 0A 00 00 F9 C7',

    // ============ 总控 ============
    // 备注：全亮时所有灯光静态常亮
    'main_all_on': 'FE 05 00 0B FF 00 E9 F7',
    'main_all_off': 'FE 05 00 0B 00 00 A8 07',
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
