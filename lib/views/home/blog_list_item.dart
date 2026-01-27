import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/views/blog/blog_detail_view.dart';
import 'package:franchisemarketturkiye/views/home/tag_badge.dart';

class BlogListItem extends StatelessWidget {
  final Blog blog;

  const BlogListItem({super.key, required this.blog});

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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              child: Image.network(
                blog.imageUrl,
                height: 100,
                width: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  width: 140,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Row(
                    children: [
                      if (blog.category != null &&
                          blog.category!.name != null) ...[
                        TagBadge(text: blog.category!.name!),
                        const SizedBox(width: 8),
                      ],
                      TagBadge(
                        text: blog.type.name ?? '',
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    blog.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Author & Date
                  Row(
                    children: [
                      if (blog.author.imageUrl != null)
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(blog.author.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        blog.author.name ?? 'Yazar Bilgisi Yok',
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 9,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${blog.dateAdded.day} ${_getMonthMap()[blog.dateAdded.month]}",
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, String> _getMonthMap() {
    return {
      1: "Ocak",
      2: "Şubat",
      3: "Mart",
      4: "Nisan",
      5: "Mayıs",
      6: "Haziran",
      7: "Temmuz",
      8: "Ağustos",
      9: "Eylül",
      10: "Ekim",
      11: "Kasım",
      12: "Aralık",
    };
  }
}
