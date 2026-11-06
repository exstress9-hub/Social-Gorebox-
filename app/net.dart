import 'dart:async';
import 'dart:convert';
import 'dart:io';

const discoveryPort = 45454;
const gamePort = 45455;

Future<List<String>> localIps() async {
  final r = <String>[];
  for (final i in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
    for (final a in i.addresses) {
      if (!a.isLoopback) r.add(a.address);
    }
  }
  return r;
}

class Room {
  final String host, ip;
  final int players;
  final String game;
  Room(this.host, this.ip, this.players, {this.game = 'impostor'});
}

class Beacon {
  Timer? _t;
  RawDatagramSocket? _s;

  Future<void> start(String host, List<String> ips, int Function() players, String Function() game) async {
    _s = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _s!.broadcastEnabled = true;
    final targets = <String>{
      '255.255.255.255',
      for (final ip in ips) '${ip.substring(0, ip.lastIndexOf('.'))}.255',
    };
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      final msg = utf8.encode(jsonEncode({
        'app': 'muhammetaly',
        'host': host,
        'players': players(),
        'game': game()
      }));
      for (final t in targets) {
        try {
          _s!.send(msg, InternetAddress(t), discoveryPort);
        } catch (_) {}
      }
    });
  }

  void stop() {
    _t?.cancel();
    _s?.close();
  }
}

class Discovery {
  RawDatagramSocket? _s;
  Timer? _t;
  final _rooms = <String, Room>{};
  final _seen = <String, DateTime>{};
  final _c = StreamController<List<Room>>.broadcast();
  Stream<List<Room>> get stream => _c.stream;

  Future<void> start() async {
    try {
      _s = await RawDatagramSocket.bind(InternetAddress.anyIPv4, discoveryPort, reuseAddress: true);
    } catch (_) {
      return;
    }
    _s!.listen((e) {
      if (e != RawSocketEvent.read) return;
      final d = _s!.receive();
      if (d == null) return;
      try {
        final m = jsonDecode(utf8.decode(d.data)) as Map;
        if (m['app'] != 'muhammetaly') return;
        final ip = d.address.address;
        _rooms[ip] = Room(
          m['host'] as String,
          ip,
          m['players'] as int,
          game: (m['game'] as String?) ?? 'impostor',
        );
        _seen[ip] = DateTime.now();
        _c.add(_rooms.values.toList());
      } catch (_) {}
    });
    _t = Timer.periodic(const Duration(seconds: 2), (_) {
      final old = DateTime.now().subtract(const Duration(seconds: 5));
      final before = _rooms.length;
      _seen.removeWhere((k, v) {
        final gone = v.isBefore(old);
        if (gone) _rooms.remove(k);
        return gone;
      });
      if (before != _rooms.length) _c.add(_rooms.values.toList());
    });
  }

  void stop() {
    _t?.cancel();
    _s?.close();
  }
}

class HostNet {
  final String hostName;
  final void Function() onChange;
  final void Function(Map m)? onClientEvent;
  HostNet(this.hostName, this.onChange, {this.onClientEvent});

  HttpServer? _srv;
  final _clients = <WebSocket, String>{};
  List<String> get names => [hostName, ..._clients.values];

  Future<void> start() async {
    _srv = await HttpServer.bind(InternetAddress.anyIPv4, gamePort, shared: true);
    _srv!.listen((req) async {
      if (!WebSocketTransformer.isUpgradeRequest(req)) {
        req.response.statusCode = 404;
        await req.response.close();
        return;
      }
      final ws = await WebSocketTransformer.upgrade(req);
      ws.listen((d) {
        final m = jsonDecode(d as String) as Map;
        if (m['t'] == 'join') {
          var n = (m['name'] as String).trim();
          if (n.isEmpty) n = 'Player';
          while (names.contains(n)) {
            n = '$n+';
          }
          _clients[ws] = n;
          _push();
        } else {
          if (onClientEvent != null) onClientEvent!(m);
        }
      }, onDone: () {
        _clients.remove(ws);
        _push();
      });
    });
  }

  void _push() {
    onChange();
    broadcast({'t': 'players', 'list': names});
  }

  void broadcast(Map m) {
    final msg = jsonEncode(m);
    for (final ws in _clients.keys) {
      ws.add(msg);
    }
  }

  void sendTo(String name, Map m) {
    for (final e in _clients.entries) {
      if (e.value == name) e.key.add(jsonEncode(m));
    }
  }

  void close() {
    for (final ws in _clients.keys.toList()) {
      ws.close();
    }
    _srv?.close(force: true);
  }
}

class ClientNet {
  late WebSocket ws;

  Future<void> connect(String ip, String name) async {
    ws = await WebSocket.connect('ws://$ip:$gamePort').timeout(const Duration(seconds: 5));
    ws.add(jsonEncode({'t': 'join', 'name': name}));
  }

  void send(Map m) {
    ws.add(jsonEncode(m));
  }

  void listen(void Function(Map) onMsg, void Function() onClose) =>
      ws.listen((d) => onMsg(jsonDecode(d as String) as Map), onDone: onClose);

  void close() => ws.close();
}
