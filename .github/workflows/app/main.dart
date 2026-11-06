import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'i18n.dart';
import 'net.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: lang,
        builder: (_, __, ___) => MaterialApp(
          title: 'Muhammetaly',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: Colors.deepPurple,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          home: Home(),
        ),
      );
}

String _playerName(TextEditingController c) =>
    c.text.trim().isEmpty ? 'Oyuncu${Random().nextInt(90) + 10}' : c.text.trim();

class Home extends StatelessWidget {
  Home({super.key});
  final nameC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muhammetaly 🎮', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => lang.value = 'tr', child: const Text('TR', style: TextStyle(fontWeight: FontWeight.bold))),
          TextButton(onPressed: () => lang.value = 'ru', child: const Text('RU', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(t('sub'), style: title),
        const SizedBox(height: 12),
        TextField(
          controller: nameC,
          decoration: InputDecoration(
            labelText: t('name'),
            prefixIcon: const Icon(Icons.person),
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: const Icon(Icons.wifi_find),
          label: Text(t('join'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JoinScreen(name: _playerName(nameC)))),
        ),
        const SizedBox(height: 20),
        Text(t('tap'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        for (final c in cats) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(children: [
              Icon(c.icon, color: Colors.purpleAccent),
              const SizedBox(width: 8),
              Text(t(c.id), style: title?.copyWith(fontWeight: FontWeight.bold)),
            ]),
          ),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final g in c.games)
              ActionChip(
                elevation: playable.contains(g) ? 2 : 0,
                backgroundColor: playable.contains(g) ? Colors.deepPurple.withOpacity(0.3) : null,
                label: Text(
                  playable.contains(g) ? t(g) : '${t(g)} • ${t('soon')}',
                  style: TextStyle(fontWeight: playable.contains(g) ? FontWeight.bold : FontWeight.normal),
                ),
                onPressed: () {
                  if (!playable.contains(g)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('soon'))));
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Lobby(name: _playerName(nameC), game: g)));
                },
              ),
          ]),
        ],
      ]),
    );
  }
}

class JoinScreen extends StatefulWidget {
  final String name;
  const JoinScreen({super.key, required this.name});
  @override
  State<JoinScreen> createState() => _JoinState();
}

class _JoinState extends State<JoinScreen> {
  final disc = Discovery();
  final ipC = TextEditingController();

  @override
  void initState() {
    super.initState();
    disc.start();
  }

  @override
  void dispose() {
    disc.stop();
    super.dispose();
  }

  Future<void> go(String ip) async {
    final c = ClientNet();
    try {
      await c.connect(ip, widget.name);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => Lobby(name: widget.name, client: c)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('fail'))));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('join'))),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(t('searching'), style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          StreamBuilder<List<Room>>(
            stream: disc.stream,
            initialData: const [],
            builder: (_, s) => Column(children: [
              if (s.data!.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              for (final r in s.data!)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.wifi)),
                    title: Text(r.host, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('IP: ${r.ip} • ${r.players} Oyuncu • Oyun: ${t(r.game)}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => go(r.ip),
                  ),
                ),
            ]),
          ),
          const Divider(height: 36),
          Text(t('manual'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: ipC,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '192.168.43.1', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.login),
            onPressed: () => go(ipC.text.trim()),
            label: Text(t('connect')),
          ),
        ]),
      );
}

class Lobby extends StatefulWidget {
  final String name;
  final String? game;
  final ClientNet? client;
  const Lobby({super.key, required this.name, this.game, this.client});
  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  HostNet? host;
  Beacon? beacon;
  List<String> players = [];
  List<String> ips = [];
  String activeGame = 'impostor';
  bool get isHost => widget.client == null;

  bool dealt = false;
  String? secretWord;
  String? secretLocation;
  String? secretRole;
  bool isSpyOrImpostor = false;
  String? buzzerWinner;
  Map<String, String> votes = {};
  String? votedSuspect;
  String? voteResultText;

  @override
  void initState() {
    super.initState();
    activeGame = widget.game ?? 'impostor';
    if (isHost) {
      _startHost();
    } else {
      widget.client!.listen(_onMsg, () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  Future<void> _startHost() async {
    host = HostNet(
      widget.name,
      () {
        if (mounted) setState(() => players = host!.names);
      },
      onClientEvent: _handleClientEventOnHost,
    );
    await host!.start();
    ips = await localIps();
    beacon = Beacon();
    await beacon!.start(widget.name, ips, () => host!.names.length, () => activeGame);
    if (mounted) setState(() => players = host!.names);
  }

  void _handleClientEventOnHost(Map m) {
    if (m['t'] == 'buzzer_hit') {
      if (buzzerWinner == null) {
        setState(() => buzzerWinner = m['by']);
        host!.broadcast({'t': 'buzzer_winner', 'by': m['by']});
      }
    } else if (m['t'] == 'vote') {
      setState(() => votes[m['from']] = m['target']);
      host!.broadcast({'t': 'vote_update', 'count': votes.length, 'total': players.length});
      if (votes.length >= players.length) {
        _finalizeVotes();
      }
    }
  }

  void _onMsg(Map m) {
    if (!mounted) return;
    if (m['t'] == 'players') setState(() => players = List<String>.from(m['list'] as List));
    if (m['t'] == 'game') setState(() => activeGame = m['game'] as String);
    if (m['t'] == 'role') {
      setState(() {
        dealt = true;
        secretWord = m['word'];
        secretLocation = m['location'];
        secretRole = m['role'];
        isSpyOrImpostor = m['is_impostor'] ?? (m['word'] == null && activeGame == 'impostor');
        buzzerWinner = null;
        votes.clear();
        voteResultText = null;
      });
    }
    if (m['t'] == 'buzzer_winner') setState(() => buzzerWinner = m['by']);
    if (m['t'] == 'buzzer_reset') setState(() => buzzerWinner = null);
    if (m['t'] == 'vote_result') {
      setState(() => voteResultText = m['text']);
    }
  }

  void _startDeal() {
    final rnd = Random();
    votes.clear();
    voteResultText = null;
    buzzerWinner = null;

    if (activeGame == 'impostor') {
      final list = lang.value == 'ru' ? ruWords : trWords;
      final w = list[rnd.nextInt(list.length)];
      final imp = rnd.nextInt(players.length);

      for (var i = 0; i < players.length; i++) {
        final isImp = (i == imp);
        final payload = {'t': 'role', 'word': isImp ? null : w, 'is_impostor': isImp};
        if (i == 0) {
          _onMsg(payload);
        } else {
          host!.sendTo(players[i], payload);
        }
      }
    } else if (activeGame == 'spy') {
      final loc = spyLocations[rnd.nextInt(spyLocations.length)];
      final locName = lang.value == 'ru' ? loc.nameRu : loc.nameTr;
      final roles = lang.value == 'ru' ? loc.rolesRu : loc.rolesTr;
      final spyIdx = rnd.nextInt(players.length);

      for (var i = 0; i < players.length; i++) {
        final isSpy = (i == spyIdx);
        final payload = {
          't': 'role',
          'location': isSpy ? null : locName,
          'role': isSpy ? (lang.value == 'ru' ? 'ШПИОН' : 'CASUS') : roles[i % roles.length],
          'is_impostor': isSpy
        };
        if (i == 0) {
          _onMsg(payload);
        } else {
          host!.sendTo(players[i], payload);
        }
      }
    } else if (activeGame == 'buzzer') {
      host!.broadcast({'t': 'role', 'game': 'buzzer'});
      setState(() => dealt = true);
    }
  }

  void _finalizeVotes() {
    final tally = <String, int>{};
    for (final v in votes.values) {
      tally[v] = (tally[v] ?? 0) + 1;
    }
    String? maxVoted;
    int maxC = 0;
    tally.forEach((k, v) {
      if (v > maxC) {
        maxC = v;
        maxVoted = k;
      }
    });
    final text = 'En çok oyu alan: $maxVoted ($maxC oy)!';
    host!.broadcast({'t': 'vote_result', 'text': text});
    setState(() => voteResultText = text);
  }

  void _pressBuzzer() {
    if (isHost) {
      if (buzzerWinner == null) {
        setState(() => buzzerWinner = widget.name);
        host!.broadcast({'t': 'buzzer_winner', 'by': widget.name});
      }
    } else {
      widget.client!.send({'t': 'buzzer_hit', 'by': widget.name});
    }
  }

  void _resetBuzzer() {
    if (isHost) {
      setState(() => buzzerWinner = null);
      host!.broadcast({'t': 'buzzer_reset'});
    }
  }

  void _castVote(String target) {
    setState(() => votedSuspect = target);
    if (isHost) {
      votes[widget.name] = target;
      if (votes.length >= players.length) _finalizeVotes();
    } else {
      widget.client!.send({'t': 'vote', 'from': widget.name, 'target': target});
    }
  }

  @override
  void dispose() {
    host?.close();
    beacon?.stop();
    widget.client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: Text('${t(activeGame)} (${players.length})')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: dealt ? _buildGameplayView() : _buildLobbyWaitingView(title),
      ),
    );
  }

  Widget _buildLobbyWaitingView(TextStyle? title) {
    return ListView(children: [
      if (isHost) Card(
        color: Colors.deepPurple.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('${t('ipinfo')}${ips.join(', ')}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      const SizedBox(height: 12),
      Text('${t('players')} (${players.length})', style: title),
      for (final p in players)
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: p == widget.name ? const Chip(label: Text('SEN')) : null,
        ),
      const SizedBox(height: 16),
      if (isHost) ...[
        FilledButton.icon(
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          icon: const Icon(Icons.play_arrow),
          onPressed: (activeGame == 'buzzer' || activeGame == 'tod') || players.length >= 3 ? _startDeal : null,
          label: Text(t('start'), style: const TextStyle(fontSize: 16)),
        ),
        if (players.length < 3 && activeGame != 'buzzer' && activeGame != 'tod')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(t('need3'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.amber)),
          ),
      ] else
        Center(child: Text(t('waiting'), style: const TextStyle(fontStyle: FontStyle.italic))),
    ]);
  }

  Widget _buildGameplayView() {
    if (activeGame == 'buzzer') {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (buzzerWinner != null) ...[
            Text('🚨 $buzzerWinner 🚨', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber)),
            Text(t('buzzerHit'), style: const TextStyle(fontSize: 18, color: Colors.greenAccent)),
            const SizedBox(height: 20),
          ],
          GestureDetector(
            onTap: _pressBuzzer,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(colors: [Colors.redAccent, Colors.red]),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
              ),
              child: Center(
                child: Text(t('buzzerPress'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (isHost)
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: _resetBuzzer,
              label: Text(t('buzzerReset')),
            ),
          const SizedBox(height: 10),
          TextButton(onPressed: () => setState(() => dealt = false), child: Text(t('back'))),
        ]),
      );
    }

    return ListView(children: [
      HoldCard(
        isSpyOrImpostor: isSpyOrImpostor,
        word: secretWord,
        location: secretLocation,
        role: secretRole,
        isSpyMode: activeGame == 'spy',
      ),
      const SizedBox(height: 20),
      if (voteResultText != null) ...[
        Card(
          color: Colors.deepPurple.shade900,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text(t('voteResult'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(voteResultText!, style: const TextStyle(fontSize: 16, color: Colors.amberAccent)),
            ]),
          ),
        ),
      ] else ...[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('voteTitle'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final p in players)
                  ChoiceChip(
                    label: Text(p),
                    selected: votedSuspect == p,
                    onSelected: votedSuspect == null ? (_) => _castVote(p) : null,
                  ),
              ]),
              if (votedSuspect != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Oyun verildi: $votedSuspect', style: const TextStyle(color: Colors.greenAccent)),
                ),
            ]),
          ),
        ),
      ],
      const SizedBox(height: 20),
      OutlinedButton(onPressed: () => setState(() => dealt = false), child: Text(t('back'))),
    ]);
  }
}

class HoldCard extends StatefulWidget {
  final bool isSpyOrImpostor;
  final String? word;
  final String? location;
  final String? role;
  final bool isSpyMode;

  const HoldCard({
    super.key,
    required this.isSpyOrImpostor,
    this.word,
    this.location,
    this.role,
    this.isSpyMode = false,
  });

  @override
  State<HoldCard> createState() => _HoldCardState();
}

class _HoldCardState extends State<HoldCard> {
  bool show = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => show = true),
        onTapUp: (_) => setState(() => show = false),
        onTapCancel: () => setState(() => show = false),
        child: Card(
          elevation: show ? 8 : 2,
          color: show
              ? (widget.isSpyOrImpostor ? Colors.red.shade900 : Colors.deepPurple.shade900)
              : Theme.of(context).cardColor,
          child: SizedBox(
            width: double.infinity,
            height: 240,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: show ? _buildRevealedContent() : _buildHiddenContent(),
              ),
            ),
          ),
        ),
      );

  Widget _buildHiddenContent() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.touch_app, size: 48, color: Colors.purpleAccent),
        const SizedBox(height: 12),
        Text(t('hold'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ]);

  Widget _buildRevealedContent() {
    if (widget.isSpyOrImpostor) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.warning, size: 48, color: Colors.amber),
        const SizedBox(height: 8),
        Text(
          widget.isSpyMode ? t('spyWord') : t('impWord'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ]);
    }

    if (widget.isSpyMode) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${t('location')}: ${widget.location}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
        const SizedBox(height: 8),
        Text('${t('role')}: ${widget.role}', style: const TextStyle(fontSize: 18, color: Colors.white70)),
      ]);
    }

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('${t('word')}:', style: const TextStyle(fontSize: 16, color: Colors.purpleAccent)),
      const SizedBox(height: 6),
      Text(widget.word ?? '', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
    ]);
  }
}
