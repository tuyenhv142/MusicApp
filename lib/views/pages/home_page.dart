import 'package:app/views/pages/viewall_pages/artist_viewall_page.dart';
import 'package:app/views/pages/search_pages.dart';
import 'package:app/views/pages/viewall_pages/playlist_viewall_page.dart';
import 'package:app/views/pages/viewall_pages/track_viewall_page.dart';
import 'package:app/view_models/singer_provider.dart';
import 'package:app/view_models/track_provide.dart';
import 'package:app/views/widgets/playlist_widget.dart';
import 'package:app/views/widgets/track_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../view_models/playList_provider.dart';
import '../../view_models/user_provider.dart';
import '../widgets/banner_widget.dart';
import '../widgets/navbar.dart';
import '../widgets/newrelease_widget.dart';
import '../widgets/singer_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  // bool _isLoading = false;
  TextEditingController playlistNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserInfo(context);
  }

  Future<void> loadUserInfo(BuildContext context) async {
    if (!mounted) return;
    // setState(() {
    //   _isLoading = true;
    // });
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .getDocCurrentUser(auth.currentUser!.uid);
      if (mounted) {
        await Provider.of<TrackProvider>(context, listen: false).getTrackData();
        await Provider.of<TrackProvider>(context, listen: false)
            .getNewReleaseData();
        await Provider.of<SingerProvider>(context, listen: false)
            .getSingerData();
        await Provider.of<PlayListProvider>(context, listen: false)
            .getPlayListData();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    } finally {
      if (mounted) {
        // setState(() {
        //   _isLoading = false;
        // });
      }
    }
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isDuplicate = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Create Playlist'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: playlistNameController,
                    decoration:
                        const InputDecoration(hintText: 'Enter playlist name'),
                  ),
                  if (isDuplicate)
                    const Text(
                      'Playlist name already exists. Please enter a different name.',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    String playlistName = playlistNameController.text;
                    isDuplicate = await userProvider.checkDuplicatePlaylist(
                        auth.currentUser!.uid, playlistName);
                    if (!isDuplicate) {
                      await userProvider.createPlaylist(
                          auth.currentUser!.uid, playlistName);
                      Fluttertoast.showToast(
                        msg: 'Playlist created successfully!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                      Navigator.of(context).pop();
                      playlistNameController.clear();
                    } else {
                      setState(() {});
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final singerProvider = Provider.of<SingerProvider>(context);
    final playListProvider = Provider.of<PlayListProvider>(context);
    final trackProvider = Provider.of<TrackProvider>(context);
    return Scaffold(
        drawer: const NavBar1(),
        appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showCreatePlaylistDialog(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerWidget(),
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Playlist",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: "SecularOne Regular",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaylistViewAll(),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'View all',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.black,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              getPlayList(context, playListProvider.getListPlayList),
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Suggestion for you",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: "SecularOne Regular",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackViewAll(),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'View all',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.black,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              getNewRelease(context, trackProvider.getListTrack),
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "New release",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: "SecularOne Regular",
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () {},
                    //   child: Row(
                    //     children: const [
                    //       Text(
                    //         'View all',
                    //         style: TextStyle(
                    //           color: Colors.black,
                    //           fontSize: 15,
                    //         ),
                    //       ),
                    //       Icon(
                    //         Icons.double_arrow_rounded,
                    //         color: Colors.black,
                    //         size: 15,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              getTrackList(context, trackProvider.getNewListTrack),
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Artist",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: "SecularOne Regular",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArtistViewAll(),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'View all',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.black,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              getSingerList(singerProvider.getListSinger),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ));
  }
}
