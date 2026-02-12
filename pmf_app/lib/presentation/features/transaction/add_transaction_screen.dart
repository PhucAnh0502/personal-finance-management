import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/budget_bloc/budget_bloc.dart';
import 'package:pmf_app/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/data/models/transaction_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  List<Map<String, dynamic>> _categories = [];
  String? _accountId;
  TransactionType _transactionType = TransactionType.expense;
  XFile? _receiptImage;
  bool _isUploadingReceipt = false;

  late AnimationController _ambientController;
  late Animation<Alignment> _bgAlignmentAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _bgAlignmentAnimation =
        AlignmentTween(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).animate(
          CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut),
        );

    _floatAnimation = Tween<double>(begin: -14, end: 14).animate(
      CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut),
    );

    _loadCategories();
    _loadAccountId();
  }

  Future<void> _loadCategories() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;
    final response = await client
        .from('categories')
        .select('id, name, icon, color')
        .eq('user_id', userId);

    setState(() {
      _categories = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _loadAccountId() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;
    final response = await client
        .from('accounts')
        .select('id')
        .eq('user_id', userId)
        .single();

    setState(() {
      _accountId = response['id'];
    });
  }

  Future<void> _pickReceiptImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _receiptImage = image;
    });
  }

  Future<String> _uploadReceiptImage(XFile image) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;
    final nameParts = image.name.split('.');
    final extension = nameParts.length > 1
        ? nameParts.last.toLowerCase()
        : 'jpg';
    final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final path = 'receipts/$userId/$fileName';
    final bytes = await image.readAsBytes();

    debugPrint(
      'Uploading receipt to $path (${bytes.length} bytes, $contentType)',
    );

    await client.storage
        .from('personal_receipts')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );
    return client.storage.from('personal_receipts').getPublicUrl(path);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null &&
        _transactionType == TransactionType.expense) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category for expenses'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    if (_accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account not found'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    String categoryId = _selectedCategoryId ?? '';
    if (_transactionType == TransactionType.income) {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser!.id;
      final incomeCategory = await client
          .from('categories')
          .select('id')
          .eq('user_id', userId)
          .eq('name', 'Income')
          .maybeSingle();

      if (incomeCategory == null) {
        final newCategory = await client
            .from('categories')
            .insert({'name': 'Income', 'user_id': userId})
            .select()
            .single();
        categoryId = newCategory['id'];
      } else {
        categoryId = incomeCategory['id'];
      }
    }

    String? receiptUrl;
    if (_transactionType == TransactionType.expense && _receiptImage != null) {
      setState(() {
        _isUploadingReceipt = true;
      });

      try {
        receiptUrl = await _uploadReceiptImage(_receiptImage!);
      } catch (e) {
        debugPrint('Receipt upload failed: $e');
        if (mounted) {
          setState(() {
            _isUploadingReceipt = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Receipt upload failed: $e'),
              backgroundColor: AppColors.expense,
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      setState(() {
        _isUploadingReceipt = false;
      });
    }

    final transaction = TransactionModel(
      accountId: _accountId!,
      categoryId: categoryId,
      amount: double.parse(_amountController.text),
      note: _noteController.text.isEmpty ? null : _noteController.text,
      transactionDate: DateTime.now(),
      transactionType: _transactionType,
      imageUrl: receiptUrl,
    );

    context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
    context.read<BudgetBloc>().add(FetchBudgetsEvent(DateTime.now()));

    _amountController.clear();
    _noteController.clear();
    setState(() {
      _selectedCategoryId = null;
      _selectedCategoryName = null;
      _receiptImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_transactionType == TransactionType.income ? "Income" : "Expense"} added successfully',
        ),
        backgroundColor: AppColors.primaryEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _bgAlignmentAnimation.value,
                end: Alignment.bottomRight,
                colors: AppColors.backgroundGradient.colors,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -80,
                  child: Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mint.withOpacity(0.45),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -140,
                  left: -60,
                  child: Transform.translate(
                    offset: Offset(0, -_floatAnimation.value),
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryEmerald.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Add Transaction',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _transactionType == TransactionType.income
                              ? 'Record your income'
                              : 'Track your spending',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildForm(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.85),
            border: Border.all(color: Colors.white.withOpacity(0.7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5A6B90).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Type',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        TransactionType.expense,
                        'Expense',
                        Icons.arrow_downward,
                        AppColors.expense,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeButton(
                        TransactionType.income,
                        'Income',
                        Icons.arrow_upward,
                        AppColors.primaryEmerald,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Amount',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: AppColors.primaryEmerald,
                    ),
                    suffixText: 'VND',
                    suffixStyle: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                if (_transactionType == TransactionType.expense) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Category',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showCategoryPicker,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.category,
                            color: AppColors.primaryEmerald,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedCategoryName ?? 'Select a category',
                              style: TextStyle(
                                color: _selectedCategoryName == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Receipt (optional)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickReceiptImage,
                        icon: const Icon(Icons.photo_camera, size: 18),
                        label: Text(
                          _receiptImage == null ? 'Capture' : 'Retake',
                        ),
                      ),
                    ],
                  ),
                  if (_receiptImage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            color: AppColors.primaryEmerald,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _receiptImage!.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _receiptImage = null;
                              });
                            },
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),
                    ),
                  if (_isUploadingReceipt)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Note (optional)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a note...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploadingReceipt ? null : _submitTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _transactionType == TransactionType.income
                          ? AppColors.primaryEmerald
                          : AppColors.expense,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isUploadingReceipt
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Add ${_transactionType == TransactionType.income ? "Income" : "Expense"}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(
    TransactionType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _transactionType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionType = type;
          if (type == TransactionType.income) {
            _selectedCategoryId = null;
            _selectedCategoryName = null;
            _receiptImage = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() async {
    // Reload categories to get the latest list
    await _loadCategories();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select Category',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No categories available.\nPlease create a budget first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryEmerald.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.category,
                            color: AppColors.primaryEmerald,
                          ),
                        ),
                        title: Text(
                          category['name'],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category['id'];
                            _selectedCategoryName = category['name'];
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
