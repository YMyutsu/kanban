class Task {
  String title;
  int status; // 0:欲しいもの 1:購入予定 2:ゲット済み
  int price;  // グッズの価格

  Task(this.title, [this.status = 0, this.price = 0]);
}