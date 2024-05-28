import 'package:app/models/singer_model.dart';
import 'package:app/view_models/singer_provider.dart';
import 'package:app/view_models/track_provide.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


import '../../../view_models/user_provider.dart';
import '../detail_pages/artist_detail_page.dart';

class ArtistViewAll extends StatefulWidget {
  const ArtistViewAll({super.key});

  @override
  State<ArtistViewAll> createState() => _ArtistViewAllState();
}

class _ArtistViewAllState extends State<ArtistViewAll> {
  @override
  Widget build(BuildContext context) {
    final singerProvider = Provider.of<SingerProvider>(context);
    final trackProvider = Provider.of<TrackProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    List<Singer> listSinger = singerProvider.getListSinger;

    void handlePopupMenuSelection(int value, singerId) {
      switch (value) {
        case 1:
          bool isFavorite = userProvider.isFavoriteArtist(singerId);
          if (isFavorite) {
            userProvider.removeFavoriteArtistId(singerId);
          } else {
            userProvider.addFavoriteArtistId(singerId);
          }
          break;
        case 2:
          singerProvider.singerDetail(singerId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ArtistDetailPage(),
            ),
          );
          break;
        default:
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Artist'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        itemCount: listSinger.length,
        itemBuilder: (context, index) {
          var singer = listSinger[index];
          return FutureBuilder<int>(
            future: trackProvider.getTrackCountBySingerId(singer.id),
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return Stack(
              //     children: [
              //       Positioned.fill(
              //         child: Center(
              //           child: LoadingAnimationWidget.beat(
              //             color: Colors.black,
              //             size: 50,
              //           ),
              //         ),
              //       ),
              //     ],
              //   );
              // }
              if (snapshot.hasError) {
                return const Text('Error loading track count');
              }
              var trackCount = snapshot.data ?? 0;
              return GestureDetector(
                onTap: () {
                  final singerId = singer.id;
                  singerProvider.singerDetail(singerId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArtistDetailPage(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRect(
                            child: Image.network(
                              singer.img,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              singer.name,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "$trackCount Songs",
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 25,
                        height: 25,
                        child: PopupMenuButton<int>(
                          color: Colors.grey,
                          offset: Offset(-10, 15),
                          elevation: 1,
                          onSelected: (value) {
                            handlePopupMenuSelection(value, singer.id);
                          },
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context) {
                            bool isFavorite =
                                userProvider.isFavoriteArtist(singer.id);
                            return [
                              PopupMenuItem(
                                value: 1,
                                height: 30,
                                child: Text(
                                  isFavorite
                                      ? "Remove from Favorites"
                                      : "Add to Favorite",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 2,
                                height: 30,
                                child: Text(
                                  "Detail",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
