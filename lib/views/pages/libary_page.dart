
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';

import '../../view_models/user_provider.dart';

import 'favorite_pages/favorite_artist_page.dart';
import 'detail_pages/favorite_playlist_detail_page.dart';
import 'favorite_pages/favorite_playlist_page.dart';
import 'favorite_pages/favorite_song_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<List<Map<String, dynamic>>> playlistsFuture;
  late UserProvider userProvider;
  TextEditingController playlistNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _reloadPlaylists();
    playlistsFuture =
        userProvider.getPlaylistDataList(userProvider.currentUser.idUser);
  }

  Future<void> _reloadPlaylists() async {
    await Provider.of<UserProvider>(context, listen: false)
        .getCurrentFavoritePlaylist();
    playlistsFuture =
        userProvider.getPlaylistDataList(userProvider.currentUser.idUser);
    setState(() {});
  }

  void _showDeletePlaylistDialog(BuildContext context, String playlistId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this playlist?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await userProvider.deletePlaylist(
                    userProvider.currentUser.idUser, playlistId);
                _reloadPlaylists();
                setState(() {});
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: 'Playlist deleted successfully!',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameDialog(
      BuildContext context, String playlistId, String currentName) {
    TextEditingController _controller =
        TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Playlist'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'New name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newName = _controller.text.trim();
                if (newName.isNotEmpty) {
                  await Provider.of<UserProvider>(context, listen: false)
                      .renamePlaylist(playlistId, newName);
                  _reloadPlaylists();
                  setState(() {});
                  Fluttertoast.showToast(
                    msg: 'Playlist renamed successfully!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    TextEditingController playlistNameController = TextEditingController();
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
                    bool duplicate = await Provider.of<UserProvider>(context,
                            listen: false)
                        .checkDuplicatePlaylist(
                            Provider.of<UserProvider>(context, listen: false)
                                .currentUser
                                .idUser,
                            playlistName);
                    if (!duplicate) {
                      await Provider.of<UserProvider>(context, listen: false)
                          .createPlaylist(
                              Provider.of<UserProvider>(context, listen: false)
                                  .currentUser
                                  .idUser,
                              playlistName);
                      await _reloadPlaylists();
                      setState(() {});
                      Navigator.of(context).pop();
                      playlistNameController.clear();
                      Fluttertoast.showToast(
                        msg: 'Playlist created successfully!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    } else {
                      setState(() {
                        isDuplicate = true;
                      });
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
    String? userId = userProvider.getCurrentUser.idUser;
    List<String>? totalFavoriteTracks =
        userId != null ? userProvider.getFavoriteTrackIds(userId) : [];
    List<String>? totalFavoriteArtists =
        userId != null ? userProvider.getFavoriteArtistIds(userId) : [];
    List<String>? totalFavoritePlaylists =
        userId != null ? userProvider.getFavoritePlaylistIds(userId) : [];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 125,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                String title;
                String subtitle;
                IconData icon;
                Color iconColor;

                switch (index) {
                  case 0:
                    title = 'Favorite Songs';
                    subtitle = '${totalFavoriteTracks?.length}';
                    icon = Icons.favorite_outline;
                    iconColor = Colors.blue;
                    break;
                  case 1:
                    title = 'Artists';
                    subtitle = '${totalFavoriteArtists?.length}';
                    icon = Icons.account_circle_outlined;
                    iconColor = Colors.purple;
                    break;
                  case 2:
                    title = 'Playlists';
                    subtitle = '${totalFavoritePlaylists?.length}';
                    icon = Icons.playlist_add_check_circle_outlined;
                    iconColor = Colors.deepOrange;
                    break;
                  default:
                    title = '';
                    subtitle = '';
                    icon = Icons.error_outline;
                    iconColor = Colors.black;
                }

                return GestureDetector(
                  onTap: () {
                    switch (index) {
                      case 0:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritePage(),
                          ),
                        );
                        break;
                      case 1:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoriteArtistPage(),
                          ),
                        );
                        break;
                      case 2:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoritePlaylistPage(),
                          ),
                        );
                        break;
                      default:
                        break;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 135,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.black.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              icon,
                              size: 35,
                              color: iconColor,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18.0, 18.0, 0, 0),
            child: Text(
              'Playlist',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 5.0, 0, 0),
            child: GestureDetector(
              onTap: () {
                _showCreatePlaylistDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        "Create a Playlist",
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 5.0, 0, 0),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: playlistsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final playlists = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        return GestureDetector(
                          onTap: () async {
                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            final playlistId = playlist['id'];
                            print("id click $playlistId");
                            await userProvider.setCurrentFavoritePlaylist(playlistId);
                            print("id ${userProvider.currentFavoritePlaylist}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FavoritePlaylistDetailPage(),
                              ),
                            );
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 8.0, 8.0, 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(

                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.4),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      playlist['img'],
                                      // (playlist['img'] != null && playlist['img'] != "")
                                      //     ? playlist['img']
                                      //     : "https://i.pinimg.com/564x/01/37/d7/0137d782153a7a446e79c404d43fcc33.jpg",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playlist['name'],
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        playlist["dateEnter"],
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
                                    offset: const Offset(-10, 15),
                                    elevation: 1,
                                    onSelected: (value) {
                                      if (value == 2) {
                                        _showDeletePlaylistDialog(
                                            context, playlist['id']);
                                      } else {
                                        _showRenameDialog(context,
                                            playlist['id'], playlist['name']);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: Colors.black,
                                    ),
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context) {
                                      return [
                                        const PopupMenuItem(
                                          value: 1,
                                          height: 30,
                                          child: Text(
                                            "Rename",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 2,
                                          height: 30,
                                          child: Text(
                                            "Delete",
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
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
