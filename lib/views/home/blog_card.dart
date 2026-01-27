import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/views/blog/blog_detail_view.dart';
import 'package:franchisemarketturkiye/views/home/tag_badge.dart';

class BlogCard extends StatelessWidget {
  final Blog blog;

  const BlogCard({super.key, required this.blog});

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
          color: AppTheme.cardColor,
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ClipRRect(
                child: Image.network(
                  blog.imageUrl,
                  height: 155,
                  width: double.infinity,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
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
                      TagBadge(text: blog.type.name ?? ''),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    blog.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  // Author row
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
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.person, size: 24, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        blog.author.name ?? 'Yazar Bilgisi Yok',
                        style: textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Date
                  Text(
                    "${blog.dateAdded.day} ${_getMonthMap()[blog.dateAdded.month]} ${blog.dateAdded.year}",
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
          ],
        ),
      ),
    );
  }

  String _stripHtml(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
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
