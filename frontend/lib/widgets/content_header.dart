import "package:flutter/material.dart";
import "package:myflix/widgets/widgets.dart";
import "../models/content_model.dart";

class ContentHeader extends StatelessWidget {
  final Content featuredContent;

  const ContentHeader({super.key, required this.featuredContent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 500.0,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(featuredContent.poster),
                  fit: BoxFit.cover)),
        ),
        Container(
          height: 500.0,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter)),
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 40.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                VerticalIconButton(
                    icon: Icons.add,
                    title: "List",
                    onTap: () => print("My List")),
                _PlayButton(),
                VerticalIconButton(
                    icon: Icons.info_outline,
                    title: "Info",
                    onTap: () => print("info"))
              ],
            ))
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => print("Play"),
        style: TextButton.styleFrom(
          minimumSize: const Size(10, 5),
          backgroundColor: Colors.white,
          padding: !Responsive.isDesktop(context)
              ? const EdgeInsets.fromLTRB(15.0, 5.0, 20.0, 5.0)
              : const EdgeInsets.fromLTRB(25.0, 10.0, 30.0, 10.0),
        ),
        child: Row(
          children: const [
            Icon(
              Icons.play_arrow,
              size: 30.0,
              color: Colors.black,
            ),
            Text(
              "Play",
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            )
          ],
        ));
  }
}
