import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/models/category_blog.dart';
import 'package:franchisemarketturkiye/views/blog/blog_detail_view.dart';
import 'package:franchisemarketturkiye/views/category/category_detail_view.dart';
import 'package:franchisemarketturkiye/views/home/tag_badge.dart';

class CategoryBlogSection extends StatelessWidget {
  final CategoryBlog categoryBlog;

  const CategoryBlogSection({super.key, required this.categoryBlog});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${categoryBlog.categoryName} ',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: 'Yazılarımız',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (MediaQuery.of(context).size.width >= 600)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryBlog.blogs.take(2).map((blog) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: categoryBlog.blogs.indexOf(blog) == 0 ? 0 : 8,
                  ),
                  child: _CategoryBlogItem(blog: blog),
                ),
              );
            }).toList(),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoryBlog.blogs.length > 2
                ? 2
                : categoryBlog.blogs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final blog = categoryBlog.blogs[index];
              return _CategoryBlogItem(blog: blog);
            },
          ),
        if (categoryBlog.blogs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 200,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailView(
                        categoryId: categoryBlog.categoryId,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF4F4F4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  'Daha Fazla Göster',
                  style: TextStyle(
                    color: Color.fromRGBO(160, 160, 160, 1),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    height: 16 / 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _CategoryBlogItem extends StatelessWidget {
  final Blog blog;

  const _CategoryBlogItem({required this.blog});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlogDetailView(blogId: blog.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  blog.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tags
            Row(
              children: [
                if (blog.category != null && blog.category!.name != null) ...[
                  TagBadge(text: blog.category!.name!.toUpperCase()),
                  const SizedBox(width: 8),
                ],
                TagBadge(text: (blog.type.name ?? '').toUpperCase()),
              ],
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              blog.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Author Row
            Row(
              children: [
                if (blog.author.imageUrl != null)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(blog.author.imageUrl!),
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.person, size: 24, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  blog.author.name ?? 'Yazar Bilgisi Yok',
                  style: textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Date
            Text(
              "${blog.dateAdded.day} ${_getMonthName(blog.dateAdded.month)} ${blog.dateAdded.year}",
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              _stripHtml(blog.description),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _stripHtml(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }
}
