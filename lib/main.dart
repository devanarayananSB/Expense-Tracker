import 'package:flutter/material.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Save Karo',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.deepPurple,
      ),
      home: ExpenseTrackerScreen(),
    );
  }
}

class ExpenseTrackerScreen extends StatefulWidget {
  @override
  _ExpenseTrackerScreenState createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _expenses = [];
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _incomeController = TextEditingController();
  final List<String> _categories = ["Food", "Rent", "Entertainment", "Other"];
  String? _selectedCategory;
  double _income = 0.0;
  bool _showIncomeInput = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  void _addExpense() {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text);

    if (description.isNotEmpty && amount != null && amount > 0 && _selectedCategory != null) {
      setState(() {
        _expenses.add({
          'description': description,
          'amount': amount,
          'category': _selectedCategory,
        });
      });

      _descriptionController.clear();
      _amountController.clear();
      _selectedCategory = null;
      Navigator.of(context).pop();
    }
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  double get _totalExpense {
    return _expenses.fold(0.0, (sum, item) => sum + item['amount']);
  }

  void _calculateIncome() {
    final income = double.tryParse(_incomeController.text);
    if (income != null && income >= 0) {
      setState(() {
        _income = income;
      });
    }
  }

  void _toggleIncomeInput() {
    setState(() {
      if (_showIncomeInput) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
      _showIncomeInput = !_showIncomeInput;
    });
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Category'),
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingAmount = _income - _totalExpense;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.purple],
            ),
          ),
        ),
        title: Text(
          'Profit Hunter',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepPurple.shade50, Colors.purple.shade100],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Toggle Income Input
                  GestureDetector(
                    onTap: _toggleIncomeInput,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'Set Income',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Summary Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryCard('Total Expense', '₹${_totalExpense.toStringAsFixed(2)}',
                          Colors.red),
                      _buildSummaryCard(
                          'Remaining',
                          '₹${remainingAmount.toStringAsFixed(2)}',
                          _income - _totalExpense > 0 ? Colors.green : Colors.red),
                    ],
                  ),
                  Divider(thickness: 2, height: 30),

                  // Expense List
                  Expanded(
                    child: _expenses.isEmpty
                        ? Center(
                            child: Text(
                              'No expenses added yet!',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _expenses.length,
                            itemBuilder: (ctx, index) {
                              final expense = _expenses[index];
                              return Dismissible(
                                key: ValueKey(expense),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(Icons.delete, color: Colors.white),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) => _deleteExpense(index),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.deepPurple,
                                      child: Icon(Icons.money, color: Colors.white),
                                    ),
                                    title: Text(expense['description']),
                                    subtitle: Text(
                                      '₹${expense['amount'].toStringAsFixed(2)} (${expense['category']})',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Income Input Slide Animation
         SlideTransition(
  position: _slideAnimation,
  child: Container(
    height: 200,
    width: MediaQuery.of(context).size.width * 0.9,
    margin: EdgeInsets.only(left: 20),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleIncomeInput, // Reverse the SlideTransition animation
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.arrow_back, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text(
                'Back',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _incomeController,
          decoration: InputDecoration(
            labelText: 'Enter your Income',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _calculateIncome,
          child: Text('Set Income'),
        ),
      ],
    ),
  ),
),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color valueColor) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}
