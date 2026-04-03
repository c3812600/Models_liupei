import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../config/hex_config.dart';

enum ConnectionStateEnum {
  disconnected,
  connecting,
  connected,
}

/// TCP 网络服务：负责长连接与发送指令
class TcpService extends ChangeNotifier with WidgetsBindingObserver {
  Socket? _socket;
  ConnectionStateEnum _connectionState = ConnectionStateEnum.disconnected;

  ConnectionStateEnum get connectionState => _connectionState;
  
  // 定时重连 Timer
  Timer? _reconnectTimer;
  
  bool _isDisposed = false;

  TcpService() {
    WidgetsBinding.instance.addObserver(this);
    _initConnection();
  }

  /// 开始连接
  void _initConnection() async {
    if (_connectionState == ConnectionStateEnum.connecting || 
        _connectionState == ConnectionStateEnum.connected) {
      return;
    }
    
    _updateState(ConnectionStateEnum.connecting);

    try {
      debugPrint('Attempting to connect to ${HexConfig.serverIp}:${HexConfig.serverPort}...');
      _socket = await Socket.connect(
        HexConfig.serverIp, 
        HexConfig.serverPort, 
        timeout: const Duration(seconds: 5)
      );
      
      _updateState(ConnectionStateEnum.connected);
      debugPrint('Connected to ${HexConfig.serverIp}:${HexConfig.serverPort}');
      
      _socket?.listen(
        (List<int> data) {
          // 处理服务器返回的数据，如果需要的话
          debugPrint('Received data: $data');
        },
        onError: (error) {
          debugPrint('Socket Error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('Socket closed by server');
          _handleDisconnect();
        },
        cancelOnError: true,
      );
      
      // 连接成功后，清除重连定时器
      _reconnectTimer?.cancel();
      
    } catch (e) {
      debugPrint('Connection failed: $e');
      _handleDisconnect();
    }
  }

  /// 发送十六进制数据
  void sendHexCommand(String commandKey) {
    if (_socket != null && _connectionState == ConnectionStateEnum.connected) {
      final bytes = HexConfig.getCommandBytes(commandKey);
      if (bytes.isNotEmpty) {
        _socket?.add(bytes);
        debugPrint('Sent HEX command [$commandKey]: $bytes');
      } else {
        debugPrint('Warning: Empty or missing HEX command for key: $commandKey');
      }
    } else {
      debugPrint('Cannot send command. Not connected.');
    }
  }

  void _handleDisconnect() {
    if (_isDisposed) return;
    
    _socket?.destroy();
    _socket = null;
    _updateState(ConnectionStateEnum.disconnected);
    
    // 延迟 3 秒后重试连接
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_isDisposed) {
        _initConnection();
      }
    });
  }

  void _updateState(ConnectionStateEnum newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      notifyListeners();
    }
  }

  /// 手动重新连接
  void manualReconnect() {
    _socket?.destroy();
    _socket = null;
    _updateState(ConnectionStateEnum.disconnected);
    _initConnection();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _reconnectTimer?.cancel();
    _socket?.destroy();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;
    if (state == AppLifecycleState.resumed) {
      if (_connectionState != ConnectionStateEnum.connected) {
        _initConnection();
      }
    }
  }
}
