import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const EnergyBudgetApp());

class EnergyBudgetApp extends StatelessWidget {
  const EnergyBudgetApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Контроль Бюджета',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardTheme(color: Color(0xFF1E1E1E)),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double t1Price = 5.56; double t2Price = 2.41; double t3Price = 6.50; double budgetLimit = 1500.0;
  double t1Kwh = 120.0; double t2Kwh = 45.0; double t3Kwh = 88.0;
  late TextEditingController _limitCtrl, _t1Ctrl, _t2Ctrl, _t3Ctrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _limitCtrl = TextEditingController(text: budgetLimit.toStringAsFixed(0));
    _t1Ctrl = TextEditingController(text: t1Price.toString());
    _t2Ctrl = TextEditingController(text: t2Price.toString());
    _t3Ctrl = TextEditingController(text: t3Price.toString());
  }

  void _saveSettings() {
    setState(() {
      budgetLimit = double.tryParse(_limitCtrl.text) ?? budgetLimit;
      t1Price = double.tryParse(_t1Ctrl.text) ?? t1Price;
      t2Price = double.tryParse(_t2Ctrl.text) ?? t2Price;
      t3Price = double.tryParse(_t3Ctrl.text) ?? t3Price;
    });
  }

  void _simulateBurning() {
    setState(() { t1Kwh += 15.0; t2Kwh += 5.0; });
  }

  @override
  Widget build(BuildContext context) {
    double costT1 = t1Kwh * t1Price; double costT2 = t2Kwh * t2Price; double costT3 = t3Kwh * t3Price;
    double totalNow = costT1 + costT2 + costT3; bool isOverLimit = totalNow >= budgetLimit;
    return Scaffold(
      appBar: AppBar(title: const Text('Мониторинг Энергии Welrok'), bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Статус'), Tab(text: 'Настройки')])),
      body: TabBarView(controller: _tabController, children: [
        Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Т1 (Пик): ${t1Kwh.toStringAsFixed(1)} кВтч (${costT1.toStringAsFixed(2)} ₽)', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Т2 (Ночь): ${t2Kwh.toStringAsFixed(1)} кВтч (${costT2.toStringAsFixed(2)} ₽)', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Т3 (Полупик): ${t3Kwh.toStringAsFixed(1)} кВтч (${costT3.toStringAsFixed(2)} ₽)', style: const TextStyle(fontSize: 16)),
          ]))),
          const SizedBox(height: 15),
          Text('Текущий счет: ${totalNow.toStringAsFixed(2)} / ${budgetLimit.toStringAsFixed(2)} руб.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isOverLimit ? Colors.redAccent : Colors.greenAccent)),
          const SizedBox(height: 15),
          if (isOverLimit) Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(8)), child: const Text('⚠️ ЛИМИТ В 1500 РУБ ИСЧЕРПАН!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))
          else Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade900, borderRadius: BorderRadius.circular(8)), child: Text('✅ До лимита осталось: ${(budgetLimit - totalNow).toStringAsFixed(2)} руб.', style: const TextStyle(color: Colors.white))),
          const Spacer(),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900), onPressed: _simulateBurning, child: const Text('Имитировать приток кВтч', style: TextStyle(color: Colors.white))))
        ])),
        Padding(padding: const EdgeInsets.all(16.0), child: ListView(children: [
          TextField(controller: _limitCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Лимит бюджета')),
          TextField(controller: _t1Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Цена Т1')),
          TextField(controller: _t2Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Цена Т2')),
          TextField(controller: _t3Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Цена Т3')),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: _saveSettings, child: const Text('Сохранить конфигурацию'))
        ]))
      ]),
    );
  }
}

