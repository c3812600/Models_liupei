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
              // 顶部提示
              Text(
                '备注：全亮时所有灯光静态常亮\n动态和静态按钮互锁(按动态时，静态按钮失效，再按一次动态按钮关闭灯光后，按静态按钮才能用)',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // 控制列表
              Expanded(
                child: ListView(
                  children: [
                    _buildDoubleControlRow(context, '住宅', 'residential'),
                    _buildDoubleControlRow(context, '会所', 'clubhouse'),
                    _buildDoubleControlRow(context, '办公', 'office'),
                    _buildDoubleControlRow(context, '商业', 'commercial'),
                    
                    Divider(height: 32.h),

                    _buildSingleControlRow(context, '轮廓灯', 'outline_light'),
                    _buildSingleControlRow(context, '塔冠', 'tower_crown'),
                    _buildSingleControlRow(context, '景观', 'landscape'),

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

  /// 构建带有动态/静态互锁的控制行
  Widget _buildDoubleControlRow(BuildContext context, String title, String key) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          Consumer<SandTableProvider>(
            builder: (context, provider, child) {
              final state = provider.doubleSwitches[key];
              if (state == null) return const SizedBox.shrink();

              // 互锁逻辑
              final isDynamicDisabled = state.isStaticOn;
              final isStaticDisabled = state.isDynamicOn;

              return Row(
                children: [
                  _CustomSwitch(
                    label: '动态',
                    value: state.isDynamicOn,
                    isDisabled: isDynamicDisabled,
                    onChanged: (val) => provider.toggleDynamic(key),
                  ),
                  SizedBox(width: 16.w),
                  _CustomSwitch(
                    label: '静态',
                    value: state.isStaticOn,
                    isDisabled: isStaticDisabled,
                    onChanged: (val) => provider.toggleStatic(key),
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
  Widget _buildSingleControlRow(BuildContext context, String title, String key) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          Consumer<SandTableProvider>(
            builder: (context, provider, child) {
              final value = provider.singleSwitches[key] ?? false;
              return _CustomSwitch(
                label: '开关',
                value: value,
                onChanged: (val) => provider.toggleSingle(key),
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

  const _CustomSwitch({
    Key? key,
    required this.label,
    required this.value,
    this.isDisabled = false,
    required this.onChanged,
    this.activeColor = Colors.green,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 禁用状态的颜色处理
    final bgColor = isDisabled
        ? Colors.grey[300]
        : (value ? activeColor : Colors.grey[400]);
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
