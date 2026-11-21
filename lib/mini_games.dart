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
        'title': 'Фигуры и приключения',
        'subtitle': 'Помоги забавным героям',
        'games': <List<dynamic>>[
          ['Подбери форму','🧩','Помоги героям собрать детали',Color(0xFFE4F5EA),ShapeFitGamePage()],
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
String shapeLabel(ShapeKind s) => switch (s) {
  ShapeKind.circle => 'Круг',
  ShapeKind.triangle => 'Треугольник',
  ShapeKind.square => 'Квадрат',
  ShapeKind.star => 'Звезда',
  ShapeKind.heart => 'Сердце',
};
Path shapePath(ShapeKind kind, Rect r) {
  final p=Path();
  switch(kind){
    case ShapeKind.circle: p.addOval(r);
    case ShapeKind.square: p.addRRect(RRect.fromRectAndRadius(r,Radius.circular(r.width*.12)));
    case ShapeKind.triangle: p.moveTo(r.center.dx,r.top);p.lineTo(r.right,r.bottom);p.lineTo(r.left,r.bottom);p.close();
    case ShapeKind.star:
      for(var i=0;i<10;i++){final radius=i.isEven?r.width/2:r.width/4;final a=-pi/2+i*pi/5;final pt=Offset(r.center.dx+cos(a)*radius,r.center.dy+sin(a)*radius);if(i==0){p.moveTo(pt.dx,pt.dy);}else{p.lineTo(pt.dx,pt.dy);}}p.close();
    case ShapeKind.heart:
      p.moveTo(r.center.dx,r.bottom);p.cubicTo(r.left-r.width*.12,r.center.dy,r.left+r.width*.15,r.top-r.height*.1,r.center.dx,r.top+r.height*.28);p.cubicTo(r.right-r.width*.15,r.top-r.height*.1,r.right+r.width*.12,r.center.dy,r.center.dx,r.bottom);p.close();
  }
  return p;
}
class ShapeFitGamePage extends StatefulWidget {
  const ShapeFitGamePage({super.key});
  @override State<ShapeFitGamePage> createState()=>_ShapeFitGamePageState();
}
class _ShapeFitGamePageState extends State<ShapeFitGamePage> {
  final random=Random();
  late ShapeKind target;
  late List<ShapeKind> options;
  late int hero,holeIndex;
  late Color heroColor;
  ShapeKind? selected;
  bool placed=false;
  int score=0,round=0;
  static const heroNames=['Мишка Бублик','Зайка Пуговка','Котик Персик','Дино Рекс','Монстрик Плюш'];
  static const heroColors=[Color(0xFFB97B50),Color(0xFFEC9BB8),Color(0xFFFFB74D),Color(0xFF55B978),Color(0xFF9C82D8)];
  static const holeSpots=[Offset(150,222),Offset(105,210),Offset(195,210),Offset(150,175),Offset(150,260)];
  void nextRound(){
    target=ShapeKind.values[random.nextInt(ShapeKind.values.length)];
    final others=ShapeKind.values.where((x)=>x!=target).toList()..shuffle(random);
    options=<ShapeKind>[target,...others.take(3)]..shuffle(random);
    hero=round % heroNames.length;holeIndex=random.nextInt(holeSpots.length);
    heroColor=heroColors[hero];selected=null;placed=false;round++;
  }
  @override void initState(){super.initState();nextRound();}
  Future<void> putShape(ShapeKind shape) async {
    if(placed)return;
    if(shape!=target){GameAudio.tap();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Почти! Попробуй другую фигурку 😊')));return;}
    setState(()=>placed=true);score++;GameAudio.correct();
    await Future.delayed(const Duration(milliseconds:650));
    if(!mounted)return;
    won(context,'${heroNames[hero]} рад! Ты подобрал ${shapeLabel(target).toLowerCase()}! ⭐',()=>setState(nextRound));
  }
  Widget choice(ShapeKind shape){
    final active=selected==shape;
    return Draggable<ShapeKind>(
      data:shape,onDragStarted:()=>setState(()=>selected=shape),
      feedback:Material(color:Colors.transparent,child:SizedBox(width:82,height:82,child:CustomPaint(painter:_ShapePainter(shape,const Color(0xFFFFB52E))))),
      childWhenDragging:Opacity(opacity:.25,child:choiceCard(shape,active)),
      child:GestureDetector(onTap:()=>setState(()=>selected=shape),child:choiceCard(shape,active)),
    );
  }
  Widget choiceCard(ShapeKind shape,bool active)=>AnimatedContainer(
    duration:const Duration(milliseconds:180),width:76,height:86,
    decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20),border:Border.all(color:active?const Color(0xFF5476B8):Colors.white,width:3),boxShadow:[BoxShadow(color:heroColor.withOpacity(.12),blurRadius:10,offset:const Offset(0,4))]),
    child:Column(children:[
      Expanded(child:Padding(padding:const EdgeInsets.all(9),child:CustomPaint(painter:_ShapePainter(shape,const Color(0xFFFFB52E)),child:const SizedBox.expand()))),
      Padding(padding:const EdgeInsets.only(bottom:5),child:Text(shapeLabel(shape),style:const TextStyle(fontSize:10,fontWeight:FontWeight.bold))),
    ]),
  );
  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:const Color(0xFFFFF5DE),appBar:AppBar(title:const Text('Помоги герою!'),backgroundColor:Colors.transparent),
    body:SafeArea(child:Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(14,4,14,10),child:Column(children:[
        Text('Раунд $round   ⭐ $score',style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900,color:Color(0xFF57436F))),
        const SizedBox(height:5),
        Text('У ${heroNames[hero]} пропала деталь! Найди подходящую форму.',textAlign:TextAlign.center,style:const TextStyle(fontSize:17,fontWeight:FontWeight.bold)),
      ])),
      Wrap(alignment:WrapAlignment.center,spacing:9,children:options.map(choice).toList()),
      Expanded(child:Center(child:DragTarget<ShapeKind>(
        onWillAcceptWithDetails:(_)=>!placed,onAcceptWithDetails:(d)=>putShape(d.data),
        builder:(context,candidates,rejected)=>GestureDetector(
          onTap:selected==null||placed?null:()=>putShape(selected!),
          child:AnimatedScale(scale:candidates.isNotEmpty?1.035:1,duration:const Duration(milliseconds:180),
            child:SizedBox(width:320,height:370,child:CustomPaint(
              painter:_HeroPainter(hero,heroColor,target,holeSpots[holeIndex],placed,candidates.isNotEmpty),child:const SizedBox.expand()))),
        ),
      ))),
      const Padding(padding:EdgeInsets.fromLTRB(16,0,16,14),child:Text('Перетащи фигурку на пустое место или выбери её и коснись героя 👆',textAlign:TextAlign.center,style:TextStyle(color:Color(0xFF766A61),fontSize:12))),
    ])),
  );
}
class _ShapePainter extends CustomPainter {
  final ShapeKind shape;final Color color;
  _ShapePainter(this.shape,this.color);
  @override void paint(Canvas canvas,Size size){final r=Rect.fromLTWH(size.width*.12,size.height*.12,size.width*.76,size.height*.76);canvas.drawShadow(shapePath(shape,r),Colors.black.withOpacity(.15),3,true);canvas.drawPath(shapePath(shape,r),Paint()..color=color);canvas.drawPath(shapePath(shape,r),Paint()..color=Colors.white.withOpacity(.85)..style=PaintingStyle.stroke..strokeWidth=2.5);}
  @override bool shouldRepaint(covariant _ShapePainter old)=>old.shape!=shape||old.color!=color;
}
class _HeroPainter extends CustomPainter {
  final int hero;final Color color;final ShapeKind hole;final Offset holeCenter;final bool placed,highlighted;
  _HeroPainter(this.hero,this.color,this.hole,this.holeCenter,this.placed,this.highlighted);
  @override void paint(Canvas canvas,Size size){
    canvas.save();canvas.scale(size.width/320,size.height/370);
    final fur=Paint()..color=color;final cream=Paint()..color=const Color(0xFFFFE6BD);final dark=Paint()..color=const Color(0xFF49332F);
    canvas.drawOval(const Rect.fromLTWH(54,328,212,20),Paint()..color=color.withOpacity(.12));
    if(hero==1){
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(76,8,55,132),const Radius.circular(28)),fur);canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(189,8,55,132),const Radius.circular(28)),fur);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(88,20,30,100),const Radius.circular(18)),Paint()..color=const Color(0xFFFFD0DC));canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(202,20,30,100),const Radius.circular(18)),Paint()..color=const Color(0xFFFFD0DC));
    }else if(hero==2||hero==3){
      canvas.drawPath(Path()..moveTo(78,100)..lineTo(hero==3?64:82,18)..lineTo(143,72)..close(),fur);canvas.drawPath(Path()..moveTo(242,100)..lineTo(hero==3?256:238,18)..lineTo(177,72)..close(),fur);
      if(hero==3)canvas.drawCircle(const Offset(150,45),13,Paint()..color=const Color(0xFFFFD34F));
    }else{
      canvas.drawCircle(const Offset(105,76),42,fur);canvas.drawCircle(const Offset(215,76),42,fur);canvas.drawCircle(const Offset(105,76),25,cream);canvas.drawCircle(const Offset(215,76),25,cream);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(47,84,226,244),const Radius.circular(104)),fur);
    canvas.drawOval(const Rect.fromLTWH(78,116,164,174),cream);
    canvas.drawCircle(const Offset(120,158),8,dark);canvas.drawCircle(const Offset(200,158),8,dark);canvas.drawOval(const Rect.fromLTWH(137,179,46,30),dark);
    canvas.drawArc(const Rect.fromLTWH(121,184,78,56),.15,pi-.3,false,Paint()..color=dark.color..style=PaintingStyle.stroke..strokeWidth=5..strokeCap=StrokeCap.round);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(12,210,66,32),const Radius.circular(16)),fur);canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(242,210,66,32),const Radius.circular(16)),fur);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(76,310,70,35),const Radius.circular(16)),fur);canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(174,310,70,35),const Radius.circular(16)),fur);
    final holeRect=Rect.fromCenter(center:holeCenter,width:82,height:82);final path=shapePath(hole,holeRect);
    if(placed){canvas.drawShadow(path,const Color(0xFF5A9D65),7,true);canvas.drawPath(path,Paint()..color=const Color(0xFFFFB52E));canvas.drawPath(path,Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=4);for(final p in [const Offset(46,80),const Offset(270,90),const Offset(270,270)])canvas.drawCircle(p,5,Paint()..color=const Color(0xFFFFC83D));}
    else{canvas.drawPath(path,Paint()..color=highlighted?const Color(0xFFD9F5D7):const Color(0xFFFFF5DE));canvas.drawPath(path,Paint()..color=const Color(0xFF72A77B)..style=PaintingStyle.stroke..strokeWidth=5);}
    canvas.restore();
  }
  @override bool shouldRepaint(covariant _HeroPainter old)=>old.hero!=hero||old.color!=color||old.hole!=hole||old.holeCenter!=holeCenter||old.placed!=placed||old.highlighted!=highlighted;
}
