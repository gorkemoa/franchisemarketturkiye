import 'dart:async';
import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/franchise.dart';
import 'package:franchisemarketturkiye/views/franchise/franchise_detail_view.dart';
import 'package:franchisemarketturkiye/viewmodels/franchises_view_model.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';

class FranchisesView extends StatefulWidget {
  final FranchisesViewModel viewModel;
  final bool isStandalone;

  const FranchisesView({
    super.key,
    required this.viewModel,
    this.isStandalone = true,
  });

  @override
  State<FranchisesView> createState() => _FranchisesViewState();
}

class _FranchisesViewState extends State<FranchisesView> {
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.viewModel.searchQuery,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.franchises.isEmpty) {
        widget.viewModel.fetchFranchises();
      }
      if (widget.viewModel.categories.isEmpty) {
        widget.viewModel.fetchCategories();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.viewModel.setSearchQuery(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.viewModel.loadMore();
    }
  }

  void _showFilterDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        if (widget.viewModel.isLoading && widget.viewModel.franchises.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (widget.viewModel.errorMessage != null &&
            widget.viewModel.franchises.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(34.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    widget.viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        widget.viewModel.fetchFranchises(isRefresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => widget.viewModel.fetchFranchises(isRefresh: true),
          color: AppTheme.primaryColor,
          child: Column(
            children: [
              _buildHeader(context),
              _buildSearchAndFilterRow(context),
              if (widget.viewModel.isSearching)
                const SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    color: AppTheme.primaryColor,
                    backgroundColor: Colors.transparent,
                  ),
                )
              else
                const SizedBox(height: 2),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount:
                      widget.viewModel.franchises.length +
                      (widget.viewModel.hasMore ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == widget.viewModel.franchises.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }

                    final franchise = widget.viewModel.franchises[index];
                    return _FranchiseCard(franchise: franchise);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (widget.isStandalone) {
      return GlobalScaffold(
        body: content,
        showBackButton: true,
        currentIndex: null,
        selectedDrawerItem: 'franchise_files',
        endDrawer: _FranchiseFilterDrawer(viewModel: widget.viewModel),
      );
    }
    return content;
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'FRANCHISE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                    fontFamily: 'BioSans',
                  ),
                ),
                TextSpan(
                  text: ' DOSYALARI',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    fontFamily: 'BioSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Franchise ara...',
                  hintStyle: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textTertiary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => _showFilterDrawer(context),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.viewModel.categoryId != null
                      ? AppTheme.primaryColor.withOpacity(0.05)
                      : Colors.white,
                  border: Border.all(
                    color: widget.viewModel.categoryId != null
                        ? AppTheme.primaryColor
                        : AppTheme.borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune,
                      color: widget.viewModel.categoryId != null
                          ? AppTheme.primaryColor
                          : AppTheme.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filtrele',
                      style: TextStyle(
                        color: widget.viewModel.categoryId != null
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FranchiseCard extends StatelessWidget {
  final Franchise franchise;

  const _FranchiseCard({required this.franchise});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FranchiseDetailView(franchiseId: franchise.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 246, 243, 243),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: ClipRRect(
                    child: Image.network(
                      franchise.logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.business,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        franchise.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        franchise.seo?.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          height: 1.3,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FranchiseFilterDrawer extends StatelessWidget {
  final FranchisesViewModel viewModel;

  const _FranchiseFilterDrawer({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(3),
          bottomLeft: Radius.circular(3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 45,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
            ),
            child: const Row(
              children: [
                Icon(Icons.tune, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text(
                  'KATEGORİLER',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BioSans',
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, child) {
                if (viewModel.isLoadingCategories) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildCategoryItem(context, null, 'Tümü'),
                    ..._buildHierarchicalCategories(context),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHierarchicalCategories(BuildContext context) {
    final List<Widget> items = [];
    final mainCategories = viewModel.categories
        .where((c) => c.parentId == 0)
        .toList();

    for (var parent in mainCategories) {
      final children = viewModel.categories
          .where((c) => c.parentId == parent.id)
          .toList();

      if (children.isEmpty) {
        items.add(_buildCategoryItem(context, parent.id, parent.title));
      } else {
        items.add(
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                parent.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: viewModel.categoryId == parent.id
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: viewModel.categoryId == parent.id
                      ? AppTheme.primaryColor
                      : AppTheme.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: EdgeInsets.zero,
              expandedAlignment: Alignment.centerLeft,
              children: [
                _buildCategoryItem(
                  context,
                  parent.id,
                  'Tüm ${parent.title}',
                  indent: 16,
                ),
                ...children.map(
                  (child) => _buildCategoryItem(
                    context,
                    child.id,
                    child.title,
                    indent: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return items;
  }

  Widget _buildCategoryItem(
    BuildContext context,
    int? id,
    String title, {
    double indent = 0,
  }) {
    final isSelected = viewModel.categoryId == id;
    return ListTile(
      contentPadding: EdgeInsets.only(left: 16 + indent, right: 16),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
          fontFamily: 'Inter',
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppTheme.primaryColor, size: 18)
          : null,
      onTap: () {
        viewModel.setCategoryId(id);
        Navigator.pop(context); // Close drawer
      },
    );
  }
}
