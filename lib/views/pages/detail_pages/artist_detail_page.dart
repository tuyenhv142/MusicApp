import 'dart:ui';

import 'package:app/models/track_model.dart';
import 'package:app/view_models/singer_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../../view_models/track_provide.dart';
import '../../../view_models/user_provider.dart';

class ArtistDetailPage extends StatefulWidget {
  const ArtistDetailPage({super.key});

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

UserProvider userProvider = UserProvider();
TrackProvider trackProvider = TrackProvider();
SingerProvider singerProvider = SingerProvider();

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  // bool _isLoaded = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await singerProvider.getCurrentSinger();
    // setState(() {
    //   _isLoaded = true;
    // });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    singerProvider = Provider.of<SingerProvider>(context);
    trackProvider = Provider.of<TrackProvider>(context);
    final singer = singerProvider.getCurrentSinger();
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Artist Detail",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<Track>>(
        future: trackProvider.getTracksBySingerId(singer?.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
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
          final List<Track> tracks = snapshot.data!;
          bool isFavorite = userProvider.isFavoriteArtist(singer?.id);
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRect(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Image.network(
                            singer!.img,
                            width: double.maxFinite,
                            height: media.width * 0.5,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black54,
                        width: double.maxFinite,
                        height: media.width * 0.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  singer.img,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      singer.name,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'id: ${singer.id}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.74),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      "${tracks.length} Songs",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.74),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ],
                                ))
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(17.5),
                                  onTap: () {
                                    final userProvider =
                                        Provider.of<UserProvider>(context,
                                            listen: false);
                                    final Track randomTrack = tracks[0];
                                    userProvider.setCurrentTrackId(
                                        randomTrack.id ?? "");
                                    userProvider.notifyTrackListChanged(tracks);
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                      // gradient: LinearGradient(
                                      //     colors: [
                                      //       Colors.white,
                                      //       Colors.red
                                      //     ],
                                      //     begin: Alignment.topCenter,
                                      //     end: Alignment.center),
                                      borderRadius: BorderRadius.circular(17.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/play_n.png',
                                          width: 15,
                                          height: 15,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        const Text(
                                          "Play",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(17.5),
                                  onTap: () {
                                    if (isFavorite) {
                                      userProvider
                                          .removeFavoriteArtistId(singer.id);
                                      Fluttertoast.showToast(
                                        msg:
                                            'Remove favorite artist successfully!',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                      );
                                    } else {
                                      userProvider
                                          .addFavoriteArtistId(singer.id);
                                      Fluttertoast.showToast(
                                        msg:
                                            'Add favorite artist successfully!',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(17.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/fav.png',
                                          width: 15,
                                          height: 15,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          isFavorite
                                              ? "Remove from Favorites"
                                              : "Add to Favorite",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "Songs",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            track.image,
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          track.title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.play_circle),
                        onTap: () {
                          final trackId = track.id ?? "";
                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          userProvider.setCurrentTrackId(trackId);
                          userProvider.notifyTrackListChanged(tracks);
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          );
          // }
        },
      ),
    );
  }
}
