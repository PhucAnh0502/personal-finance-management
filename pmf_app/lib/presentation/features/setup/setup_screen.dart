import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/core/utils/format_helper.dart';
import 'package:pmf_app/presentation/shared/neumorphic_container.dart';
import '../../../bloc/setup_bloc/setup_bloc.dart';
import '../../../data/models/asset_model.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  int _currentStep = 0;
  String _selectedAvatar = 'assets/avatars/avatar1.jpg';
  final List<AssetModel> _assets = [];
  final _formKey = GlobalKey<FormState>();

  final List<String> _defaultAvatars = [
    'assets/avatars/avatar1.jpg',
    'assets/avatars/avatar2.jpg',
    'assets/avatars/avatar3.jpg',
    'assets/avatars/avatar4.jpg',
    'assets/avatars/avatar5.jpg',
    'assets/avatars/avatar6.jpg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 1) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please enter your display name."),
              backgroundColor: AppColors.error),
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<SetupBloc, SetupState>(
        listener: (context, state) {
          if (state is SetupSuccess) {
            // Navigate to budget screen after setup completion
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/budget', (route) => false);
          } else if (state is SetupFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppColors.expense),
            );
          }
        },
        child: Stack(
          children: [
            // Animated gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
            ),
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mint.withOpacity(0.45),
                ),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryEmerald.withOpacity(0.6),
                ),
              ),
            ),
            // Main content
            Column(
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: (_currentStep + 1) / 2,
                        backgroundColor:
                            AppColors.textSecondary.withOpacity(0.2),
                        color: AppColors.primaryEmerald,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Step ${_currentStep + 1} / 2",
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) =>
                        setState(() => _currentStep = index),
                    children: [
                      _buildProfileStep(),
                      _buildFinancialStep(),
                    ],
                  ),
                ),
              ],
            ),
            if (_currentStep > 0)
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                      color: AppColors.textPrimary),
                  onPressed: _prevPage,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // STEP 1: CHOOSE AVATAR & NAME
  Widget _buildProfileStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Set up your profile",
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Customize your account with a name and avatar",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 50),
          const Text(
            "Choose your avatar",
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _defaultAvatars.map((path) {
              bool isSelected = _selectedAvatar == path;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = path),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryEmerald
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.primaryEmerald.withOpacity(0.4),
                              blurRadius: 16,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(path),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 50),
          const Text(
            "Your name",
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 15),
          NeumorphicContainer(
            child: TextField(
              controller: _nameController,
                style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 16),
              decoration: const InputDecoration(
                hintText: "Enter your display name",
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                prefixIcon:
                    Icon(Icons.person_outline, color: AppColors.primaryEmerald),
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 50),
          _buildActionButton("Next", _nextPage),
        ],
      ),
    );
  }

  // STEP 2: ENTER FINANCIAL DETAILS
  Widget _buildFinancialStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Financial Setup",
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Add your account balance and assets",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 40),
            _buildSectionTitle("Account Balance"),
            const SizedBox(height: 15),
            NeumorphicContainer(
              child: TextFormField(
                controller: _balanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                style: const TextStyle(
                  color: AppColors.primaryEmerald,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "0.00",
                  hintStyle:
                    TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
                  border: InputBorder.none,
                  suffixText: "VND",
                  suffixStyle:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your balance';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Your Assets"),
                GestureDetector(
                  onTap: _showBottomSheetAddAsset,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.emeraldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 5),
                        Text(
                          "Add Asset",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAssetsList(),
            const SizedBox(height: 40),
            BlocBuilder<SetupBloc, SetupState>(
              builder: (context, state) {
                if (state is SetupLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryEmerald));
                }
                return _buildActionButton("Complete Setup", _submitSetup);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600),
    );
  }

  Widget _buildAssetsList() {
    if (_assets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.75),
        ),
        child: const Center(
          child: Text(
            "No assets yet.\nTap 'Add Asset' to get started.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textSecondary, height: 1.5, fontSize: 14),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        final totalValue = asset.quantity * asset.purchasePrice;
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.emeraldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.trending_up,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.assetName,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${asset.quantity} × ${FormatHelper.formatCurrency(asset.purchasePrice)} = ${FormatHelper.formatCurrencyWithSymbol(totalValue, symbol: ' VND')}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.expense, size: 20),
                    onPressed: () {
                      setState(() {
                        _assets.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBottomSheetAddAsset() {
    final assetNameController = TextEditingController();
    String selectedAssetType = 'Gold';
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    final assetTypeOptions = ['Gold', 'Silver', 'Stock', 'Crypto'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 30,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                ),
                child: Form(
                  key: dialogFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Add New Asset",
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.textPrimary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildBottomSheetTextField(assetNameController,
                          "Asset Name", "e.g., Bitcoin, Gold"),
                      const SizedBox(height: 16),
                      _buildAssetTypeDropdown(
                        selectedAssetType,
                        assetTypeOptions,
                        (newValue) {
                          setModalState(() {
                            selectedAssetType = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBottomSheetTextField(
                                quantityController,
                                "Quantity",
                                "0.00",
                                TextInputType.number),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBottomSheetTextField(
                                priceController,
                                "Price (per unit)",
                                "0.00",
                                TextInputType.number),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.primaryEmerald,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Cancel",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.primaryEmerald,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (dialogFormKey.currentState!.validate()) {
                                  final newAsset = AssetModel(
                                    assetName: assetNameController.text,
                                    assetType: selectedAssetType,
                                    quantity: double.tryParse(
                                            quantityController.text) ??
                                        0,
                                    purchasePrice:
                                        double.tryParse(priceController.text) ??
                                            0,
                                  );
                                  setState(() {
                                    _assets.add(newAsset);
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: AppColors.emeraldGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Add Asset",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  TextFormField _buildBottomSheetTextField(
    TextEditingController controller,
    String label,
    String hint, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : [],
        style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12)),
        focusedBorder: const UnderlineInputBorder(
          borderSide:
            BorderSide(color: AppColors.primaryEmerald, width: 2)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildAssetTypeDropdown(
    String selectedValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: "Asset Type",
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryEmerald, width: 2),
        ),
      ),
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an asset type';
        }
        return null;
      },
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppColors.emeraldGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryEmerald.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _submitSetup() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<SetupBloc>().add(SetupSubmitted(
          displayName: _nameController.text,
          avatarUrl: _selectedAvatar,
          accountBalance:
              double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0,
          assets: _assets,
        ));
  }
}