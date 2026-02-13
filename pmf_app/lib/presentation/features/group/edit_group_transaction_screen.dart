import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pmf_app/bloc/group_bloc/group_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/data/models/category_model.dart';
import 'package:pmf_app/data/models/group_transaction_model.dart';

class EditGroupTransactionScreen extends StatefulWidget {
  final String groupId;
  final GroupTransactionModel transaction;
  final List<CategoryModel> categories;

  const EditGroupTransactionScreen({
    Key? key,
    required this.groupId,
    required this.transaction,
    required this.categories,
  }) : super(key: key);

  @override
  State<EditGroupTransactionScreen> createState() =>
      _EditGroupTransactionScreenState();
}

class _EditGroupTransactionScreenState
    extends State<EditGroupTransactionScreen>
    with TickerProviderStateMixin {
  late AnimationController _ambientController;
  late Animation<Alignment> _bgAlignmentAnimation;
  late Animation<double> _floatAnimation;

  final _imagePicker = ImagePicker();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategoryId;
  XFile? _receiptImage;
  String? _currentImageUrl;
  bool _isUploadingReceipt = false;

  @override
  void initState() {
    super.initState();

    _amountController.text = widget.transaction.amount.toStringAsFixed(0);
    _noteController.text = widget.transaction.note ?? '';
    _selectedCategoryId = widget.transaction.category?.id;
    _currentImageUrl = widget.transaction.imageProof;

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    _bgAlignmentAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(
        CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut));

    _floatAnimation = Tween<double>(begin: -14, end: 14).animate(
        CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Receipt Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _receiptImage = image;
      _currentImageUrl = null;
    });
  }

  Future<String> _uploadReceiptImage(XFile image) async {
    final client = Supabase.instance.client;
    final groupId = widget.groupId;
    final nameParts = image.name.split('.');
    final extension =
        nameParts.length > 1 ? nameParts.last.toLowerCase() : 'jpg';
    final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final path = '$groupId/$fileName';
    final bytes = await image.readAsBytes();

    await client.storage.from('group_receipts').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );
    return client.storage.from('group_receipts').getPublicUrl(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, child) {
          return Container(
            height: MediaQuery.of(context).size.height,
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
                  bottom: -100,
                  left: -60,
                  child: Transform.translate(
                    offset: Offset(0, -_floatAnimation.value),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryEmerald.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                _buildContent(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  _buildAmountField(),
                  const SizedBox(height: 16),
                  _buildCategoryField(),
                  const SizedBox(height: 16),
                  _buildNoteField(),
                  const SizedBox(height: 16),
                  _buildReceiptSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.navyDark),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Expense Detail',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    final amountText = widget.transaction.amount.toStringAsFixed(0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryEmerald.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryEmerald.withOpacity(0.45),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: const TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'VND',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    final categoryName =
        widget.transaction.category?.name ?? 'Uncategorized';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryEmerald.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.secondaryEmerald.withOpacity(0.8),
                ),
              ),
              child: Text(
                categoryName,
                style: const TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    final noteText = widget.transaction.note?.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryEmerald.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Note (optional)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (noteText == null || noteText.isEmpty)
                ? 'No note provided'
                : noteText,
            style: TextStyle(
              color: (noteText == null || noteText.isEmpty)
                  ? AppColors.textSecondary
                  : AppColors.navyDark,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryEmerald.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receipt',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          if (_receiptImage == null && _currentImageUrl == null)
            _buildReceiptPlaceholder()
          else
            _buildReceiptPreview(),
          if (_receiptImage != null || _currentImageUrl != null)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Tap image to view',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReceiptPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryEmerald.withOpacity(0.7),
          style: BorderStyle.solid,
          width: 1.2,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, color: AppColors.textSecondary, size: 30),
            SizedBox(height: 8),
            Text(
              'No receipt attached',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptPreview() {
    final imageWidget = _receiptImage != null
        ? Image.file(
            File(_receiptImage!.path),
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: AppColors.mintLight,
                child: const Center(
                  child: Icon(Icons.receipt, color: AppColors.textSecondary),
                ),
              );
            },
          )
        : Image.network(
            _currentImageUrl!,
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: AppColors.mintLight,
                child: const Center(
                  child: Icon(Icons.receipt, color: AppColors.textSecondary),
                ),
              );
            },
          );

    return Column(
      children: [
        GestureDetector(
          onTap: _showReceiptPreviewDialog,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageWidget,
          ),
        )
      ],
    );
  }

  void _showReceiptPreviewDialog() {
    if (_receiptImage == null && _currentImageUrl == null) return;
    final imageWidget = _receiptImage != null
        ? Image.file(
            File(_receiptImage!.path),
            fit: BoxFit.contain,
          )
        : Image.network(
            _currentImageUrl!,
            fit: BoxFit.contain,
          );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.white,
            child: imageWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isUploadingReceipt ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryEmerald,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isUploadingReceipt
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Update Expense',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_amountController.text.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    String? imageProofUrl = _currentImageUrl;
    if (_receiptImage != null) {
      setState(() => _isUploadingReceipt = true);
      try {
        imageProofUrl = await _uploadReceiptImage(_receiptImage!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
        setState(() => _isUploadingReceipt = false);
        return;
      }
      setState(() => _isUploadingReceipt = false);
    }

    context.read<GroupBloc>().add(UpdateGroupExpense(
          transactionId: widget.transaction.id,
          groupId: widget.groupId,
          amount: amount,
          categoryId: _selectedCategoryId!,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          imageProof: imageProofUrl,
        ));

    Navigator.pop(context);
  }
}
