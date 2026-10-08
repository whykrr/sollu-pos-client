import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/outlet_settings_service.dart';

typedef PosNudgeCallback = void Function(String entityType);

class PosReverbClient {
  final DioClient dioClient;
  final OutletSettingsService outletSettingsService;
  final PosNudgeCallback? onNudge;

  WebSocket? _socket;
  Timer? _reconnectTimer;
  Timer? _debounceTimer;
  bool _isDisposed = false;
  int _reconnectAttempts = 0;
  String? _currentSocketId;

  PosReverbClient({
    required this.dioClient,
    required this.outletSettingsService,
    this.onNudge,
  });

  bool get isConnected => _socket != null && _socket?.readyState == WebSocket.open;

  /// Buka koneksi WebSocket ke Reverb Server
  Future<void> connect() async {
    if (_isDisposed || isConnected) return;

    final outletProfile = outletSettingsService.getOutletProfile();
    final outletId = outletProfile?['id']?.toString();

    if (outletId == null || outletId.isEmpty) {
      debugPrint('[PosReverb] Outlet ID not found in profile. Reverb listener deferred.');
      return;
    }

    try {
      final wsScheme = AppConfig.reverbScheme == 'https' ? 'wss' : 'ws';
      final wsUrl =
          '$wsScheme://${AppConfig.reverbHost}:${AppConfig.reverbPort}/app/${AppConfig.reverbAppKey}?protocol=7&client=dart-pos&version=1.0.0&flash=false';

      debugPrint('[PosReverb] Connecting to Reverb at $wsUrl...');
      _socket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 10));

      _reconnectAttempts = 0;
      debugPrint('[PosReverb] WebSocket connection established.');

      _socket!.listen(
        (data) => _handleIncomingMessage(data.toString(), outletId),
        onError: (error) {
          debugPrint('[PosReverb] Socket error: $error');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('[PosReverb] Socket closed by server.');
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('[PosReverb] Failed to connect: $e');
      _scheduleReconnect();
    }
  }

  void _handleIncomingMessage(String rawMessage, String outletId) {
    try {
      final Map<String, dynamic> msg = jsonDecode(rawMessage);
      final String? event = msg['event'];

      if (event == 'pusher:connection_established') {
        final dynamic rawData = msg['data'];
        final Map<String, dynamic> data =
            rawData is String ? jsonDecode(rawData) : (rawData ?? {});
        _currentSocketId = data['socket_id']?.toString();
        debugPrint('[PosReverb] Handshake complete. socket_id: $_currentSocketId');

        if (_currentSocketId != null) {
          _subscribeChannel(_currentSocketId!, outletId);
        }
      } else if (event == 'pusher:ping') {
        _socket?.add(jsonEncode({'event': 'pusher:pong', 'data': {}}));
      } else if (event == 'pos.catalog.nudge' ||
          (msg['data'] != null && _isNudgePayload(msg['data']))) {
        _dispatchNudge(msg);
      }
    } catch (e) {
      debugPrint('[PosReverb] Error decoding message: $e');
    }
  }

  bool _isNudgePayload(dynamic rawData) {
    try {
      final Map<String, dynamic> data =
          rawData is String ? jsonDecode(rawData) : (rawData ?? {});
      return data['event'] == 'pos.catalog.nudge';
    } catch (_) {
      return false;
    }
  }

  void _dispatchNudge(Map<String, dynamic> msg) {
    dynamic rawData = msg['data'];
    Map<String, dynamic> data =
        rawData is String ? jsonDecode(rawData) : (rawData is Map ? Map<String, dynamic>.from(rawData) : {});

    final entityType = data['entity_type']?.toString() ?? 'product';
    debugPrint('[PosReverb] Sinyal pos.catalog.nudge diterima (entity: $entityType). Debouncing...');

    // Debounce nudge signal (200ms) agar mutasi batch tidak memicu multiple delta syncs serentak
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (onNudge != null && !_isDisposed) {
        onNudge!(entityType);
      }
    });
  }

  Future<void> _subscribeChannel(String socketId, String outletId) async {
    final channelName = 'private-outlet.$outletId.pos';
    try {
      debugPrint('[PosReverb] Authorizing channel $channelName via API...');
      final response = await dioClient.dio.post(
        '/api/broadcasting/auth',
        data: {
          'socket_id': socketId,
          'channel_name': channelName,
        },
      );

      final String? auth = response.data['auth']?.toString();
      if (auth != null && isConnected) {
        final subPayload = jsonEncode({
          'event': 'pusher:subscribe',
          'data': {
            'channel': channelName,
            'auth': auth,
          },
        });
        _socket?.add(subPayload);
        debugPrint('[PosReverb] Subscribed successfully to channel: $channelName');
      }
    } catch (e) {
      debugPrint('[PosReverb] Failed to authorize private channel $channelName: $e');
    }
  }

  void _scheduleReconnect() {
    _socket = null;
    if (_isDisposed) return;

    _reconnectAttempts++;
    final delaySeconds = (_reconnectAttempts * 3).clamp(3, 30);
    debugPrint('[PosReverb] Scheduling reconnect in $delaySeconds seconds (attempt $_reconnectAttempts)...');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      connect();
    });
  }

  /// Tutup koneksi WebSocket
  void disconnect() {
    _reconnectTimer?.cancel();
    _debounceTimer?.cancel();
    _socket?.close();
    _socket = null;
  }

  /// Bersihkan seluruh resource
  void dispose() {
    _isDisposed = true;
    disconnect();
  }
}
