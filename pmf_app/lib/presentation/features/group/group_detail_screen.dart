import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/group_bloc/group_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/core/theme/app_theme.dart';
import 'package:pmf_app/core/utils/format_helper.dart';
import 'package:pmf_app/data/models/category_model.dart';
import 'package:pmf_app/data/models/group_budget_model.dart';
import 'package:pmf_app/data/models/group_model.dart';
import 'package:pmf_app/data/models/group_transaction_model.dart';
import 'package:pmf_app/presentation/features/group/add_transaction_screen.dart';
import 'package:pmf_app/presentation/features/group/edit_group_transaction_screen.dart';
import 'package:pmf_app/presentation/shared/neumorphic_container.dart';

class GroupDetailScreen extends StatefulWidget {
	final GroupModel group;

	const GroupDetailScreen({super.key, required this.group});

	@override
	State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
		with TickerProviderStateMixin {
	late TabController _tabController;
	late double _totalFund;
	List<CategoryModel> _categories = [];
	String? _filterCategoryId;
	DateTime? _filterStartDate;
	DateTime? _filterEndDate;

	@override
	void initState() {
		super.initState();
		_totalFund = widget.group.totalFund;
		_tabController = TabController(length: 2, vsync: this);

		context.read<GroupBloc>().add(FetchGroupDetail(widget.group.id));
	}

	@override
	void dispose() {
		_tabController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return WillPopScope(
			onWillPop: () async {
				context.read<GroupBloc>().add(FetchGroups());
				return true;
			},
			child: Scaffold(
				body: Container(
					height: MediaQuery.of(context).size.height,
					decoration: BoxDecoration(
						gradient: AppTheme.getBackgroundGradient(context),
					),
					child: Stack(
						children: [
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
							SafeArea(
								child: BlocBuilder<GroupBloc, GroupState>(
									builder: (context, state) {
											if (state is GroupLoading) {
												return const Center(
													child: CircularProgressIndicator(
														color: AppColors.primaryEmerald,
													),
												);
											}

											if (state is GroupError) {
												return Center(
													child: Column(
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															const Icon(
																Icons.error_outline,
																color: AppColors.error,
																size: 48,
															),
															const SizedBox(height: 16),
															Text(
																state.message,
																textAlign: TextAlign.center,
																style: TextStyle(
																	color: AppTheme.getSubtitleStyle(context).color,
																	fontSize: 14,
																),
															),
															const SizedBox(height: 20),
															ElevatedButton.icon(
																onPressed: () => context
																		.read<GroupBloc>()
																		.add(FetchGroupDetail(widget.group.id)),
																icon: const Icon(Icons.refresh),
																label: const Text('Retry'),
															),
														],
													),
												);
											}

											if (state is GroupDetailLoaded) {
												_categories = state.categories;
												final budgetByCategoryId = <String, GroupBudgetModel>{
													for (final budget in state.budgets)
														budget.categoryId: budget,
												};
												final filteredTransactions = _applyFilters(state.transactions);
												final totalSpent = _calculateTotalSpent(filteredTransactions);
												final categorySpending = _calculateCategorySpending(filteredTransactions);

												return SingleChildScrollView(
													child: Padding(
														padding: const EdgeInsets.all(20),
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Row(
																	children: [
																		IconButton(
																			onPressed: () {
																				context.read<GroupBloc>().add(FetchGroups());
																				Navigator.pop(context);
																			},
																			icon: Icon(
																				Icons.arrow_back_ios_new,
																				color: AppTheme.getTextPrimaryColor(context),
																			),
																		),
																		const SizedBox(width: 4),
																		Text(
																			widget.group.name,
																			style: AppTheme.getTitleStyle(context).copyWith(
																				fontSize: 24,
																			),
																		),
																			const Spacer(),
																			IconButton(
																				onPressed: _showDeleteGroupDialog,
																				icon: const Icon(
																					Icons.delete_outline,
																					color: AppColors.error,
																				),
																			),
																	],
																),
																const SizedBox(height: 16),
																_buildGroupSummary(_totalFund),
																const SizedBox(height: 16),
																_buildSpendingSummary(totalSpent, _totalFund),
																const SizedBox(height: 24),
																_buildTabBar(),
																const SizedBox(height: 16),
																SizedBox(
																	height: MediaQuery.of(context).size.height * 0.5,
																	child: TabBarView(
																		controller: _tabController,
																		children: [
																			_buildCategoryTab(
																				state.categories,
																				categorySpending,
																				budgetByCategoryId,
																			),
																			_buildTransactionsTab(filteredTransactions),
																		],
																	),
																),
																const SizedBox(height: 40),
															],
														),
													),
												);
											}

											return const SizedBox.shrink();
										},
									),
								),
							],
						),
			),
			floatingActionButton: BlocBuilder<GroupBloc, GroupState>(
				builder: (context, state) {
					if (state is GroupDetailLoaded) {
						return FloatingActionButton(
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute(
										builder: (_) => AddTransactionScreen(
											groupId: widget.group.id,
											categories: state.categories,
										),
									),
								);
							},
							backgroundColor: AppColors.primaryEmerald,
							child: const Icon(Icons.add, color: Colors.white),
						);
					}
					return const SizedBox.shrink();
				},
			),
		),
		);
	}

	Widget _buildGroupSummary(double totalFund) {
		return NeumorphicContainer(
			borderRadius: BorderRadius.circular(20),
			padding: const EdgeInsets.all(16),
			child: Row(
				children: [
					Container(
						width: 48,
						height: 48,
						decoration: BoxDecoration(
							shape: BoxShape.circle,
							color: AppColors.primaryEmerald.withOpacity(0.15),
						),
						child: const Icon(
							Icons.account_balance_wallet,
							color: AppColors.primaryEmerald,
						),
					),
					const SizedBox(width: 12),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Total Fund',
									style: AppTheme.getSubtitleStyle(context).copyWith(
										fontSize: 12,
									),
								),
								const SizedBox(height: 4),
								Text(
									'${FormatHelper.formatCurrencyWithSymbol(totalFund, symbol: ' VND')}',
									style: TextStyle(
										color: AppTheme.getTextPrimaryColor(context),
										fontSize: 18,
										fontWeight: FontWeight.bold,
									),
								),
							],
						),
					),
					IconButton(
						onPressed: _showUpdateFundModal,
						icon: const Icon(
							Icons.edit_outlined,
							color: AppColors.primaryEmerald,
						),
					),
				],
			),
		);
	}

	Widget _buildTransactionCard(GroupTransactionModel transaction) {
		final date = _formatDate(transaction.createdAt);
		return Padding(
			padding: const EdgeInsets.only(bottom: 12),
			child: GestureDetector(
				behavior: HitTestBehavior.opaque,
				onTap: () => _showEditExpenseDialog(transaction),
				child: NeumorphicContainer(
					borderRadius: BorderRadius.circular(16),
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Expanded(
										child: Text(
											transaction.category?.name ?? 'Uncategorized',
											style: TextStyle(
												color: AppTheme.getTextPrimaryColor(context),
												fontSize: 14,
												fontWeight: FontWeight.bold,
											),
										),
									),
									IconButton(
										padding: EdgeInsets.zero,
										constraints: const BoxConstraints(),
										icon: const Icon(
											Icons.delete,
											size: 18,
											color: AppColors.expense,
										),
										onPressed: () => _showDeleteExpenseDialog(transaction),
									),
								],
							),
							const SizedBox(height: 4),
							Text(
								'-${FormatHelper.formatCurrencyWithSymbol(transaction.amount, symbol: ' VND')}',
								style: const TextStyle(
									color: AppColors.expense,
									fontSize: 14,
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 8),
							if (transaction.note != null && transaction.note!.isNotEmpty)
								Text(
									transaction.note!,
											style: TextStyle(
												color: AppTheme.getSubtitleStyle(context).color,
												fontSize: 12,
											),
								),
							const SizedBox(height: 8),
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Text(
										transaction.creatorName,
											style: TextStyle(
												color: AppTheme.getSubtitleStyle(context).color,
												fontSize: 11,
											),
									),
									Text(
										date,
											style: TextStyle(
												color: AppTheme.getSubtitleStyle(context).color,
												fontSize: 11,
											),
									),
								],
							),
						],
					),
				),
			),
		);
	}

	String _formatDate(DateTime date) {
		final local = date.toLocal();
		return '${local.day.toString().padLeft(2, '0')}/'
				'${local.month.toString().padLeft(2, '0')}/'
				'${local.year}';
	}

	List<GroupTransactionModel> _applyFilters(List<GroupTransactionModel> transactions) {
		var filtered = transactions;

		if (_filterCategoryId != null) {
			filtered = filtered.where((t) => t.category?.id == _filterCategoryId).toList();
		}

		if (_filterStartDate != null) {
			filtered = filtered.where((t) => t.createdAt.isAfter(_filterStartDate!.subtract(const Duration(days: 1)))).toList();
		}

		if (_filterEndDate != null) {
			filtered = filtered.where((t) => t.createdAt.isBefore(_filterEndDate!.add(const Duration(days: 1)))).toList();
		}

		return filtered;
	}

	double _calculateTotalSpent(List<GroupTransactionModel> transactions) {
		return transactions.fold(0.0, (sum, t) => sum + t.amount);
	}

	Map<String, double> _calculateCategorySpending(List<GroupTransactionModel> transactions) {
		final Map<String, double> spending = {};
		for (final t in transactions) {
			final catId = t.category?.id ?? 'uncategorized';
			spending[catId] = (spending[catId] ?? 0.0) + t.amount;
		}
		return spending;
	}

	bool _hasActiveFilters() {
		return _filterCategoryId != null || _filterStartDate != null || _filterEndDate != null;
	}

	Widget _buildSpendingSummary(double totalSpent, double totalFund) {
		final remaining = totalFund - totalSpent;
		final percentUsed = totalFund > 0 ? (totalSpent / totalFund) * 100 : 0.0;

		return NeumorphicContainer(
			borderRadius: BorderRadius.circular(20),
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						'Spending Summary',
						style: AppTheme.getSubtitleStyle(context).copyWith(
							fontSize: 12,
							fontWeight: FontWeight.w600,
						),
					),
					const SizedBox(height: 12),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Total Spent',
										style: AppTheme.getSubtitleStyle(context).copyWith(
											fontSize: 11,
										),
									),
									Text(
										'${FormatHelper.formatCurrencyWithSymbol(totalSpent, symbol: ' VND')}',
										style: const TextStyle(
											color: AppColors.expense,
											fontSize: 16,
											fontWeight: FontWeight.bold,
										),
									),
								],
							),
							Column(
								crossAxisAlignment: CrossAxisAlignment.end,
								children: [
									Text(
										'Remaining',
										style: AppTheme.getSubtitleStyle(context).copyWith(
											fontSize: 11,
										),
									),
									Text(
										'${FormatHelper.formatCurrencyWithSymbol(remaining, symbol: ' VND')}',
										style: TextStyle(
											color: remaining >= 0 ? AppColors.income : AppColors.expense,
											fontSize: 16,
											fontWeight: FontWeight.bold,
										),
									),
								],
							),
						],
					),
					const SizedBox(height: 12),
					LinearProgressIndicator(
						value: percentUsed / 100,
						backgroundColor: AppTheme.getSurfaceColor(context).withOpacity(0.6),
						valueColor: AlwaysStoppedAnimation<Color>(
							percentUsed > 100 ? AppColors.expense : AppColors.primaryEmerald,
						),
						minHeight: 8,
						borderRadius: BorderRadius.circular(4),
					),
					const SizedBox(height: 8),
					Text(
						'${percentUsed.toStringAsFixed(1)}% of budget used',
						style: AppTheme.getSubtitleStyle(context).copyWith(fontSize: 11),
					),
				],
			),
		);
	}

	void _showFilterDialog() {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Filter Transactions'),
				content: StatefulBuilder(
					builder: (context, setDialogState) {
						return SingleChildScrollView(
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
									const SizedBox(height: 8),
									DropdownButton<String?>(
										isExpanded: true,
										value: _filterCategoryId,
										hint: const Text('All categories'),
										items: [
											const DropdownMenuItem<String?>(
												value: null,
												child: Text('All categories'),
											),
											..._categories.map((cat) {
												return DropdownMenuItem<String?>(
													value: cat.id,
													child: Text(cat.name),
												);
											}).toList(),
										],
										onChanged: (val) {
											setDialogState(() {
												_filterCategoryId = val;
											});
										},
									),
									const SizedBox(height: 16),
									const Text('Start Date', style: TextStyle(fontWeight: FontWeight.w600)),
									const SizedBox(height: 8),
									ListTile(
										contentPadding: EdgeInsets.zero,
										title: Text(_filterStartDate == null
												? 'No start date'
												: _formatDate(_filterStartDate!)),
										trailing: const Icon(Icons.calendar_today, size: 18),
										onTap: () async {
											final picked = await showDatePicker(
												context: context,
												initialDate: _filterStartDate ?? DateTime.now(),
												firstDate: DateTime(2020),
												lastDate: DateTime.now(),
											);
											if (picked != null) {
												setDialogState(() {
													_filterStartDate = picked;
												});
											}
										},
									),
									if (_filterStartDate != null)
										TextButton(
											onPressed: () {
												setDialogState(() {
													_filterStartDate = null;
												});
											},
											child: const Text('Clear'),
										),
									const SizedBox(height: 16),
									const Text('End Date', style: TextStyle(fontWeight: FontWeight.w600)),
									const SizedBox(height: 8),
									ListTile(
										contentPadding: EdgeInsets.zero,
										title: Text(_filterEndDate == null
												? 'No end date'
												: _formatDate(_filterEndDate!)),
										trailing: const Icon(Icons.calendar_today, size: 18),
										onTap: () async {
											final picked = await showDatePicker(
												context: context,
												initialDate: _filterEndDate ?? DateTime.now(),
												firstDate: DateTime(2020),
												lastDate: DateTime.now(),
											);
											if (picked != null) {
												setDialogState(() {
													_filterEndDate = picked;
												});
											}
										},
									),
									if (_filterEndDate != null)
										TextButton(
											onPressed: () {
												setDialogState(() {
													_filterEndDate = null;
												});
											},
											child: const Text('Clear'),
										),
								],
							),
						);
					},
				),
				actions: [
					TextButton(
						onPressed: () {
							setState(() {
								_filterCategoryId = null;
								_filterStartDate = null;
								_filterEndDate = null;
							});
							Navigator.pop(context);
						},
						child: const Text('Clear All'),
					),
					TextButton(
						onPressed: () {
							setState(() {});
							Navigator.pop(context);
						},
						child: const Text('Apply'),
					),
				],
			),
		);
	}

	Color _parseHexColor(String hexColor) {
		var hex = hexColor.replaceAll('#', '');
		if (hex.length == 6) {
			hex = 'FF$hex';
		}
		return Color(int.parse(hex, radix: 16));
	}

	void _showUpdateFundModal() {
		final controller = TextEditingController(
			text: _totalFund.toStringAsFixed(2),
		);
		final formKey = GlobalKey<FormState>();

		showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			backgroundColor: Colors.transparent,
			builder: (context) {
				return Container(
					decoration: BoxDecoration(
						color: AppTheme.getModalBackgroundColor(context),
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
							key: formKey,
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Update Total Fund',
										style: AppTheme.getTitleStyle(context).copyWith(fontSize: 22),
									),
									const SizedBox(height: 20),
									TextFormField(
										controller: controller,
										keyboardType: TextInputType.number,
										style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
										decoration: InputDecoration(
											labelText: 'Total fund',
											hintText: '0.00',
											filled: true,
											fillColor: AppTheme.getSurfaceColor(context).withOpacity(0.5),
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(12),
												borderSide: BorderSide.none,
											),
											contentPadding: const EdgeInsets.symmetric(
												horizontal: 16, vertical: 12),
										),
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'Total fund is required';
											}
											final parsed = double.tryParse(value);
											if (parsed == null || parsed < 0) {
												return 'Enter a valid amount';
											}
											return null;
										},
									),
									const SizedBox(height: 24),
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
																width: 2,
															),
															borderRadius: BorderRadius.circular(12),
														),
														child: const Text(
															'Cancel',
															textAlign: TextAlign.center,
															style: TextStyle(
																color: AppColors.primaryEmerald,
																fontWeight: FontWeight.bold,
															),
														),
													),
												),
											),
											const SizedBox(width: 12),
											Expanded(
												child: GestureDetector(
													onTap: () {
														if (formKey.currentState!.validate()) {
															final value =
																double.parse(controller.text.trim());
															setState(() {
																_totalFund = value;
															});
															context.read<GroupBloc>().add(
																UpdateGroupFund(
																	groupId: widget.group.id,
																	totalFund: value,
																),
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
															'Update',
															textAlign: TextAlign.center,
															style: TextStyle(
																color: Colors.white,
																fontWeight: FontWeight.bold,
															),
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
				);
			},
		);
	}

	void _showCreateCategoryModal() {
		final nameController = TextEditingController();
		final limitController = TextEditingController();
		final formKey = GlobalKey<FormState>();

		showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			backgroundColor: Colors.transparent,
			builder: (context) {
				return Container(
					decoration: BoxDecoration(
						color: AppTheme.getModalBackgroundColor(context),
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
							key: formKey,
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Create Category',
										style: AppTheme.getTitleStyle(context).copyWith(fontSize: 22),
									),
									const SizedBox(height: 20),
									TextFormField(
										controller: nameController,
										style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
										decoration: InputDecoration(
											labelText: 'Category name',
											hintText: 'e.g. Food',
											filled: true,
											fillColor: AppTheme.getSurfaceColor(context).withOpacity(0.5),
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(12),
												borderSide: BorderSide.none,
											),
											contentPadding: const EdgeInsets.symmetric(
												horizontal: 16, vertical: 12),
										),
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'Category name is required';
											}
											return null;
										},
									),
										const SizedBox(height: 16),
										_buildDialogTextField(
											limitController,
											'Budget Limit (VND)',
											'0.00',
											TextInputType.number,
										),
									const SizedBox(height: 24),
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
																width: 2,
															),
															borderRadius: BorderRadius.circular(12),
														),
														child: const Text(
															'Cancel',
															textAlign: TextAlign.center,
															style: TextStyle(
																color: AppColors.primaryEmerald,
																fontWeight: FontWeight.bold,
															),
														),
													),
												),
											),
											const SizedBox(width: 12),
											Expanded(
												child: GestureDetector(
													onTap: () {
														if (formKey.currentState!.validate()) {
														final limit =
															double.tryParse(limitController.text.trim()) ?? 0;
															context.read<GroupBloc>().add(
																CreateGroupCategory(
																	groupId: widget.group.id,
																	name: nameController.text.trim(),
																limitAmount: limit,
																),
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
															'Create',
															textAlign: TextAlign.center,
															style: TextStyle(
																color: Colors.white,
																fontWeight: FontWeight.bold,
															),
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
				);
			},
		);
	}

	void _showEditCategoryDialog(CategoryModel category) {
		final nameController = TextEditingController(text: category.name);
		final formKey = GlobalKey<FormState>();

		showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			backgroundColor: Colors.transparent,
			builder: (context) {
				return BackdropFilter(
					filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
					child: Container(
						decoration: BoxDecoration(
							color: AppTheme.getModalBackgroundColor(context),
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
								key: formKey,
								child: Column(
									mainAxisSize: MainAxisSize.min,
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: [
												Text(
													'Edit Category',
													style: AppTheme.getTitleStyle(context).copyWith(fontSize: 22),
												),
												IconButton(
													icon: Icon(
														Icons.close,
														color: AppTheme.getTextPrimaryColor(context),
													),
													onPressed: () => Navigator.pop(context),
												),
											],
										),
										const SizedBox(height: 20),
										_buildDialogTextField(
											nameController,
											'Category Name',
											'Enter category name',
											TextInputType.text,
										),
										const SizedBox(height: 30),
										SizedBox(
											width: double.infinity,
											child: ElevatedButton(
												onPressed: () {
													if (formKey.currentState!.validate()) {
														context.read<GroupBloc>().add(
															UpdateGroupCategory(
																categoryId: category.id,
																groupId: widget.group.id,
																name: nameController.text.trim(),
															),
														);
														Navigator.pop(context);
													}
												},
												style: ElevatedButton.styleFrom(
													backgroundColor: AppColors.primaryEmerald,
													padding: const EdgeInsets.symmetric(vertical: 16),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(12),
													),
												),
												child: const Text(
													'Update Category',
													style: TextStyle(
														color: Colors.white,
														fontSize: 16,
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
			},
		);
	}

	void _showDeleteCategoryDialog(CategoryModel category) {
		showModalBottomSheet(
			context: context,
			backgroundColor: Colors.transparent,
			builder: (context) {
				return BackdropFilter(
					filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
					child: Container(
						padding: const EdgeInsets.all(24),
						decoration: BoxDecoration(
							color: AppTheme.getModalBackgroundColor(context),
							borderRadius: const BorderRadius.only(
								topLeft: Radius.circular(32),
								topRight: Radius.circular(32),
							),
						),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Delete Category',
									style: AppTheme.getTitleStyle(context).copyWith(fontSize: 20),
								),
								const SizedBox(height: 12),
								Text(
									'Remove ${category.name} from group categories? All transactions in this category will remain but become uncategorized.',
										style: TextStyle(
											color: AppTheme.getSubtitleStyle(context).color,
											fontSize: 14,
											height: 1.4,
										),
								),
								const SizedBox(height: 24),
								Row(
									children: [
										Expanded(
											child: OutlinedButton(
												onPressed: () => Navigator.pop(context),
												style: OutlinedButton.styleFrom(
													side: BorderSide(
														color: AppTheme.getSurfaceColor(context).withOpacity(0.6),
													),
													padding: const EdgeInsets.symmetric(vertical: 12),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(12),
													),
												),
												child: const Text('Cancel'),
											),
										),
										const SizedBox(width: 12),
										Expanded(
											child: ElevatedButton(
												onPressed: () {
													context.read<GroupBloc>().add(
														DeleteGroupCategory(
															categoryId: category.id,
															groupId: widget.group.id,
														),
													);
													Navigator.pop(context);
												},
												style: ElevatedButton.styleFrom(
													backgroundColor: AppColors.expense,
													padding: const EdgeInsets.symmetric(vertical: 12),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(12),
													),
												),
												child: const Text(
													'Delete',
													style: TextStyle(color: Colors.white),
												),
											),
										),
									],
								),
							],
						),
					),
				);
			},
		);
	}

	Widget _buildDialogTextField(
		TextEditingController controller,
		String label,
		String hint,
		TextInputType keyboardType,
	) {
		return TextFormField(
			controller: controller,
			keyboardType: keyboardType,
			inputFormatters: keyboardType == TextInputType.number
				? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
				: [],
			style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
			decoration: InputDecoration(
				labelText: label,
				hintText: hint,
				labelStyle: TextStyle(color: AppTheme.getSubtitleStyle(context).color),
				hintStyle: TextStyle(color: AppTheme.getSubtitleStyle(context).color),
				enabledBorder: UnderlineInputBorder(
					borderSide: BorderSide(
						color: AppTheme.getSurfaceColor(context).withOpacity(0.6),
					),
				),
				focusedBorder: const UnderlineInputBorder(
					borderSide: BorderSide(color: AppColors.primaryEmerald, width: 2),
				),
			),
			validator: (value) {
				if (value == null || value.isEmpty) {
					return 'This field cannot be empty';
				}
				return null;
			},
		);
	}

	void _showDeleteGroupDialog() {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Delete Group'),
				content: Text(
					'Are you sure you want to delete ${widget.group.name}? This action cannot be undone.',
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: const Text('Cancel'),
					),
					TextButton(
						onPressed: () {
							context.read<GroupBloc>().add(DeleteGroup(widget.group.id));
							Navigator.pop(context);
							Navigator.pop(context);
						},
						child: const Text(
							'Delete',
							style: TextStyle(color: AppColors.error),
						),
					),
				],
			),
		);
	}

	void _showEditExpenseDialog(GroupTransactionModel transaction) {
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (_) => BlocProvider.value(
					value: context.read<GroupBloc>(),
					child: EditGroupTransactionScreen(
						groupId: widget.group.id,
						transaction: transaction,
						categories: _categories,
					),
				),
			),
		);
	}

	void _showDeleteExpenseDialog(GroupTransactionModel transaction) {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Delete Expense'),
				content: const Text(
					'Are you sure you want to delete this expense?',
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: const Text('Cancel'),
					),
					TextButton(
						onPressed: () {
							context.read<GroupBloc>().add(DeleteGroupExpense(
								transactionId: transaction.id,
								groupId: widget.group.id,
							));
							Navigator.pop(context);
						},
						child: const Text(
							'Delete',
							style: TextStyle(color: AppColors.error),
						),
					),
				],
			),
		);
	}

	Widget _buildTabBar() {
		return ClipRRect(
			borderRadius: BorderRadius.circular(25),
			child: BackdropFilter(
				filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
				child: Container(
					decoration: BoxDecoration(
						color: AppTheme.getSurfaceColor(context).withOpacity(0.7),
						borderRadius: BorderRadius.circular(25),
						border: Border.all(
							color: AppTheme.getSurfaceColor(context).withOpacity(0.4),
						),
					),
					child: TabBar(
						controller: _tabController,
						indicator: BoxDecoration(
							gradient: AppColors.emeraldGradient,
							borderRadius: BorderRadius.circular(25),
						),
						labelColor: Colors.white,
						unselectedLabelColor:
							AppTheme.getSubtitleStyle(context).color,
						labelStyle: const TextStyle(
							fontSize: 14,
							fontWeight: FontWeight.bold,
						),
						dividerColor: Colors.transparent,
						indicatorSize: TabBarIndicatorSize.tab,
						tabs: const [
							Tab(text: 'Categories'),
							Tab(text: 'Transactions'),
						],
					),
				),
			),
		);
	}

	Widget _buildCategoryTab(
		List<CategoryModel> categories,
		Map<String, double> categorySpending,
		Map<String, GroupBudgetModel> budgetByCategoryId,
	) {
		if (categories.isEmpty) {
			return Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							Icons.category_outlined,
							size: 60,
							color: AppColors.primaryEmerald.withOpacity(0.5),
						),
						const SizedBox(height: 12),
						Text(
							'No categories yet',
							style: TextStyle(
								color: AppTheme.getSubtitleStyle(context).color,
								fontSize: 16,
							),
						),
						const SizedBox(height: 20),
						ElevatedButton.icon(
							onPressed: _showCreateCategoryModal,
							icon: const Icon(Icons.add),
							label: const Text('Add Category'),
							style: ElevatedButton.styleFrom(
								backgroundColor: AppColors.primaryEmerald,
								foregroundColor: Colors.white,
							),
						),
					],
				),
			);
		}

		return ListView(
			padding: const EdgeInsets.all(4),
			children: [
				Row(
					mainAxisAlignment: MainAxisAlignment.end,
					children: [
						TextButton.icon(
							onPressed: _showCreateCategoryModal,
							icon: const Icon(Icons.add, size: 18, color: AppColors.primaryEmerald),
							label: const Text(
								'Add',
								style: TextStyle(color: AppColors.primaryEmerald),
							),
						),
					],
				),
				...categories.map((category) {
					final color = _parseHexColor(category.color);
					final spent = categorySpending[category.id] ?? 0.0;
					final limit = budgetByCategoryId[category.id]?.amountLimit ?? 0.0;
					final remaining = limit - spent;
					final percentRemaining = limit > 0
							? ((remaining / limit) * 100).clamp(0.0, 100.0)
							: 0.0;
					
					Color statusColor = AppColors.primaryEmerald;
					if (limit <= 0) {
						statusColor = AppTheme.getSubtitleStyle(context).color ?? AppColors.textSecondary;
					} else if (percentRemaining < 15) {
						statusColor = AppColors.expense;
					} else if (percentRemaining < 50) {
						statusColor = Colors.orangeAccent;
					}

					return Padding(
						padding: const EdgeInsets.only(bottom: 16),
						child: ClipRRect(
							borderRadius: BorderRadius.circular(20),
							child: BackdropFilter(
								filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
								child: Container(
									padding: const EdgeInsets.all(20),
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(20),
										color: AppTheme.getCardColor(context),
										border: Border.all(
											color: AppTheme.getSurfaceColor(context).withOpacity(0.6),
										),
										boxShadow: [
											BoxShadow(
												color: Colors.black.withOpacity(0.08),
												blurRadius: 18,
												offset: const Offset(0, 12),
											),
										],
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Row(
												children: [
													Container(
														padding: const EdgeInsets.all(12),
														decoration: BoxDecoration(
															color: color.withOpacity(0.15),
															borderRadius: BorderRadius.circular(12),
														),
														child: Icon(
															Icons.category,
															color: color,
															size: 24,
														),
													),
													const SizedBox(width: 12),
													Expanded(
														child: Text(
															category.name,
															style: TextStyle(
																color: AppTheme.getTextPrimaryColor(context),
																fontSize: 16,
																fontWeight: FontWeight.bold,
															),
														),
													),
													IconButton(
														icon: const Icon(
															Icons.edit_outlined,
															color: AppColors.primaryEmerald,
															size: 20,
														),
														onPressed: () => _showEditCategoryDialog(category),
													),
													IconButton(
														icon: const Icon(
															Icons.delete_outline,
															color: AppColors.error,
															size: 20,
														),
														onPressed: () => _showDeleteCategoryDialog(category),
													),
												],
											),
											const SizedBox(height: 16),
											Row(
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
												children: [
													Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(
																'Remaining',
																style: AppTheme.getSubtitleStyle(context).copyWith(fontSize: 12),
															),
															const SizedBox(height: 4),
															Text(
																limit <= 0
																	? 'No budget'
																	: '${FormatHelper.formatCurrencyWithSymbol(remaining, symbol: ' VND')}',
																style: TextStyle(
																	color: statusColor,
																	fontSize: 18,
																	fontWeight: FontWeight.bold,
																),
															),
														],
													),
													Column(
														crossAxisAlignment: CrossAxisAlignment.end,
														children: [
															Text(
																'Spent / Total',
																style: AppTheme.getSubtitleStyle(context).copyWith(fontSize: 12),
															),
															const SizedBox(height: 4),
															Text(
																'${FormatHelper.formatCurrency(spent)} / ${FormatHelper.formatCurrency(limit)}',
																style: TextStyle(
																	color: AppTheme.getTextPrimaryColor(context),
																	fontSize: 14,
																	fontWeight: FontWeight.w600,
																),
															),
														],
													),
												],
											),
											const SizedBox(height: 12),
											ClipRRect(
												borderRadius: BorderRadius.circular(8),
												child: LinearProgressIndicator(
													value: percentRemaining / 100,
														backgroundColor: AppTheme.getSurfaceColor(context).withOpacity(0.3),
													valueColor: AlwaysStoppedAnimation<Color>(statusColor),
													minHeight: 10,
												),
											),
											const SizedBox(height: 8),
											Text(
												limit <= 0
													? 'No budget set'
													: '${percentRemaining.toStringAsFixed(0)}% remaining',
												style: TextStyle(
													color: statusColor,
													fontSize: 12,
													fontWeight: FontWeight.w600,
												),
											),
										],
									),
								),
							),
						),
					);
				}).toList(),
			],
		);
	}

	Widget _buildTransactionsTab(List<GroupTransactionModel> transactions) {
		return Column(
			children: [
				Row(
					mainAxisAlignment: MainAxisAlignment.end,
					children: [
						IconButton(
							icon: Icon(
								_hasActiveFilters() ? Icons.filter_alt : Icons.filter_alt_outlined,
								color: _hasActiveFilters()
									? AppColors.primaryEmerald
									: AppTheme.getSubtitleStyle(context).color,
							),
							onPressed: _showFilterDialog,
						),
					],
				),
				Expanded(
					child: transactions.isEmpty
						? Center(
								child: Column(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Icon(
											Icons.receipt_long,
											size: 60,
											color: AppColors.primaryEmerald.withOpacity(0.5),
										),
										const SizedBox(height: 12),
										Text(
											'No transactions yet',
											style: TextStyle(
												color: AppTheme.getSubtitleStyle(context).color,
												fontSize: 16,
											),
										),
									],
								),
							)
						: ListView(
								padding: const EdgeInsets.symmetric(horizontal: 4),
								children: transactions.map(_buildTransactionCard).toList(),
							),
				),
			],
		);
	}
}
