import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<Expense> _items = [];
  double _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _db.getByMonth(_month);
    if (!mounted) return;
    setState(() {
      _items = items;
      _total = items.fold(0.0, (s, e) => s + e.amount);
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
    _load();
  }

  Future<void> _openForm([Expense? e]) async {
    final saved = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: e)));
    if (saved == true) _load();
  }

  Future<void> _delete(Expense e) async {
    await _db.delete(e.id!);
    _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('تم حذف "${e.title}"'),
      action: SnackBarAction(
        label: 'تراجع',
        onPressed: () async {
          await _db.insert(e);
          _load();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'ar').format(_month);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مصروفاتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'الإحصائيات',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StatsScreen(month: _month))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('مصروف جديد'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _changeMonth(-1)),
                    Text(monthLabel,
                        style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _changeMonth(1)),
                  ],
                ),
                const Text('إجمالي المصروفات'),
                Text(
                  '${_total.toStringAsFixed(2)} $currency',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('لا توجد مصروفات في هذا الشهر'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final e = _items[i];
                          final cat = categoryByName(e.category);
                          return Dismissible(
                            key: ValueKey(e.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _delete(e),
                            child: ListTile(
                              onTap: () => _openForm(e),
                              leading: CircleAvatar(
                                backgroundColor: cat.color.withOpacity(0.15),
                                child: Icon(cat.icon, color: cat.color),
                              ),
                              title: Text(e.title),
                              subtitle: Text(
                                  '${e.category} • ${DateFormat('d MMMM', 'ar').format(e.date)}'),
                              trailing: Text(
                                '${e.amount.toStringAsFixed(2)} $currency',
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
