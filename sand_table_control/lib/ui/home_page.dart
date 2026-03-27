import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/sand_table_provider.dart';
import '../services/tcp_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('沙盘控制'),
        centerTitle: true,
        actions: [
          _buildConnectionIndicator(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              // 控制列表
              Expanded(
                child: ListView(
                  children: [
                    _buildDoubleControlRow(context, '住宅', 'residential'),
                    _buildDoubleControlRow(context, '会所', 'clubhouse'),
                    _buildDoubleControlRow(context, '办公', 'office'),
                    _buildDoubleControlRow(context, '石材柱灯槽', 'outline_light'),
                    
                    Divider(height: 32.h),

                    _buildSingleControlRow(context, '裙房', 'commercial', textOn: '开', textOff: '关'),
                    _buildSingleControlRow(context, '塔冠', 'tower_crown', textOn: '开', textOff: '关'),
                    _buildSingleControlRow(context, '首层景观', 'landscape', textOn: '开', textOff: '关'),

                    Divider(height: 32.h),

                    // 总控
                    _buildMainControlRow(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建右上角 WiFi / TCP 连接状态指示器
  Widget _buildConnectionIndicator() {
    return Consumer<TcpService>(
      builder: (context, tcpService, child) {
        IconData icon;
        Color color;
        String tooltip;

        switch (tcpService.connectionState) {
          case ConnectionStateEnum.connected:
            icon = Icons.wifi;
            color = Colors.green;
            tooltip = '已连接到控制器';
            break;
          case ConnectionStateEnum.connecting:
            icon = Icons.wifi_protected_setup;
            color = Colors.orange;
            tooltip = '正在连接...';
            break;
          case ConnectionStateEnum.disconnected:
          default:
            icon = Icons.wifi_off;
            color = Colors.red;
            tooltip = '未连接';
            break;
        }

        return IconButton(
          icon: Icon(icon, color: color),
          tooltip: tooltip,
          onPressed: () {
            // 手动触发重连
            if (tcpService.connectionState != ConnectionStateEnum.connected) {
              tcpService.manualReconnect();
            }
          },
        );
      },
    );
  }

  /// 构建双按钮控制行（动态/静态分离）
  Widget _buildDoubleControlRow(BuildContext context, String title, String key) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          Consumer<SandTableProvider>(
            builder: (context, provider, child) {
              final value = provider.switches[key] ?? false;
              final isTurnedOff = provider.isTurnedOff[key] ?? false;
              
              // 动态：当 value 为 true 且没有被全暗锁定时激活
              final isDynamicActive = !isTurnedOff && value == true;
              // 静态：当 value 为 false 且没有被全暗锁定时激活
              final isStaticActive = !isTurnedOff && value == false;

              return Row(
                children: [
                  _StateButton(
                    label: '动态',
                    isActive: isDynamicActive,
                    activeColor: Colors.green,
                    onTap: () => provider.setSwitchState(key, true),
                  ),
                  SizedBox(width: 12.w),
                  _StateButton(
                    label: '静态',
                    isActive: isStaticActive,
                    activeColor: Colors.blue,
                    onTap: () => provider.setSwitchState(key, false),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建单开关控制行
  Widget _buildSingleControlRow(
    BuildContext context, 
    String title, 
    String key, 
    {String textOn = '开', String textOff = '关', Color colorOn = Colors.green, Color colorOff = Colors.grey}
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          Consumer<SandTableProvider>(
            builder: (context, provider, child) {
              final value = provider.switches[key] ?? false;
              final isTurnedOff = provider.isTurnedOff[key] ?? false;
              
              // 如果该模块处于全暗关闭状态，则显示“关”
              final displayLabel = isTurnedOff ? '关' : (value ? textOn : textOff);
              
              return _CustomSwitch(
                label: displayLabel,
                value: value,
                activeColor: colorOn,
                inactiveColor: colorOff,
                onChanged: (val) => provider.toggleSwitch(key),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建总控行
  Widget _buildMainControlRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('总控', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.blue)),
          Consumer<SandTableProvider>(
            builder: (context, provider, child) {
              return _CustomSwitch(
                label: provider.isAllOn ? '全亮' : '全暗',
                value: provider.isAllOn,
                activeColor: Colors.blue,
                onChanged: (val) => provider.toggleMainControl(),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 自定义开关组件，根据草图需求显示方框文字形式的切换按钮
class _CustomSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final bool isDisabled;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const _CustomSwitch({
    Key? key,
    required this.label,
    required this.value,
    this.isDisabled = false,
    required this.onChanged,
    this.activeColor = Colors.green,
    this.inactiveColor = const Color(0xFFBDBDBD), // 默认灰色 Colors.grey[400]
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 禁用或根据状态改变颜色，当全暗时 label 为 '关' 或者 '全暗'，通常对应 false，此时如果需要强制灰色，可以在外部传灰色。
    // 如果想要按钮在特定状态下强制为灰色，这里直接通过 label 判断或者依赖传入的 inactiveColor
    Color bgColor;
    if (isDisabled) {
      bgColor = Colors.grey[300]!;
    } else if (label == '关' || label == '全暗') {
      bgColor = Colors.grey[400]!;
    } else {
      bgColor = value ? activeColor : inactiveColor;
    }

    final textColor = isDisabled ? Colors.grey[500] : Colors.white;

    return GestureDetector(
      onTap: isDisabled ? null : () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: Colors.black12,
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 简单的状态按钮，用于双按钮并排的情况
class _StateButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _StateButton({
    Key? key,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive ? activeColor : const Color(0xFFBDBDBD);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black12,
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
