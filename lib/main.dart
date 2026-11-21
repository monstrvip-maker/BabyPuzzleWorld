import 'dart:math';
import 'character_assets.dart';
import 'mini_games.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {\n  WidgetsFlutterBinding.ensureInitialized();\n  BackgroundMusic.initialize();\n  runApp(const BabyPuzzleApp());\n}

class BabyPuzzleApp extends StatelessWidget {
  const BabyPuzzleApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'Baby Puzzle World',
    theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto', colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3478E8))),
    home: const HomePage(),
  );
}

class CharacterImage extends StatefulWidget {
  final String name;
  final double? width, height;
  final BoxFit fit;
  const CharacterImage(this.name, {super.key, this.width, this.height, this.fit=BoxFit.contain});
  @override State<CharacterImage> createState() => _CharacterImageState();
}

class _CharacterImageState extends State<CharacterImage> with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(vsync:this,duration:const Duration(milliseconds:1900))..repeat(reverse:true);
  @override void dispose(){_motion.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    return SizedBox(width:widget.width,height:widget.height,child:AnimatedBuilder(
      animation:_motion,
      builder:(context,child)=>Transform.translate(offset:Offset(0,-4*_motion.value),child:Transform.rotate(angle:(_motion.value-.5)*.035,child:child)),
      child:CustomPaint(painter:_CharacterPainter(widget.name),child:const SizedBox.expand()),
    ));
  }
}

class _CharacterPainter extends CustomPainter {
  final String name;
  _CharacterPainter(this.name);
  static const palette=<String,Color>{
    'dino':Color(0xFF42AD58),'triceratops':Color(0xFFE65D49),'whale':Color(0xFF39A9E8),'octopus':Color(0xFFAD72D5),
    'submarine':Color(0xFFFFB52E),'turtle':Color(0xFF48A96A),'firetruck':Color(0xFFE64A3B),'bus':Color(0xFFFFC247),
    'puppy':Color(0xFFB87950),'kitten':Color(0xFFFFB33D),'elephant':Color(0xFF8DA6BD),'lion':Color(0xFFE5A62D),
    'apple':Color(0xFFE84B45),'banana':Color(0xFFF4D044),'butterfly':Color(0xFFB16BD2),'rocket':Color(0xFF438FD0),
  };
  @override void paint(Canvas canvas,Size size){
    final scale=min(size.width,size.height)/200;
    canvas.save();canvas.translate((size.width-200*scale)/2,(size.height-200*scale)/2);canvas.scale(scale);
    final c=palette[name]??const Color(0xFF5476A8);
    final ink=Paint()..color=const Color(0xFF493A45);
    final fill=Paint()..color=c;
    final pale=Paint()..color=Color.lerp(c,Colors.white,.58)!;
    void oval(double x,double y,double w,double h,Paint p)=>canvas.drawOval(Rect.fromLTWH(x,y,w,h),p);
    void circle(double x,double y,double r,Paint p)=>canvas.drawCircle(Offset(x,y),r,p);
    void path(List<Offset> pts,Paint p,{bool close=true}){final q=Path()..moveTo(pts.first.dx,pts.first.dy);for(final v in pts.skip(1)){q.lineTo(v.dx,v.dy);}if(close)q.close();canvas.drawPath(q,p);}
    // soft halo behind every original hand-drawn character
    circle(100,102,88,Paint()..shader=RadialGradient(colors:[c.withOpacity(.23),c.withOpacity(.015)]).createShader(const Rect.fromCircle(center:Offset(100,102),radius:88)));
    switch(name){
      case 'dino':
        oval(38,76,126,94,fill);oval(118,35,58,57,fill);path([const Offset(47,83),const Offset(24,52),const Offset(57,61)],fill);path([const Offset(75,78),const Offset(67,43),const Offset(99,62)],fill);
        for(var i=0;i<4;i++){path([Offset(60+i*22,78),Offset(70+i*22,55),Offset(80+i*22,78)],pale);}
        oval(61,151,27,24,fill);oval(120,151,27,24,fill);oval(145,52,7,8,ink);oval(159,52,7,8,Paint()..color=Colors.white);
        oval(152,76,25,9,Paint()..color=const Color(0xFFEF8C82));break;
      case 'triceratops':
        oval(35,80,130,88,fill);oval(105,47,72,65,fill);
        path([const Offset(118,51),const Offset(110,20),const Offset(135,43)],pale);path([const Offset(148,51),const Offset(169,20),const Offset(163,57)],pale);
        for(var i=0;i<3;i++)circle(111+i*20,106,5,pale);circle(151,72,6,ink);oval(166,90,22,12,pale);break;
      case 'whale':
        oval(24,68,150,94,fill);path([const Offset(42,111),const Offset(12,91),const Offset(18,131)],fill);path([const Offset(42,111),const Offset(12,143),const Offset(55,130)],fill);
        oval(65,139,40,18,pale);circle(144,94,6,ink);canvas.drawArc(const Rect.fromLTWH(132,101,22,18),0,pi/2,false,Paint()..color=ink.color..style=PaintingStyle.stroke..strokeWidth=3);for(var i=0;i<3;i++)oval(155+i*8,40+i*7,25,12,Paint()..color=const Color(0xFF8BD6F5));break;
      case 'octopus':
        for(var i=0;i<6;i++){final x=35.0+i*24;canvas.drawPath(Path()..moveTo(100,125)..quadraticBezierTo(x,145,x+(i.isEven?8:-8),177),Paint()..color=c..style=PaintingStyle.stroke..strokeWidth=17..strokeCap=StrokeCap.round);}
        circle(100,91,58,fill);circle(79,86,6,ink);circle(120,86,6,ink);canvas.drawArc(const Rect.fromLTWH(84,96,32,21),0,pi,false,Paint()..color=ink.color..style=PaintingStyle.stroke..strokeWidth=3);break;
      case 'submarine':
        oval(25,70,150,76,fill);path([const Offset(87,72),const Offset(96,43),const Offset(130,43),const Offset(141,72)],fill);for(var i=0;i<3;i++){circle(62+i*34,106,11,pale);}path([const Offset(72,146),const Offset(72,166),const Offset(126,166),const Offset(126,146)],fill);break;
      case 'turtle':
        oval(35,62,132,104,fill);oval(72,83,62,63,pale);for(var i=0;i<4;i++){oval(i%2==0?26:145,i<2?76:128,34,30,fill);}circle(165,96,28,fill);circle(174,88,5,ink);path([const Offset(41,112),const Offset(17,124),const Offset(42,131)],fill);break;
      case 'firetruck':
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(24,67,150,91),const Radius.circular(17)),fill);canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(125,42,48,56),const Radius.circular(10)),fill);oval(43,142,35,35,ink);oval(129,142,35,35,ink);oval(51,150,18,18,pale);oval(137,150,18,18,pale);for(var i=0;i<3;i++){canvas.drawRect(Rect.fromLTWH(45+i*27,84,19,22),pale);}break;
      case 'bus':
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(22,45,156,112),const Radius.circular(23)),fill);for(var i=0;i<4;i++){canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(34+i*35,61,28,34),const Radius.circular(6)),pale);}oval(42,139,34,34,ink);oval(129,139,34,34,ink);break;
      case 'puppy':
        oval(23,50,56,85,Paint()..color=const Color(0xFF8D5948));oval(121,50,56,85,Paint()..color=const Color(0xFF8D5948));circle(100,103,68,fill);oval(62,98,76,62,pale);circle(80,94,6,ink);circle(121,94,6,ink);oval(91,111,18,13,ink);canvas.drawArc(const Rect.fromLTWH(83,117,34,23),0,pi,false,Paint()..color=ink.color..style=PaintingStyle.stroke..strokeWidth=4);break;
      case 'kitten':
        path([const Offset(35,82),const Offset(43,22),const Offset(86,57),const Offset(113,57),const Offset(157,22),const Offset(166,82)],fill);circle(100,105,66,fill);circle(76,99,7,ink);circle(124,99,7,ink);path([const Offset(91,119),const Offset(100,127),const Offset(109,119)],ink);for(var i=0;i<3;i++){canvas.drawLine(Offset(57,117+i*9),Offset(20,108+i*13),Paint()..color=ink.color..strokeWidth=3);}break;
      case 'elephant':
        oval(35,42,130,118,fill);oval(129,92,42,78,fill);oval(138,104,25,58,pale);circle(68,91,27,pale);circle(132,91,27,pale);circle(91,87,6,ink);circle(128,87,6,ink);break;
      case 'lion':
        for(var i=0;i<12;i++){final a=i*pi/6;circle(100+62*cos(a),103+62*sin(a),27,Paint()..color=const Color(0xFF98603D));}circle(100,103,57,fill);oval(65,94,70,58,pale);circle(83,88,6,ink);circle(117,88,6,ink);path([const Offset(91,109),const Offset(100,117),const Offset(109,109)],ink);break;
      case 'apple':
        circle(76,108,48,fill);circle(126,108,48,fill);path([const Offset(100,65),const Offset(95,39),const Offset(110,32),const Offset(111,67)],Paint()..color=const Color(0xFF765039));oval(107,31,48,22,Paint()..color=const Color(0xFF54B85B));break;
      case 'banana':
        final p=Path()..moveTo(31,72)..quadraticBezierTo(78,158,159,111)..quadraticBezierTo(125,181,65,137)..quadraticBezierTo(34,112,31,72)..close();canvas.drawPath(p,fill);canvas.drawPath(p,Paint()..color=const Color(0xFFFFE98A)..style=PaintingStyle.stroke..strokeWidth=8);break;
      case 'butterfly':
        oval(22,55,70,70,Paint()..color=const Color(0xFFEF8AB7));oval(108,55,70,70,Paint()..color=const Color(0xFF73BCEB));oval(31,119,59,47,Paint()..color=const Color(0xFFFFC75C));oval(110,119,59,47,Paint()..color=const Color(0xFFB18AE5));canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(93,63,14,104),const Radius.circular(8)),ink);canvas.drawLine(const Offset(98,66),const Offset(78,36),ink..strokeWidth=4);canvas.drawLine(const Offset(102,66),const Offset(122,36),ink..strokeWidth=4);break;
      case 'rocket':
        canvas.save();canvas.translate(100,102);canvas.rotate(-.65);canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-31,-75,62,132),const Radius.circular(30)),fill);path([const Offset(-31,34),const Offset(-62,75),const Offset(-23,60)],Paint()..color=const Color(0xFFE85D4A));path([const Offset(31,34),const Offset(62,75),const Offset(23,60)],Paint()..color=const Color(0xFFE85D4A));circle(0,-24,17,pale);path([const Offset(-19,56),const Offset(0,99),const Offset(19,56)],Paint()..color=const Color(0xFFFFB33D));canvas.restore();break;
    }
    // tiny friendly cheeks and shine
    if(!['rocket','banana','apple','firetruck','bus','submarine'].contains(name)){circle(73,119,5,Paint()..color=const Color(0xFFFFA4A4).withOpacity(.7));circle(128,119,5,Paint()..color=const Color(0xFFFFA4A4).withOpacity(.7));}
    canvas.restore();
  }
  @override bool shouldRepaint(covariant _CharacterPainter old)=>old.name!=name;
}

class PuzzlePieceGraphic extends StatelessWidget {
  final String asset;
  final int piece;
  final double size;
  const PuzzlePieceGraphic({super.key, required this.asset, required this.piece, required this.size});

  @override
  Widget build(BuildContext context) {
    final x = piece % 2;
    final y = piece ~/ 2;
    return SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: x == 0 ? 0 : -size,
              top: y == 0 ? 0 : -size,
              width: size * 2,
              height: size * 2,
              child: CharacterImage(asset, width: size * 2, height: size * 2),
            ),
          ],
        ),
      ),
    );
  }
}

class PuzzleItem {
  final String name, asset, category;
  final Color color;
  const PuzzleItem(this.name,this.asset,this.category,this.color);
}
const items = <PuzzleItem>[
  PuzzleItem('Динозавр','dino','Динозавры',Color(0xFFE4F5D9)),
  PuzzleItem('Трицератопс','triceratops','Динозавры',Color(0xFFFFE8D8)),
  PuzzleItem('Китёнок','whale','Океан',Color(0xFFDDF2FF)),
  PuzzleItem('Осьминог','octopus','Океан',Color(0xFFFFE0F0)),
  PuzzleItem('Подлодка','submarine','Океан',Color(0xFFFFF2C9)),
  PuzzleItem('Черепашка','turtle','Океан',Color(0xFFE3F4D8)),
  PuzzleItem('Пожарная машина','firetruck','Транспорт',Color(0xFFFFE0DC)),
  PuzzleItem('Автобус','bus','Транспорт',Color(0xFFFFF3C7)),
  PuzzleItem('Щенок','puppy','Животные',Color(0xFFFFE7D5)),
  PuzzleItem('Котёнок','kitten','Животные',Color(0xFFFFE6D7)),
  PuzzleItem('Слонёнок','elephant','Животные',Color(0xFFE2ECFF)),
  PuzzleItem('Львёнок','lion','Животные',Color(0xFFFFE9B8)),
  PuzzleItem('Яблоко','apple','Еда',Color(0xFFFFE0E0)),
  PuzzleItem('Банан','banana','Еда',Color(0xFFFFF5C9)),
  PuzzleItem('Бабочка','butterfly','Природа',Color(0xFFF2E2FF)),
  PuzzleItem('Ракета','rocket','Космос',Color(0xFFE0EEFF)),
];

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage> {
  int stars=0; Set<String> done={};
  @override void initState(){super.initState(); _load();}
  Future<void> _load() async {final p=await SharedPreferences.getInstance(); if(!mounted)return; setState((){stars=p.getInt('stars')??0;done=(p.getStringList('done')??[]).toSet();});}
  Future<void> reward(String key) async {final p=await SharedPreferences.getInstance(); if(done.add(key)){stars++;await p.setInt('stars',stars);await p.setStringList('done',done.toList());} if(mounted)setState((){});}
  @override Widget build(BuildContext context){
    final cats=['Все','Динозавры','Океан','Транспорт','Животные','Еда','Природа','Космос'];
    return Scaffold(backgroundColor:const Color(0xFFF4F9FF),body:SafeArea(child:CustomScrollView(slivers:[
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(20,18,20,8),child:Row(children:[
        const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Привет, малыш!',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900,color:Color(0xFF243B68))),Text('Собирай картинки и получай звёздочки ⭐',style:TextStyle(color:Color(0xFF62718D)))])),
        Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22)),child:Text('⭐ $stars',style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)))
      ]))),
      SliverToBoxAdapter(child:Container(margin:const EdgeInsets.all(16),padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF63B8FF),Color(0xFF6687F5)]),borderRadius:BorderRadius.circular(26)),child:Row(children:[
        const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Мир открытий!',style:TextStyle(fontSize:23,color:Colors.white,fontWeight:FontWeight.w900)),SizedBox(height:5),Text('Весёлые пазлы без интернета',style:TextStyle(color:Colors.white,fontSize:15))])),
        CharacterImage('dino', width:104, height:104)
      ]))),
      SliverToBoxAdapter(child: MiniGamesSection(onReturn: _load)),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.symmetric(horizontal:18,vertical:4),child:Text('Выбери мир',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:Color(0xFF243B68))))),
      SliverPadding(padding:const EdgeInsets.all(14),sliver:SliverGrid(delegate:SliverChildBuilderDelegate((c,i){
        final cat=cats[i+1]; final list=items.where((e)=>e.category==cat).toList(); final item=list.first;
        return InkWell(borderRadius:BorderRadius.circular(22),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LevelsPage(category:cat,items:list,onWin:reward))),
          child:Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),boxShadow:[BoxShadow(color:Colors.blue.withOpacity(.07),blurRadius:12,offset:const Offset(0,5))]),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
            Expanded(child:Padding(padding:const EdgeInsets.all(8),child:CharacterImage(item.asset, width: 140, height: 140))),
            Text(cat,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w800,color:Color(0xFF30456D))),
            Padding(padding:const EdgeInsets.only(bottom:12,top:3),child:Text('${list.length} пазла',style:const TextStyle(color:Color(0xFF8290A8))))
          ])));
      },childCount:cats.length-1),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:1.08))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(20,8,20,24),child:Text('Все игры доступны сразу • Прогресс сохраняется на устройстве',textAlign:TextAlign.center,style:TextStyle(color:Color(0xFF8390A6)))))
    ])));
  }
}

class LevelsPage extends StatelessWidget {
 final String category; final List<PuzzleItem> items; final Future<void> Function(String) onWin;
 const LevelsPage({super.key,required this.category,required this.items,required this.onWin});
 @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFFF4F9FF),appBar:AppBar(title:Text(category,style:const TextStyle(fontWeight:FontWeight.w900)),backgroundColor:const Color(0xFFF4F9FF)),body:GridView.builder(padding:const EdgeInsets.all(16),itemCount:items.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:14,mainAxisSpacing:14),itemBuilder:(c,i){final p=items[i];return InkWell(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>PuzzlePage(item:p,onWin:onWin))),child:Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(24)),child:Column(children:[Expanded(child:Padding(padding:const EdgeInsets.all(10),child:CharacterImage(p.asset, width: 140, height: 140))),Padding(padding:const EdgeInsets.only(bottom:14),child:Text(p.name,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)))])));}));
}

class PuzzlePage extends StatefulWidget {
  final PuzzleItem item;
  final Future<void> Function(String) onWin;
  const PuzzlePage({super.key, required this.item, required this.onWin});
  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  late List<int> order;
  late List<int?> slots;
  bool won = false;
  int? selectedPiece;
  static const int n = 2;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    order = List.generate(n * n, (i) => i)..shuffle();
    slots = List<int?>.filled(n * n, null);
    won = false;
    selectedPiece = null;
  }

  void _drop(int piece, int slot) {
    if (won || slots[slot] != null || !order.contains(piece)) return;
    setState(() {
      selectedPiece = null;
      slots[slot] = piece;
      order.remove(piece);
      won = slots.every((v) => v != null) &&
          List.generate(n * n, (i) => slots[i] == i).every((v) => v);
    });
    if (won) { GameAudio.win(); } else { GameAudio.correct(); }
    HapticFeedback.selectionClick();
    if (won) { HapticFeedback.heavyImpact(); _finish(); }
  }

  Future<void> _finish() async {
    GameAudio.win();
    HapticFeedback.mediumImpact();
    await widget.onWin(widget.item.asset);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ура! Получилось! 🎉', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CharacterImage(widget.item.asset, height: 120),
            const Text(
              'Ты собрал картинку и заработал звёздочку!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Дальше'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(_reset);
            },
            child: const Text('Ещё раз'),
          ),
        ],
      ),
    );
  }

  Widget _piece(int piece, {bool draggable = false}) {
    final image = Container(
      width: 74,
      height: 74,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: PuzzlePieceGraphic(
          asset: widget.item.asset,
          piece: piece,
          size: 66,
        ),
      ),
    );
    final selectable = GestureDetector(
      onTap: () => setState(() => selectedPiece = piece),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPiece == piece ? const Color(0xFF3478E8) : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: image,
      ),
    );
    if (!draggable) return selectable;
    return Draggable<int>(
      data: piece,
      feedback: Material(
        color: Colors.transparent,
        child: CharacterImage(widget.item.asset, width: 86, height: 86),
      ),
      childWhenDragging: const SizedBox(width: 80, height: 80),
      child: selectable,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.item.color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.item.name),
        actions: [
          IconButton(
            onPressed: () => setState(_reset),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Нажми на деталь, затем на клетку — или перетащи её',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 5,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: n * n,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemBuilder: (context, index) => DragTarget<int>(
                        onWillAcceptWithDetails: (details) =>
                            slots[index] == null && !won,
                        onAcceptWithDetails: (details) =>
                            _drop(details.data, index),
                        builder: (context, candidates, rejects) =>
                            GestureDetector(
                          onTap: () {
                            if (won) return;
                            final placed = slots[index];
                            if (placed != null) {
                              setState(() {
                                order.add(placed);
                                slots[index] = null;
                                selectedPiece = null;
                              });
                            } else if (selectedPiece != null) {
                              _drop(selectedPiece!, index);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.55),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: slots[index] == null
                                ? const Center(
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      PuzzlePieceGraphic(asset: widget.item.asset, piece: slots[index]!, size: 132),
                                      Positioned(
                                        right: 5,
                                        top: 5,
                                        child: CircleAvatar(
                                          radius: 11,
                                          backgroundColor: const Color(0xFF3478E8),
                                          child: Text('${slots[index]! + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 18),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.55),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: order.map((piece) => _piece(piece, draggable: true)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
