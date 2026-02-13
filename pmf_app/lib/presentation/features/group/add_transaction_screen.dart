import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/group_bloc/group_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/data/models/category_model.dart';
import 'package:pmf_app/presentation/shared/neumorphic_container.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTransactionScreen extends StatefulWidget {
	final String groupId;
	final List<CategoryModel> categories;

	const AddTransactionScreen({
		super.key,
		required this.groupId,
		required this.categories,
	});

	@override
	State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
		with TickerProviderStateMixin {
	late AnimationController _ambientController;
	late Animation<Alignment> _bgAlignmentAnimation;
	late Animation<double> _floatAnimation;

	final _formKey = GlobalKey<FormState>();
	final _amountController = TextEditingController();
	final _noteController = TextEditingController();
	final _imagePicker = ImagePicker();
	String? _selectedCategoryId;
	XFile? _receiptImage;
	bool _isUploadingReceipt = false;

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
		});
	}

	Future<String> _uploadReceiptImage(XFile image) async {
		final client = Supabase.instance.client;
		final groupId = widget.groupId;
		final nameParts = image.name.split('.');
		final extension = nameParts.length > 1
				? nameParts.last.toLowerCase()
				: 'jpg';
			final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
			final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
			final path = '$groupId/$fileName';
			final bytes = await image.readAsBytes();

		await client.storage
				.from('group_receipts')
				.uploadBinary(
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
												Row(
													children: [
														IconButton(
															onPressed: () => Navigator.pop(context),
															icon: const Icon(
																Icons.arrow_back_ios_new,
																color: AppColors.navyDark,
															),
														),
														const SizedBox(width: 4),
														const Text(
															'Add Expense',
															style: TextStyle(
																color: AppColors.navyDark,
																fontSize: 24,
																fontWeight: FontWeight.bold,
															),
														),
													],
												),
												const SizedBox(height: 20),
												NeumorphicContainer(
													borderRadius: BorderRadius.circular(20),
													padding: const EdgeInsets.all(16),
													child: Form(
														key: _formKey,
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																TextFormField(
																	controller: _amountController,
																	keyboardType: TextInputType.number,
																	decoration: InputDecoration(
																		labelText: 'Amount',
																		hintText: '0.00',
																		filled: true,
																		fillColor: AppColors.surface.withOpacity(0.5),
																		border: OutlineInputBorder(
																			borderRadius: BorderRadius.circular(12),
																			borderSide: BorderSide.none,
																		),
																		contentPadding: const EdgeInsets.symmetric(
																				horizontal: 16, vertical: 12),
																	),
																	validator: (value) {
																		if (value == null || value.trim().isEmpty) {
																			return 'Amount is required';
																		}
																		final parsed = double.tryParse(value);
																		if (parsed == null || parsed <= 0) {
																			return 'Enter a valid amount';
																		}
																		return null;
																	},
																),
																const SizedBox(height: 16),
																DropdownButtonFormField<String>(
																	value: _selectedCategoryId,
																	decoration: InputDecoration(
																		labelText: 'Category',
																		filled: true,
																		fillColor: AppColors.surface.withOpacity(0.5),
																		border: OutlineInputBorder(
																			borderRadius: BorderRadius.circular(12),
																			borderSide: BorderSide.none,
																		),
																		contentPadding: const EdgeInsets.symmetric(
																				horizontal: 16, vertical: 12),
																	),
																	items: widget.categories
																			.map(
																				(category) => DropdownMenuItem<String>(
																					value: category.id,
																					child: Text(category.name),
																				),
																			)
																			.toList(),
																	onChanged: (value) {
																		setState(() {
																			_selectedCategoryId = value;
																		});
																	},
																	validator: (value) {
																		if (value == null || value.isEmpty) {
																			return 'Category is required';
																		}
																		return null;
																	},
																),
																const SizedBox(height: 16),
																TextFormField(
																	controller: _noteController,
																	maxLines: 3,
																	decoration: InputDecoration(
																		labelText: 'Note (optional)',
																		hintText: 'Add a note...',
																		filled: true,
																		fillColor: AppColors.surface.withOpacity(0.5),
																		border: OutlineInputBorder(
																			borderRadius: BorderRadius.circular(12),
																			borderSide: BorderSide.none,
																		),
																		contentPadding: const EdgeInsets.symmetric(
																				horizontal: 16, vertical: 12),
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
																								width: 2),
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
																				onTap: _isUploadingReceipt ? null : _submit,
																				child: Container(
																					padding:
																							const EdgeInsets.symmetric(vertical: 14),
																					decoration: BoxDecoration(
																						gradient: AppColors.emeraldGradient,
																						borderRadius: BorderRadius.circular(12),
																					),
																					child: const Text(
																						'Add',
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

	void _submit() async {
		if (!_formKey.currentState!.validate()) return;

		String? receiptUrl;
		if (_receiptImage != null) {
			setState(() {
				_isUploadingReceipt = true;
			});

			try {
				receiptUrl = await _uploadReceiptImage(_receiptImage!);
			} catch (e) {
				if (mounted) {
					setState(() {
						_isUploadingReceipt = false;
					});
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text('Failed to upload receipt: $e'),
							backgroundColor: AppColors.error,
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

		final amount = double.parse(_amountController.text.trim());
		context.read<GroupBloc>().add(
				AddGroupExpense(
					groupId: widget.groupId,
					amount: amount,
					categoryId: _selectedCategoryId!,
					note: _noteController.text.trim().isEmpty
							? null
							: _noteController.text.trim(),
					imageProof: receiptUrl,
				),
			);
		Navigator.pop(context);
	}
}
