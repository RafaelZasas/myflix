import "package:flutter/material.dart";

import "package:myflix/models/models.dart";
import "package:myflix/widgets/responsive.dart";

class ContentList extends StatelessWidget {
  final String title;
  final List<Content> contentList;
  final bool isFeatured;

  const ContentList({
    super.key,
    required this.title,
    required this.contentList,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    double boxHeight = 220.0;
    double imageHeight = 200.0;
    double imageWidth = 130.0;

    if (!Responsive.isMobile(context)) {
      boxHeight = 300.0;
      imageHeight = 280.0;
      imageWidth = 210.0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: isFeatured ? 500.0 : boxHeight,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: contentList.length,
              itemBuilder: (BuildContext context, int index) {
                final Content content = contentList[index];
                return GestureDetector(
                  onTap: () => print(content.title),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    height: isFeatured ? 400.0 : imageHeight,
                    width: isFeatured ? 200.0 : imageWidth,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(content.poster),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
