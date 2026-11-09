import 'package:flutter/material.dart';
import 'model.dart';
import 'view_model.dart';
import 'package:intl/intl.dart';


final names = ['💗 欲しいもの (Wishlist)', '🛒 購入予定 (To Buy)', '🎁 ゲット済み (Got It)'];
final labels = ['欲しいもの', '購入予定', 'ゲット済み'];
final colors = [Colors.pink.shade50, Colors.green.shade50, Colors.red.shade50];

class KanbanView extends StatefulWidget {
  final KanbanViewModel vm;
  KanbanView(this.vm, {super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final input = TextEditingController();
  final priceInput = TextEditingController();

  void add() {
    final price = int.tryParse(priceInput.text) ?? 0;

    widget.vm.add(input.text, price);

    input.clear();
    priceInput.clear();
  }
    Future<void> edit(Task t) async {
    var text = t.title;
    final result = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('タスクを編集'),
        content: TextFormField(
          initialValue: text,
          autofocus: true,
          onChanged: (v) => text = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, text),
            child: Text('保存'),
          ),
        ],
      ),
    );
    if (result != null) widget.vm.rename(t, result);
  }


  Widget taskCard(Task t) {
    final s = t.status;
    final buttons = Wrap(spacing: 4, children: [
        if (s > 0)
        TextButton(
          onPressed: () => widget.vm.move(t, s - 1),
          child: Text('← ${labels[s - 1]}へ'),
        ),
      if (s < 2)
        FilledButton(
          onPressed: () => widget.vm.move(t, s + 1),
          child: Text('${labels[s + 1]}へ →'),
        ),
    ]);
    
    return Card(child: ListTile(
      title: Text(t.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),

          Text(
            '¥${NumberFormat('#,###').format(t.price)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade400,
            ),
          ),

          SizedBox(height: 8),
          buttons,
        ],
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => edit(t),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline),
          onPressed: () => widget.vm.remove(t),
        ),
      ]),

    ));
  }

  Widget lane(int s) {
    final cards = [
      for (final t in widget.vm.tasks)
        if (t.status == s) taskCard(t),
    ];
    int totalPrice = 0;

    for (final t in widget.vm.tasks) {
      if (t.status == s) {
        totalPrice += t.price;
      }
    }
    return SizedBox(
      width: 300,
      child: Card(
        color: colors[s],
        child: Column(children: [
          ListTile(
            title: Text(names[s]),
            trailing: Text('${cards.length}件'),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '合計金額',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '¥${NumberFormat('#,###').format(totalPrice)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),

Expanded(child: ListView(children: cards)),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    priceInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: input,
      decoration: InputDecoration(
        labelText: '新しいグッズ',
        hintText: 'ファンクラブ会員限定アクスタ',
        border: OutlineInputBorder(),
      ),
    );
      
    final priceField = TextField(
      controller: priceInput,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '価格（円）',
        hintText: '例：1200',
        prefixIcon: Icon(Icons.currency_yen),
        border: OutlineInputBorder(),
      ),
    );
  


    final button = ValueListenableBuilder(
      valueListenable: input,
      builder: (context, value, child) => FilledButton.icon(
        onPressed: value.text.isEmpty ? null : add,
        icon: Icon(Icons.favorite_border),
        label: Text('欲しいものに追加 ♡'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.pink.shade200,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: StadiumBorder(),
          elevation: 2,
        ),
      ),
    );



    final entry = Card(child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(children: [
        field,
        SizedBox(height: 12),
        priceField,
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: button,
        ),
      ]),
    ));
    final board = ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) => ListView(
        scrollDirection: Axis.horizontal,
        children: [for (int s = 0; s < 3; s++) lane(s)],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('🐢推しグッズ管理🍏')),
      body: Column(children: [
        entry,
        Expanded(child: board),
      ]),
    );
  }
}