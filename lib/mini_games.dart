import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'character_assets.dart';

void _tapSound(){SystemSound.play(SystemSoundType.click);HapticFeedback.selectionClick();}
void _winSound(){SystemSound.play(SystemSoundType.alert);HapticFeedback.mediumImpact();}

class MiniGamesSection extends StatelessWidget {
 const MiniGamesSection({super.key});
 @override Widget build(BuildContext context){
  final games=<_GameCard>[
   _GameCard('Найди пару','🧠','Тренируй память',const Color(0xFFE9E2FF),const MemoryGamePage()),
   _GameCard('Найди предмет','🔎','Ищи нужную картинку',const Color(0xFFFFE8D7),const FindGamePage()),
   _GameCard('Угадай тень','🌙','Узнай силуэт',const Color(0xFFDFF2FF),const ShadowGamePage()),
  ];
  return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const Padding(padding:EdgeInsets.fromLTRB(18,12,18,10),child:Text('Другие игры',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:Color(0xFF243B68)))),
   SizedBox(height:150,child:ListView.separated(padding:const EdgeInsets.symmetric(horizontal:14),scrollDirection:Axis.horizontal,itemCount:games.length,separatorBuilder:(_,__)=>const SizedBox(width:12),itemBuilder:(c,i){
    final g=games[i];return SizedBox(width:190,child:Material(color:g.color,borderRadius:BorderRadius.circular(22),child:InkWell(borderRadius:BorderRadius.circular(22),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>g.page)),child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(g.emoji,style:const TextStyle(fontSize:34)),const Spacer(),Text(g.title,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900,color:Color(0xFF293B5E))),Text(g.subtitle,style:const TextStyle(fontSize:12,color:Color(0xFF52627D)))])))));
   })),
  ]);
 }
}
class _GameCard{final String title,emoji,subtitle;final Color color;final Widget page;const _GameCard(this.title,this.emoji,this.subtitle,this.color,this.page);}
List<MapEntry<String,String>> _deck([int count=8]){final all=characterAssets.entries.toList()..shuffle();return all.take(count).toList();}

class MemoryGamePage extends StatefulWidget{const MemoryGamePage({super.key});@override State<MemoryGamePage> createState()=>_MemoryGamePageState();}
class _MemoryGamePageState extends State<MemoryGamePage>{
 late List<MapEntry<String,String>> cards;late List<int> order;final Set<int> opened={};final Set<int> matched={};int moves=0;bool locked=false;
 @override void initState(){super.initState();_reset();}
 void _reset(){cards=_deck(6);order=[...List.generate(6,(i)=>i),...List.generate(6,(i)=>i)]..shuffle();opened.clear();matched.clear();moves=0;locked=false;}
 Future<void> _flip(int i)async{
  if(locked||matched.contains(i)||opened.contains(i))return;_tapSound();setState(()=>opened.add(i));
  if(opened.length==2){moves++;final pair=opened.toList();if(order[pair[0]]==order[pair[1]]){await Future.delayed(const Duration(milliseconds:300));if(!mounted)return;setState((){matched.addAll(pair);opened.clear();});_winSound();if(matched.length==order.length)_complete();}else{locked=true;await Future.delayed(const Duration(milliseconds:800));if(!mounted)return;setState((){opened.clear();locked=false;});}}
 }
 void _complete(){showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Умница! 🎉',textAlign:TextAlign.center),content:Text('Все пары найдены! Ходов: $moves',textAlign:TextAlign.center),actions:[TextButton(onPressed:(){Navigator.pop(c);setState(_reset);},child:const Text('Ещё раз')),FilledButton(onPressed:(){Navigator.pop(c);Navigator.pop(context);},child:const Text('Готово'))]));}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2ECFF),
      appBar: AppBar(
        title: const Text('Найди пару'),
        backgroundColor: Colors.transparent,
        actions: [IconButton(onPressed: () => setState(_reset), icon: const Icon(Icons.refresh))],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Открой две одинаковые картинки • Ходы: $moves', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: order.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (context, index) {
              final visible = opened.contains(index) || matched.contains(index);
              return GestureDetector(
                onTap: () => _flip(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: visible ? Colors.white : const Color(0xFF8B79D9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        visible ? cards[order[index]].value : '❔',
                        key: ValueKey(visible ? order[index].toString() : 'back$index'),
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class FindGamePage extends StatefulWidget{const FindGamePage({super.key});@override State<FindGamePage> createState()=>_FindGamePageState();}
class _FindGamePageState extends State<FindGamePage>{
 late List<MapEntry<String,String>> options;late int target;int score=0;String message='Найди такую же картинку!';
 void _next(){options=_deck(9);target=Random().nextInt(options.length);message='Найди такую же картинку!';}
 @override void initState(){super.initState();_next();}
 void _choose(int i){if(i==target){_winSound();setState(()=>score++);showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Правильно! ⭐',textAlign:TextAlign.center),content:Text('Ты нашёл '+options[target].value,textAlign:TextAlign.center),actions:[FilledButton(onPressed:(){Navigator.pop(c);setState(_next);},child:const Text('Дальше'))]));}else{_tapSound();setState(()=>message='Попробуй ещё раз 🙂');}}
 @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFFFFF0E3),appBar:AppBar(title:const Text('Найди предмет'),backgroundColor:Colors.transparent,actions:[IconButton(onPressed:()=>setState(_next),icon:const Icon(Icons.refresh))]),body:Column(children:[const SizedBox(height:18),Text('⭐ $score',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const Text('Найди картинку:',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),AnimatedSwitcher(duration:const Duration(milliseconds:300),child:Text(options[target].value,key:ValueKey(options[target].key),style:const TextStyle(fontSize:84))),Text(message,style:const TextStyle(fontSize:16)),Expanded(child:GridView.builder(padding:const EdgeInsets.all(18),itemCount:options.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:12,mainAxisSpacing:12),itemBuilder:(c,i)=>Material(color:Colors.white,borderRadius:BorderRadius.circular(20),child:InkWell(borderRadius:BorderRadius.circular(20),onTap:()=>_choose(i),child:Center(child:Text(options[i].value,style:const TextStyle(fontSize:48)))))))]));}
}

class ShadowGamePage extends StatefulWidget{const ShadowGamePage({super.key});@override State<ShadowGamePage> createState()=>_ShadowGamePageState();}
class _ShadowGamePageState extends State<ShadowGamePage>{
 late List<MapEntry<String,String>> options;late int target;int score=0;
 void _next(){options=_deck(3);target=Random().nextInt(3);}
 @override void initState(){super.initState();_next();}
 void _choose(int i){if(i==target){_winSound();setState(()=>score++);showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Верно! 🌟',textAlign:TextAlign.center),content:const Text('Ты узнал силуэт!',textAlign:TextAlign.center),actions:[FilledButton(onPressed:(){Navigator.pop(c);setState(_next);},child:const Text('Следующий'))]));}else{_tapSound();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Это другая тень. Попробуй ещё!')));}}
 @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFFE6F5FF),appBar:AppBar(title:const Text('Угадай тень'),backgroundColor:Colors.transparent,actions:[IconButton(onPressed:()=>setState(_next),icon:const Icon(Icons.refresh))]),body:Column(children:[const SizedBox(height:20),Text('⭐ $score',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const Text('Кому принадлежит эта тень?',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),const SizedBox(height:30),AnimatedSwitcher(duration:const Duration(milliseconds:300),child:Text(options[target].value,key:ValueKey(options[target].key),style:const TextStyle(fontSize:100,color:Colors.black))),const Text('Выбери правильную картинку',style:TextStyle(fontSize:16)),Expanded(child:GridView.builder(padding:const EdgeInsets.all(18),itemCount:3,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:12,mainAxisSpacing:12),itemBuilder:(c,i)=>Material(color:Colors.white,borderRadius:BorderRadius.circular(20),child:InkWell(borderRadius:BorderRadius.circular(20),onTap:()=>_choose(i),child:Center(child:Text(options[i].value,style:const TextStyle(fontSize:48)))))))]));}
}
