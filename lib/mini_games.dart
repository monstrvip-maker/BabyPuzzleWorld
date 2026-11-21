import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'character_assets.dart';

class GameAudio {
 static final AudioPlayer _p=AudioPlayer();
 static Future<void> tap() async {HapticFeedback.selectionClick();await _play('tap.wav');}
 static Future<void> correct() async {HapticFeedback.lightImpact();await _play('correct.wav');}
 static Future<void> win() async {HapticFeedback.mediumImpact();await _play('win.wav');}
 static Future<void> _play(String f) async {try{await _p.stop();await _p.play(AssetSource('audio/'+f));}catch(_){}}
}
class MiniGamesSection extends StatelessWidget {
  final VoidCallback? onReturn;
  const MiniGamesSection({super.key, this.onReturn});

  @override
  Widget build(BuildContext context) {
    final categories = <Map<String, dynamic>>[
      {
        'title': 'Память и внимание',
        'subtitle': 'Ищи, запоминай и сравнивай',
        'games': <List<dynamic>>[
          ['Найди пару','🧠','Тренируй память',Color(0xFFE9E2FF),MemoryGamePage()],
          ['Найди предмет','🔎','Ищи нужную картинку',Color(0xFFFFE8D7),FindGamePage()],
          ['Угадай тень','🌙','Узнай силуэт',Color(0xFFDFF2FF),ShadowGamePage()],
          ['Что лишнее?','🧩','Найди непохожее',Color(0xFFFFF2C9),OddGamePage()],
        ],
      },
      {
        'title': 'Учимся и считаем',
        'subtitle': 'Цвета, числа и наблюдательность',
        'games': <List<dynamic>>[
          ['Сосчитай','🔢','Сколько предметов?',Color(0xFFE2F5E7),CountGamePage()],
          ['Найди цвет','🎨','Выбери нужный цвет',Color(0xFFFFE6EE),ColorGamePage()],
        ],
      },
      {
        'title': 'Логика и узоры',
        'subtitle': 'Продолжай последовательности',
        'games': <List<dynamic>>[
          ['Повтори ряд','🔶','Продолжи узор',Color(0xFFE3EEFF),SequenceGamePage()],
        ],
      },
      {
        'title': 'Формы и творчество',
        'subtitle': 'Подбирай детали и раскрашивай',
        'games': <List<dynamic>>[
          ['Подбери форму','🧩','Вставь недостающую деталь',Color(0xFFE4F5EA),ShapeFitGamePage()],
          ['Раскраска','🖍️','Раскрась картинку пальцем',Color(0xFFFFE8EF),ColoringGamePage()],
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 12, 18, 4),
          child: Text('Дополнительные игры', style: TextStyle(
            fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF243B68))),
        ),
        ...categories.map((category) {
          final games = category['games'] as List<List<dynamic>>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 2),
                child: Text(category['title'] as String, style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF30456D))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 9),
                child: Text(category['subtitle'] as String, style: const TextStyle(
                  fontSize: 12, color: Color(0xFF71809A))),
              ),
              SizedBox(
                height: 146,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: games.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return SizedBox(
                      width: 190,
                      child: Material(
                        color: game[3] as Color,
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            GameAudio.tap();
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => game[4] as Widget,
                            )).then((_) => onReturn?.call());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(game[1] as String,
                                  style: const TextStyle(fontSize: 34)),
                                const Spacer(),
                                Text(game[0] as String, style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w900,
                                  color: Color(0xFF293B5E))),
                                Text(game[2] as String, style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF52627D))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 7, 18, 2),
          child: Row(
            children: [
              Icon(Icons.swipe, size: 18, color: Color(0xFF71809A)),
              SizedBox(width: 6),
              Text('Листай игры вправо и влево', style: TextStyle(
                fontSize: 12, color: Color(0xFF71809A))),
            ],
          ),
        ),
      ],
    );
  }
}

class GameProgress {
  static Future<void> awardStar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stars', (prefs.getInt('stars') ?? 0) + 1);
    await prefs.setInt('mini_games_completed',
        (prefs.getInt('mini_games_completed') ?? 0) + 1);
  }
}
List<MapEntry<String,String>> deck([int n=8]){final a=characterAssets.entries.toList()..shuffle();return a.take(min(n,a.length)).toList();}
class GameShell extends StatelessWidget{final String title;final Color color;final Widget child;const GameShell(this.title,this.color,this.child,{super.key});@override Widget build(BuildContext c)=>Scaffold(backgroundColor:color,appBar:AppBar(title:Text(title),backgroundColor:Colors.transparent),body:SafeArea(child:child));}
void won(BuildContext c,String text,VoidCallback next){GameAudio.win();GameProgress.awardStar();showDialog<void>(context:c,builder:(d)=>AlertDialog(title:const Text('Ура! 🎉 +1 звезда ⭐',textAlign:TextAlign.center),content:Text('$text\\nЗвёздочка добавлена на главный экран!',textAlign:TextAlign.center),actions:[FilledButton(onPressed:(){Navigator.pop(d);next();},child:const Text('Дальше'))]));}
Widget tile(String e,VoidCallback tap,{double size=48})=>Material(color:Colors.white,borderRadius:BorderRadius.circular(20),child:InkWell(borderRadius:BorderRadius.circular(20),onTap:tap,child:Center(child:Text(e,style:TextStyle(fontSize:size)))));

class MemoryGamePage extends StatefulWidget{const MemoryGamePage({super.key});@override State<MemoryGamePage> createState()=>_MemoryState();}
class _MemoryState extends State<MemoryGamePage> {
  late List<MapEntry<String, String>> cards;
  late List<int> ids;
  final Set<int> opened = <int>{};
  final Set<int> matched = <int>{};
  int moves = 0;
  bool lock = false;

  void reset() {
    cards = deck(6);
    ids = <int>[...List.generate(6, (i) => i), ...List.generate(6, (i) => i)]..shuffle();
    opened.clear();
    matched.clear();
    moves = 0;
    lock = false;
  }

  @override
  void initState() {
    super.initState();
    reset();
  }

  Future<void> flip(int i) async {
    if (lock || opened.contains(i) || matched.contains(i)) return;
    GameAudio.tap();
    setState(() => opened.add(i));
    if (opened.length != 2) return;

    moves++;
    final pair = opened.toList();
    if (ids[pair[0]] == ids[pair[1]]) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() {
        matched.addAll(pair);
        opened.clear();
      });
      GameAudio.correct();
      if (matched.length == ids.length) {
        won(context, 'Все пары найдены! Ходов: $moves', () => setState(reset));
      }
    } else {
      lock = true;
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        opened.clear();
        lock = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameShell(
      'Найди пару',
      const Color(0xFFF2ECFF),
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Открой одинаковые картинки • Ходы: $moves',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: ids.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final isFaceUp = opened.contains(i) || matched.contains(i);
                final String cardKey =
                    isFaceUp ? 'card-${ids[i]}' : 'back-$i';
                return GestureDetector(
                  onTap: () => flip(i),
                  child: AnimatedScale(
                    scale: matched.contains(i) ? 0.94 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      decoration: BoxDecoration(
                        color: isFaceUp
                            ? Colors.white
                            : const Color(0xFF8B79D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Text(
                            isFaceUp ? cards[ids[i]].value : '❔',
                            key: ValueKey<String>(cardKey),
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FindGamePage extends StatefulWidget{const FindGamePage({super.key});@override State<FindGamePage> createState()=>_FindState();}
class _FindState extends State<FindGamePage>{late List<MapEntry<String,String>> opts;late int target;int score=0;void next(){opts=deck(9);target=Random().nextInt(opts.length);}@override void initState(){super.initState();next();}void choose(int i){if(i==target){score++;won(context,'Правильно! Ты нашёл нужную картинку.',()=>setState(next));}else{GameAudio.tap();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Попробуй ещё раз 🙂')));}}@override Widget build(BuildContext c)=>GameShell('Найди предмет',const Color(0xFFFFF0E3),Column(children:[const SizedBox(height:16),Text('⭐ '+score.toString(),style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const Text('Найди такую же картинку',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),AnimatedSwitcher(duration:const Duration(milliseconds:250),child:Text(opts[target].value,key:ValueKey(opts[target].key),style:const TextStyle(fontSize:88))),Expanded(child:GridView.builder(padding:const EdgeInsets.all(18),itemCount:opts.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:12,mainAxisSpacing:12),itemBuilder:(c,i)=>tile(opts[i].value,()=>choose(i))))]));}

class ShadowGamePage extends StatefulWidget{const ShadowGamePage({super.key});@override State<ShadowGamePage> createState()=>_ShadowState();}
class _ShadowState extends State<ShadowGamePage>{late List<MapEntry<String,String>> opts;late int target;int score=0;void next(){opts=deck(3);target=Random().nextInt(3);}@override void initState(){super.initState();next();}void choose(int i){if(i==target){score++;won(context,'Ты узнал картинку!',()=>setState(next));}else{GameAudio.tap();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Попробуй ещё!')));}}@override Widget build(BuildContext c)=>GameShell('Угадай тень',const Color(0xFFE6F5FF),Column(children:[const SizedBox(height:20),Text('⭐ '+score.toString(),style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const Text('Кому принадлежит силуэт?',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),const SizedBox(height:25),AnimatedSwitcher(duration:const Duration(milliseconds:300),child:ColorFiltered(colorFilter:const ColorFilter.mode(Colors.black,BlendMode.srcIn),child:Text(opts[target].value,key:ValueKey(opts[target].key),style:const TextStyle(fontSize:100)))),Expanded(child:GridView.builder(padding:const EdgeInsets.all(18),itemCount:opts.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:12,mainAxisSpacing:12),itemBuilder:(c,i)=>tile(opts[i].value,()=>choose(i))))]));}

class CountGamePage extends StatefulWidget{const CountGamePage({super.key});@override State<CountGamePage> createState()=>_CountState();}
class _CountState extends State<CountGamePage>{late String emoji;late int count;late List<int> choices;int score=0;void next(){emoji=deck(6).first.value;count=Random().nextInt(5)+1;choices=({count,max(1,count-1),count+1,Random().nextInt(5)+1}).toList()..shuffle();}@override void initState(){super.initState();next();}void choose(int n){if(n==count){score++;won(context,'Верно! Здесь '+count.toString()+' предметов.',()=>setState(next));}else{GameAudio.tap();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Давай пересчитаем!')));}}@override Widget build(BuildContext c)=>GameShell('Сосчитай',const Color(0xFFE8F7E9),Column(children:[const SizedBox(height:20),Text('⭐ '+score.toString(),style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const Text('Сколько предметов?',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),Expanded(child:Center(child:Wrap(alignment:WrapAlignment.center,spacing:12,runSpacing:12,children:List.generate(count,(i)=>Text(emoji,style:const TextStyle(fontSize:58)))))),Wrap(spacing:12,children:choices.map((v)=>FilledButton(onPressed:()=>choose(v),child:Text(v.toString(),style:const TextStyle(fontSize:24)))).toList()),const SizedBox(height:40)]));}

class ColorGamePage extends StatefulWidget{const ColorGamePage({super.key});@override State<ColorGamePage> createState()=>_ColorState();}
class _ColorState extends State<ColorGamePage>{final colors=<Color>[Colors.red,Colors.blue,Colors.green,Colors.orange,Colors.purple];final names=<String>['красный','синий','зелёный','оранжевый','фиолетовый'];late int target;int score=0;void next(){target=Random().nextInt(colors.length);}@override void initState(){super.initState();next();}void choose(int i){if(i==target){score++;won(context,'Правильно! Это '+names[target]+' цвет.',()=>setState(next));}else{GameAudio.tap();}}@override Widget build(BuildContext c)=>GameShell('Найди цвет',const Color(0xFFFFEAF0),Column(children:[const SizedBox(height:24),Text('⭐ '+score.toString(),style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const Text('Найди такой же цвет',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:18),AnimatedContainer(duration:const Duration(milliseconds:350),width:150,height:150,decoration:BoxDecoration(color:colors[target],shape:BoxShape.circle)),const Spacer(),Wrap(spacing:16,runSpacing:16,children:List.generate(colors.length,(i)=>InkWell(onTap:()=>choose(i),child:Container(width:82,height:82,decoration:BoxDecoration(color:colors[i],borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white,width:4)))))),const SizedBox(height:60)]));}

class OddGamePage extends StatefulWidget{const OddGamePage({super.key});@override State<OddGamePage> createState()=>_OddState();}
class _OddState extends State<OddGamePage>{late List<MapEntry<String,String>> opts;late int odd;int score=0;void next(){final d=deck(6);final same=d.take(3).toList();final different=d[3];opts=[...same,different]..shuffle();odd=opts.indexWhere((e)=>e.key==different.key);}@override void initState(){super.initState();next();}void choose(int i){if(i==odd){score++;won(context,'Верно! Эта картинка отличается.',()=>setState(next));}else{GameAudio.tap();}}@override Widget build(BuildContext c)=>GameShell('Что лишнее?',const Color(0xFFFFF4D8),Column(children:[const SizedBox(height:20),Text('⭐ '+score.toString(),style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const Text('Найди непохожую картинку',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),Expanded(child:GridView.builder(padding:const EdgeInsets.all(18),itemCount:4,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:14,mainAxisSpacing:14),itemBuilder:(c,i)=>tile(opts[i].value,()=>choose(i),size:62)))]));}

class SequenceGamePage extends StatefulWidget{const SequenceGamePage({super.key});@override State<SequenceGamePage> createState()=>_SequenceState();}
class _SequenceState extends State<SequenceGamePage>{final patterns=<List<String>>[['🔴','🔵','🔴','🔵'],['⭐','🌙','⭐','🌙'],['🍎','🍌','🍎','🍌'],['🐱','🐶','🐱','🐶']];late List<String> row;late String answer;int score=0;void next(){final p=patterns[Random().nextInt(patterns.length)];row=p.take(3).toList();answer=p[3];}@override void initState(){super.initState();next();}void choose(String s){if(s==answer){score++;won(context,'Отлично! Ты продолжил узор.',()=>setState(next));}else{GameAudio.tap();}}@override Widget build(BuildContext c)=>GameShell('Повтори ряд',const Color(0xFFEAF0FF),Column(children:[const SizedBox(height:24),Text('⭐ '+score.toString(),style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const Text('Что должно быть дальше?',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),const SizedBox(height:50),Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[...row.map((e)=>Text(e,style:const TextStyle(fontSize:54))),const Text('❓',style:TextStyle(fontSize:54))]),const Spacer(),Wrap(spacing:24,children:[FilledButton(onPressed:()=>choose(answer),child:Text(answer,style:const TextStyle(fontSize:30))),FilledButton(onPressed:()=>choose('❌'),child:const Text('❌',style:TextStyle(fontSize:30)))]),const SizedBox(height:70)]));}

enum ShapeKind { circle, triangle, square, star, heart }

String shapeLabel(ShapeKind s) => switch(s) {
  ShapeKind.circle => 'Круг',
  ShapeKind.triangle => 'Треугольник',
  ShapeKind.square => 'Квадрат',
  ShapeKind.star => 'Звезда',
  ShapeKind.heart => 'Сердце',
};

Path shapePath(ShapeKind kind, Rect r) {
  final p = Path();
  switch (kind) {
    case ShapeKind.circle:
      p.addOval(r);
    case ShapeKind.square:
      p.addRRect(RRect.fromRectAndRadius(r, const Radius.circular(8)));
    case ShapeKind.triangle:
      p.moveTo(r.center.dx, r.top);
      p.lineTo(r.right, r.bottom);
      p.lineTo(r.left, r.bottom);
      p.close();
    case ShapeKind.star:
      for (var i = 0; i < 10; i++) {
        final radius = i.isEven ? r.width / 2 : r.width / 4;
        final a = -pi / 2 + i * pi / 5;
        final pt = Offset(r.center.dx + cos(a) * radius, r.center.dy + sin(a) * radius);
        if (i == 0) { p.moveTo(pt.dx, pt.dy); } else { p.lineTo(pt.dx, pt.dy); }
      }
      p.close();
    case ShapeKind.heart:
      p.moveTo(r.center.dx, r.bottom);
      p.cubicTo(r.left - r.width * .12, r.center.dy, r.left + r.width * .15, r.top - r.height * .1, r.center.dx, r.top + r.height * .28);
      p.cubicTo(r.right - r.width * .15, r.top - r.height * .1, r.right + r.width * .12, r.center.dy, r.center.dx, r.bottom);
      p.close();
  }
  return p;
}

class ShapeFitGamePage extends StatefulWidget {
  const ShapeFitGamePage({super.key});
  @override State<ShapeFitGamePage> createState() => _ShapeFitGamePageState();
}
class _ShapeFitGamePageState extends State<ShapeFitGamePage> {
  final _random = Random();
  late ShapeKind target;
  late List<ShapeKind> options;
  ShapeKind? selected;
  int score = 0;
  int round = 0;
  void _next() {
    target = ShapeKind.values[_random.nextInt(ShapeKind.values.length)];
    final others = ShapeKind.values.where((s) => s != target).toList()..shuffle(_random);
    options = <ShapeKind>[target, ...others.take(3)]..shuffle(_random);
    selected = null;
    round++;
  }
  @override void initState() { super.initState(); _next(); }
  void _place(ShapeKind shape) {
    if (shape != target) {
      GameAudio.tap();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Эта деталь не подходит. Попробуй другую!')));
      return;
    }
    score++;
    GameAudio.correct();
    won(context, 'Ты подобрал форму: ${shapeLabel(target)}!', () => setState(_next));
  }
  Widget _shapeChoice(ShapeKind shape) {
    final isSelected = selected == shape;
    return Draggable<ShapeKind>(
      data: shape,
      onDragStarted: () => setState(() => selected = shape),
      feedback: Material(color: Colors.transparent, child: SizedBox(width: 76, height: 76, child: CustomPaint(painter: _ShapePainter(shape, const Color(0xFFFFB52E))))),
      childWhenDragging: Opacity(opacity: .3, child: _choiceCard(shape, isSelected)),
      child: GestureDetector(onTap: () => setState(() => selected = shape), child: _choiceCard(shape, isSelected)),
    );
  }
  Widget _choiceCard(ShapeKind shape, bool isSelected) => Container(
    width: 66, height: 72,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? const Color(0xFF5476B8) : Colors.white, width: 3)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(child: Padding(padding: const EdgeInsets.all(8), child: CustomPaint(painter: _ShapePainter(shape, const Color(0xFFFFB52E)), child: const SizedBox.expand()))),
      Text(shapeLabel(shape), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
    ]),
  );
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFEAF7E8),
    appBar: AppBar(title: const Text('Подбери форму'), backgroundColor: Colors.transparent),
    body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 10), child: Text('Раунд $round  •  ⭐ $score\nВыбери деталь для персонажа и перетащи её на пустое место', textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
      Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: options.map(_shapeChoice).toList()),
      Expanded(child: Center(child: DragTarget<ShapeKind>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (d) => _place(d.data),
        builder: (context, candidates, rejected) => GestureDetector(
          onTap: selected == null ? null : () => _place(selected!),
          child: SizedBox(width: 300, height: 330, child: CustomPaint(
            painter: _BearPainter(target, candidates.isNotEmpty),
            child: const SizedBox.expand(),
          )),
        ),
      ))),
      const Padding(padding: EdgeInsets.only(bottom: 16), child: Text('Можно перетащить деталь или сначала выбрать её, а затем нажать на пустое место', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF60745F)))),
    ])),
  );
}

class _ShapePainter extends CustomPainter {
  final ShapeKind shape; final Color color;
  _ShapePainter(this.shape, this.color);
  @override void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width*.12, size.height*.12, size.width*.76, size.height*.76);
    canvas.drawPath(shapePath(shape, rect), Paint()..color=color..style=PaintingStyle.fill);
    canvas.drawPath(shapePath(shape, rect), Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
  }
  @override bool shouldRepaint(covariant _ShapePainter old) => old.shape != shape || old.color != color;
}

class _BearPainter extends CustomPainter {
  final ShapeKind hole; final bool highlighted;
  _BearPainter(this.hole, this.highlighted);
  @override void paint(Canvas canvas, Size size) {
    final scale = size.width / 300;
    canvas.save(); canvas.scale(scale);
    final fur = Paint()..color=const Color(0xFFB97B50);
    final dark = Paint()..color=const Color(0xFF563B32);
    final cream = Paint()..color=const Color(0xFFFFE2B8);
    canvas.drawOval(const Rect.fromLTWH(37, 27, 78, 78), fur);
    canvas.drawOval(const Rect.fromLTWH(185, 27, 78, 78), fur);
    canvas.drawOval(const Rect.fromLTWH(50, 42, 52, 52), cream);
    canvas.drawOval(const Rect.fromLTWH(198, 42, 52, 52), cream);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(48, 88, 204, 210), const Radius.circular(92)), fur);
    canvas.drawOval(const Rect.fromLTWH(72, 110, 156, 150), cream);
    canvas.drawCircle(const Offset(111, 119), 8, dark);
    canvas.drawCircle(const Offset(189, 119), 8, dark);
    canvas.drawOval(const Rect.fromLTWH(132, 139, 36, 25), dark);
    canvas.drawArc(const Rect.fromLTWH(115, 145, 70, 50), .2, pi-.4, false, Paint()..color=dark.color..style=PaintingStyle.stroke..strokeWidth=5..strokeCap=StrokeCap.round);
    final holeRect = Rect.fromCenter(center: const Offset(150, 218), width: 76, height: 76);
    final path = shapePath(hole, holeRect);
    canvas.drawPath(path, Paint()..color=highlighted ? const Color(0xFFDAF4D8) : const Color(0xFFEAF7E8));
    canvas.drawPath(path, Paint()..color=const Color(0xFF679A68)..style=PaintingStyle.stroke..strokeWidth=4..strokeCap=StrokeCap.round);
    for (final leg in [70.0, 180.0]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(leg, 265, 48, 32), const Radius.circular(14)), fur);
    }
    canvas.restore();
  }
  @override bool shouldRepaint(covariant _BearPainter old) => old.hole != hole || old.highlighted != highlighted;
}

class ColoringGamePage extends StatefulWidget {
  const ColoringGamePage({super.key});
  @override State<ColoringGamePage> createState() => _ColoringGamePageState();
}
class _ColoringGamePageState extends State<ColoringGamePage> {
  final colors = <Color>[Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.pink, Colors.brown];
  final names = <String>['Красный','Оранжевый','Жёлтый','Зелёный','Синий','Фиолетовый','Розовый','Коричневый'];
  final fills = <int, Color>{};
  int selectedColor = 0;
  int selectedPart = 0;
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF0F4),
    appBar: AppBar(title: const Text('Раскраска'), backgroundColor: Colors.transparent, actions: [
      IconButton(onPressed: () => setState(() { fills.clear(); selectedPart=0; }), icon: const Icon(Icons.refresh)),
    ]),
    body: SafeArea(child: Column(children: [
      const Padding(padding: EdgeInsets.all(14), child: Text('Выбери цвет и нажимай на части бабочки', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      Expanded(child: Center(child: GestureDetector(
        onTapDown: (d) {
          final normalizedX = d.localPosition.dx / 320;
          final normalizedY = d.localPosition.dy / 330;
          setState(() => selectedPart = normalizedY < .42 ? (normalizedX < .5 ? 0 : 1) : (normalizedX < .5 ? 2 : 3));
          GameAudio.tap();
        },
        child: CustomPaint(
          size: const Size(320, 330),
          painter: _ButterflyPainter(fills),
        ),
      ))),
      Text('Цвет: ${names[selectedColor]}', style: const TextStyle(fontWeight: FontWeight.bold)),
      Padding(padding: const EdgeInsets.all(14), child: Wrap(
        alignment: WrapAlignment.center, spacing: 12, runSpacing: 12,
        children: List.generate(colors.length, (i) => GestureDetector(
          onTap: () => setState(() { selectedColor=i; fills[selectedPart]=colors[i]; }),
          child: Container(width: 42, height: 42, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle, border: Border.all(color: selectedColor==i ? Colors.black : Colors.white, width: 3))),
        )),
      )),
      const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('Нажми на крылышко, чтобы раскрасить его', style: TextStyle(fontSize: 12, color: Colors.black54))),
    ])),
  );
}

class _ButterflyPainter extends CustomPainter {
  final Map<int, Color> fills;
  _ButterflyPainter(this.fills);
  @override void paint(Canvas canvas, Size size) {
    final sx=size.width/320, sy=size.height/330;
    canvas.save(); canvas.scale(sx,sy);
    final outline=Paint()..color=const Color(0xFF493C43)..style=PaintingStyle.stroke..strokeWidth=5;
    final body=Paint()..color=(fills[4] ?? Colors.white)..style=PaintingStyle.fill;
    final leftTop=Rect.fromLTWH(25,55,125,105), rightTop=Rect.fromLTWH(170,55,125,105);
    final leftBottom=Rect.fromLTWH(38,165,110,115), rightBottom=Rect.fromLTWH(172,165,110,115);
    final wingRects=[leftTop,rightTop,leftBottom,rightBottom];
    for(var i=0;i<wingRects.length;i++){
      final fill=Paint()..color=fills[i] ?? Colors.white;
      canvas.drawOval(wingRects[i],fill); canvas.drawOval(wingRects[i],outline);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(148,90,24,190),const Radius.circular(12)),body);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(148,90,24,190),const Radius.circular(12)),outline);
    final antenna=Paint()..color=outline.color..style=PaintingStyle.stroke..strokeWidth=5..strokeCap=StrokeCap.round;
    canvas.drawLine(const Offset(158,95),const Offset(130,38),antenna);
    canvas.drawLine(const Offset(162,95),const Offset(190,38),antenna);
    canvas.drawCircle(const Offset(130,38),8,Paint()..color=outline.color);
    canvas.drawCircle(const Offset(190,38),8,Paint()..color=outline.color);
    canvas.restore();
  }
  @override bool shouldRepaint(covariant _ButterflyPainter old) => old.fills != fills;
}
