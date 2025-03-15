import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/goal.dart';

class GoalForm extends StatefulWidget {
  final Goal? initialGoal;
  final Function(String title, String category, double targetAmount,
      DateTime targetDate, String? note) onSubmit;

  const GoalForm({
    super.key,
    this.initialGoal,
    required this.onSubmit,
  });

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  String _selectedCategory = 'Savings';
  late DateTime _targetDate;

  final List<String> _categories = [
    'Savings',
    'Emergency Fund',
    'Retirement',
    'House',
    'Car',
    'Education',
    'Travel',
    'Wedding',
    'Business',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialGoal?.title);
    _amountController = TextEditingController(
        text: widget.initialGoal?.targetAmount.toStringAsFixed(2));
    _noteController = TextEditingController(text: widget.initialGoal?.note);
    _selectedCategory = widget.initialGoal?.category ?? _categories.first;
    _targetDate = widget.initialGoal?.targetDate ??
        DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Goal Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Target Amount',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a target amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Target Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text: '${_targetDate.month}/${_targetDate.day}/${_targetDate.year}',
            ),
            onTap: _selectDate,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  _titleController.text,
                  _selectedCategory,
                  double.parse(_amountController.text),
                  _targetDate,
                  _noteController.text.isEmpty ? null : _noteController.text,
                );
              }
            },
            child: Text(widget.initialGoal == null ? 'Create Goal' : 'Update Goal'),
          ),
        ],
      ),
    );
  }
} 