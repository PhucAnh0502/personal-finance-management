import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/group_bloc/group_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/core/theme/app_theme.dart';
import 'package:pmf_app/core/utils/format_helper.dart';
import 'package:pmf_app/data/models/group_model.dart';
import 'package:pmf_app/presentation/shared/neumorphic_container.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {

  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(FetchGroups());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            onPressed: () =>
                                context.read<GroupBloc>().add(FetchGroups()),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is GroupLoaded) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Groups',
                              style: AppTheme.getTitleStyle(context).copyWith(
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildGroupList(state.groups),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupModal,
        backgroundColor: AppColors.primaryEmerald,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGroupList(List<GroupModel> groups) {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.groups_outlined,
              size: 60,
              color: AppColors.primaryEmerald.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No groups yet',
              style: TextStyle(
                color: AppTheme.getSubtitleStyle(context).color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: groups.map(_buildGroupCard).toList(),
    );
  }

  Widget _buildGroupCard(GroupModel group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicContainer(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupDetailScreen(group: group),
              ),
            ).then((_) => context.read<GroupBloc>().add(FetchGroups()));
          },
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
                  Icons.group,
                  color: AppColors.primaryEmerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total fund: ${FormatHelper.formatCurrencyWithSymbol(group.totalFund, symbol: ' VND')}',
                      style: TextStyle(
                        color: AppTheme.getSubtitleStyle(context).color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateGroupModal() {
    final nameController = TextEditingController();
    final fundController = TextEditingController();
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
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create Group',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Group name',
                        hintText: 'e.g. Trip Fund',
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
                          return 'Group name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: fundController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Total fund',
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.primaryEmerald, width: 2),
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
                                final totalFund =
                                    double.parse(fundController.text.trim());
                                context.read<GroupBloc>().add(
                                      CreateGroup(
                                        nameController.text.trim(),
                                        totalFund,
                                      ),
                                    );
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
          ),
        );
      },
    );
  }
}
