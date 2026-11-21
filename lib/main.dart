import 'character_assets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const BabyPuzzleApp());

class BabyPuzzleApp extends StatelessWidget {
  const BabyPuzzleApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'Baby Puzzle World',
    theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto', colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3478E8))),
    home: const HomePage(),
  );
}

class CharacterImage extends StatelessWidget {
  final String name;
  final double? width, height;
  final BoxFit fit;
  const CharacterImage(this.name, {super.key, this.width, this.height, this.fit=BoxFit.contain});
  @override Widget build(BuildContext context) => SizedBox(
    width: width, height: height,
    child: LayoutBuilder(builder: (context, constraints) => Center(
      child: Text(characterAssets[name] ?? '🧩', textAlign: TextAlign.center,
        style: TextStyle(fontSize: (constraints.maxWidth.isFinite ? constraints.maxWidth : 120) * .82, height: 1.0)),
    )),
  );
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
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.symmetric(horizontal:18,vertical:4),child:Text('Выбери мир',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:Color(0xFF243B68))))),
      SliverPadding(padding:const EdgeInsets.all(14),sliver:SliverGrid(delegate:SliverChildBuilderDelegate((c,i){
        final cat=cats[i+1]; final list=items.where((e)=>e.category==cat).toList(); final item=list.first;
        return InkWell(borderRadius:BorderRadius.circular(22),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LevelsPage(category:cat,items:list,onWin:reward))),
          child:Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),boxShadow:[BoxShadow(color:Colors.blue.withOpacity(.07),blurRadius:12,offset:const Offset(0,5))]),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
            Expanded(child:Padding(padding:const EdgeInsets.all(8),child:CharacterImage(item.asset))),
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
 @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFFF4F9FF),appBar:AppBar(title:Text(category,style:const TextStyle(fontWeight:FontWeight.w900)),backgroundColor:const Color(0xFFF4F9FF)),body:GridView.builder(padding:const EdgeInsets.all(16),itemCount:items.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:14,mainAxisSpacing:14),itemBuilder:(c,i){final p=items[i];return InkWell(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>PuzzlePage(item:p,onWin:onWin))),child:Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(24)),child:Column(children:[Expanded(child:Padding(padding:const EdgeInsets.all(10),child:CharacterImage(p.asset))),Padding(padding:const EdgeInsets.only(bottom:14),child:Text(p.name,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)))])));}));
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
    if (won) _finish();
  }

  Future<void> _finish() async {
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
