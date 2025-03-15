import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../data/models/expense.dart';

class ExpenseForm extends ConsumerStatefulWidget {
  final Expense? initialExpense;
  final Function(String budgetId, String category, double amount, DateTime date,
      String? note, String? imagePath) onSubmit;

  const ExpenseForm({
    super.key,
    this.initialExpense,
    required this.onSubmit,
  });

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBudgetId;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  File? _receiptImage;
  bool _isImageLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedBudgetId = widget.initialExpense?.budgetId;
    _amountController = TextEditingController(
        text: widget.initialExpense?.amount.toStringAsFixed(2));
    _noteController = TextEditingController(text: widget.initialExpense?.note);
    _selectedDate = widget.initialExpense?.date ?? DateTime.now();

    if (widget.initialExpense?.receiptUrl != null) {
      // TODO: Load image from URL
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isImageLoading = true;
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (pickedFile != null) {
        setState(() {
          _receiptImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture image')),
      );
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetsStream = ref.watch(activeBudgetsProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          budgetsStream.when(
            data: (budgets) {
              if (budgets.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No active budgets found'),
                );
              }

              return DropdownButtonFormField<String>(
                value: _selectedBudgetId,
                decoration: const InputDecoration(
                  labelText: 'Budget Category',
                  border: OutlineInputBorder(),
                ),
                items: budgets.map((budget) {
                  return DropdownMenuItem(
                    value: budget.id,
                    child: Text(budget.category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBudgetId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a budget category';
                  }
                  return null;
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => const Text('Error loading budgets'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
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
              labelText: 'Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text: '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isImageLoading ? null : _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Add Receipt'),
                ),
              ),
              if (_receiptImage != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            _receiptImage!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              color: Colors.white,
                              onPressed: () {
                                setState(() {
                                  _receiptImage = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() && _selectedBudgetId != null) {
                widget.onSubmit(
                  _selectedBudgetId!,
                  _selectedBudgetId!,
                  double.parse(_amountController.text),
                  _selectedDate,
                  _noteController.text.isEmpty ? null : _noteController.text,
                  _receiptImage?.path,
                );
              }
            },
            child: Text(
                widget.initialExpense == null ? 'Add Expense' : 'Update Expense'),
          ),
        ],
      ),
    );
  }
} 