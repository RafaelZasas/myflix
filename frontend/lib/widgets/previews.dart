import "package:flutter/material.dart";
import "package:myflix/models/models.dart";
import "package:myflix/widgets/responsive.dart";

class Previews extends StatelessWidget {
  final String title;
  final List<Content> contentList;

  const Previews({super.key, required this.title, required this.contentList});

  @override
  Widget build(BuildContext context) {
    double boxHeight = 165.0;
    double containerHeight = 250.0;
    double containerWidth = 100.0;

    if (!Responsive.isMobile(context)) {
      boxHeight = 215.0;
      containerHeight = 300.0;
      containerWidth = 150.0;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: boxHeight,
          child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                final Content content = contentList[index];

                return GestureDetector(
                  onTap: () => print(content.title),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        height: containerHeight,
                        width: containerWidth,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(content.poster),
                              fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: contentList.length),
        )
      ],
    );
  }
}
