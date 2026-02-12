import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/asset_bloc/asset_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/data/models/asset_model.dart';

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> with TickerProviderStateMixin {
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

    _bgAlignmentAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(
        CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut));

    _floatAnimation = Tween<double>(begin: -14, end: 14).animate(
        CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut));

    context.read<AssetBloc>().add(FetchAssetEvent());
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
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
                  child: BlocBuilder<AssetBloc, AssetState>(
                    builder: (context, state) {
                      if (state is AssetLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryEmerald,
                          ),
                        );
                      }

                      if (state is AssetError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${state.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<AssetBloc>().add(FetchAssetEvent());
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is AssetLoaded) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Assets',
                                      style: TextStyle(
                                        color: AppColors.navyDark,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildTotalValueCard(state.totalValue, state.assets),
                                    const SizedBox(height: 28),
                                    _buildAssetList(state.assets),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAssetModal(),
        backgroundColor: AppColors.primaryEmerald,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTotalValueCard(double totalValue, List<AssetModel> assets) {
    // Calculate total profit/loss percentage
    double totalCost = 0;
    for (final asset in assets) {
      totalCost += asset.quantity * asset.purchasePrice;
    }
    final totalProfitLoss = totalValue - totalCost;
    final isProfit = totalProfitLoss >= 0;
    final profitLossPercentage = totalCost > 0 ? (totalProfitLoss / totalCost) * 100 : 0;
    
    final cardColor = isProfit ? AppColors.primaryEmerald : AppColors.error;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: cardColor.withOpacity(0.15),
            border: Border.all(color: cardColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Portfolio Value',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${totalValue.toStringAsFixed(2)} VND',
                style: TextStyle(
                  color: cardColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${isProfit ? '+' : ''}${profitLossPercentage.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isProfit ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetList(List<AssetModel> assets) {
    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up_outlined,
              color: AppColors.primaryEmerald.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'No assets yet',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first asset to get started',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: assets.map((asset) => _buildAssetCard(asset)).toList(),
    );
  }

  Widget _buildAssetCard(AssetModel asset) {
    final profitLoss = asset.profitLoss;
    final isProfit = profitLoss >= 0;
    final totalValue = asset.totalValue;
    final cardColor = isProfit ? AppColors.primaryEmerald : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: cardColor.withOpacity(0.1),
              border: Border.all(color: cardColor.withOpacity(0.2)),
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset.assetName,
                                style: const TextStyle(
                                  color: AppColors.navyDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildAssetTypeBadge(asset.assetType),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _showDeleteConfirmation(asset),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${totalValue.toStringAsFixed(2)} VND',
                              style: TextStyle(
                                color: cardColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${isProfit ? '+' : ''}${profitLoss.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: isProfit ? Colors.greenAccent : Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAssetInfo('Quantity', asset.quantity.toString()),
                        _buildAssetInfo('Buy Price', '${asset.purchasePrice.toStringAsFixed(2)} VND'),
                        _buildAssetInfo('Current Price', '${asset.currentPrice.toStringAsFixed(2)} VND'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetTypeBadge(String type) {
    Color badgeColor;
    IconData icon;

    switch (type.toLowerCase()) {
      case 'gold':
        badgeColor = const Color(0xFFFFD700);
        icon = Icons.diamond;
        break;
      case 'silver':
        badgeColor = const Color(0xFFC0C0C0);
        icon = Icons.diamond;
        break;
      case 'stock':
        badgeColor = AppColors.primaryEmerald;
        icon = Icons.trending_up;
        break;
      case 'crypto':
        badgeColor = const Color(0xFFF7931A);
        icon = Icons.currency_bitcoin;
        break;
      default:
        badgeColor = Colors.grey;
        icon = Icons.category;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 12),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.navyDark,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navyDark,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showAddAssetModal() {
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
                borderRadius: const BorderRadius.only(
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
                      _buildModalTextField(assetNameController,
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
                            child: _buildModalTextField(
                                quantityController,
                                "Quantity",
                                "0.00",
                                TextInputType.number),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildModalTextField(
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
                                  context.read<AssetBloc>().add(
                                        AddAssetEvent(newAsset),
                                      );
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

  TextFormField _buildModalTextField(
    TextEditingController controller,
    String label,
    String hint, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asset Type',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.transparent,
            ),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedValue,
            underline: const SizedBox(),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(AssetModel asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text(
          'Are you sure you want to delete ${asset.assetName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (asset.id != null) {
                context.read<AssetBloc>().add(DeleteAssetEvent(asset.id!));
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
