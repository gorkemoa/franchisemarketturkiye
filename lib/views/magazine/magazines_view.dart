import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/magazine.dart';
import 'package:franchisemarketturkiye/viewmodels/magazines_view_model.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';
import 'package:franchisemarketturkiye/views/magazine/magazine_detail_view.dart';
import 'package:intl/intl.dart';

class MagazinesView extends StatefulWidget {
  final MagazinesViewModel viewModel;

  const MagazinesView({super.key, required this.viewModel});

  @override
  State<MagazinesView> createState() => _MagazinesViewState();
}

class _MagazinesViewState extends State<MagazinesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.magazines.isEmpty) {
        widget.viewModel.fetchMagazines();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalScaffold(
      showBackButton: true,
      selectedDrawerItem: 'magazines',
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading &&
              widget.viewModel.magazines.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (widget.viewModel.errorMessage != null &&
              widget.viewModel.magazines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(34.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
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
                          widget.viewModel.fetchMagazines(isRefresh: true),
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
            onRefresh: () => widget.viewModel.fetchMagazines(isRefresh: true),
            color: AppTheme.primaryColor,
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 2),
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width >= 600
                          ? 4
                          : 2,
                      childAspectRatio: MediaQuery.of(context).size.width >= 600
                          ? 0.65
                          : 0.6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount:
                        widget.viewModel.magazines.length +
                        (widget.viewModel.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == widget.viewModel.magazines.length) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                            strokeWidth: 2,
                          ),
                        );
                      }

                      final magazine = widget.viewModel.magazines[index];
                      return _MagazineCard(magazine: magazine);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'FRANCHISE MARKET',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                    fontFamily: 'BioSans',
                  ),
                ),
                TextSpan(
                  text: ' DERGİLERİ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black, // Assuming black based on other views
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
}

class _MagazineCard extends StatelessWidget {
  final Magazine magazine;

  const _MagazineCard({required this.magazine});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MagazineDetailView(magazineId: magazine.id),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  magazine.imageUrl,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Title
        Text(
          magazine.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'BioSans',
          ),
        ),
        const SizedBox(height: 4),
        // Date
        Text(
          DateFormat('d MMMM yyyy', 'tr_TR').format(magazine.dateAdded),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
