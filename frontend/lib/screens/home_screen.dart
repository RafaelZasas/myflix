import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/material.dart";
import "package:myflix/cubits/cubits.dart";
import "package:myflix/models/models.dart";
import "package:myflix/widgets/widgets.dart";
import "package:myflix/server/server.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Database db = Database();
  late ScrollController _scrollController;

  late Future<List<Content>> oldies;
  late Future<Content> featuredContent;
  late Future<List<Content>> previews;
  late Future<List<Content>> criticallyAcclaimed;

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() {
        BlocProvider.of<AppBarCubit>(context)
            .setOffset(_scrollController.offset);
      });
    super.initState();

    oldies = db.fetchOldies();
    featuredContent = db.fetchFeaturedContent();
    previews = db.fetchPreviews();
    criticallyAcclaimed = db.fetchCriticallyAclaimed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[850],
        child: const Icon(Icons.cast),
        onPressed: () => print("cast"),
      ),
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 50.0),
        child: BlocBuilder<AppBarCubit, double>(
          builder: (context, scrollOffset) {
            return CustomAppBar(scrollOffset: scrollOffset);
          },
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          HeaderRow(future: featuredContent),
          PreviewsRow(future: previews),
          ContentRow(future: oldies, title: "Golden oldies"),
          ContentRow(
              future: criticallyAcclaimed, title: "Critically Acclaimed"),
          ContentRow(future: previews, title: "My List"),
        ],
      ),
    );
  }
}

class HeaderRow extends StatelessWidget {
  final Future<Content> future;
  const HeaderRow({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      // child: ContentHeader(featuredContent: sintelContent))
      child: FutureBuilder<Content>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ContentHeader(featuredContent: snapshot.data!);
          } else if (snapshot.hasError) {
            return const Text("Error");
          }
          return Container(height: 500, color: Colors.black);
        },
      ),
    );
  }
}

class PreviewsRow extends StatelessWidget {
  final Future<List<Content>> future;
  const PreviewsRow({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 20.0),
      sliver: SliverToBoxAdapter(
        child: FutureBuilder<List<Content>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Previews(
                  title: "previews",
                  contentList: snapshot.data!,
                  key: const PageStorageKey(
                    "previews",
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Error fetching movie",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              return Container(height: 500, color: Colors.black);
            }),
      ),
    );
  }
}

class ContentRow extends StatelessWidget {
  final Future future;
  final String title;

  const ContentRow({super.key, required this.future, required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ContentList(
              key: PageStorageKey(title),
              title: title,
              contentList: snapshot.data!,
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error fetching movie",
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          return Container(height: 500, color: Colors.black);
        },
      ),
    );
  }
}
