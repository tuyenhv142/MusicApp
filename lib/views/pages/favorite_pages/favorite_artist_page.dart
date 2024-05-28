import 'package:app/models/singer_model.dart';
import 'package:app/view_models/singer_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';


import '../../../view_models/user_provider.dart';
import '../detail_pages/artist_detail_page.dart';

class FavoriteArtistPage extends StatefulWidget {
  const FavoriteArtistPage({super.key});

  @override
  State<FavoriteArtistPage> createState() => _FavoriteArtistPageState();
}

class _FavoriteArtistPageState extends State<FavoriteArtistPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final singerProvider = Provider.of<SingerProvider>(context);

    String? userId = userProvider.getCurrentUser.idUser;
    List<String>? favoriteArtistIds =
        userId != null ? userProvider.getFavoriteArtistIds(userId) : [];

    if (kDebugMode) {
      print(favoriteArtistIds);
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              // _showModalBottomSheet(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Singer>>(
        future: singerProvider.getArtistsByIdList(favoriteArtistIds!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: LoadingAnimationWidget.beat(
                      color: Colors.black,
                      size: 50,
                    ),
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          List<Singer> favoriteArtists = snapshot.data ?? [];

          return Column(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Artist",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${favoriteArtists.length} artist - Followed',
                        style: Theme.of(context).textTheme.bodyLarge!,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: favoriteArtists.length,
                  itemBuilder: (context, index) {
                    final Singer artist = favoriteArtists[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          artist.img,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        artist.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                  'Are you sure you want to remove this artist from favorites?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      userProvider.removeFavoriteArtistId(
                                          artist.id ?? "");
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      onTap: () {
                        final singerId = artist.id;
                        singerProvider.singerDetail(singerId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ArtistDetailPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
