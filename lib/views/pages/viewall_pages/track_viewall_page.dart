import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../models/track_model.dart';
import '../../../view_models/track_provide.dart';
import '../../../view_models/user_provider.dart';



class TrackViewAll extends StatefulWidget {
  const TrackViewAll({super.key});

  @override
  State<TrackViewAll> createState() => _TrackViewAllState();
}

class _TrackViewAllState extends State<TrackViewAll> {
  @override
  Widget build(BuildContext context) {
    final trackProvider = Provider.of<TrackProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    List<Track> listTrack = trackProvider.getListTrack;

    TextEditingController playlistNameController = TextEditingController();

    void showCreatePlaylistDialog(BuildContext context) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
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
                      decoration: const InputDecoration(
                        hintText: 'Enter playlist name',
                      ),
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
                          userProvider.currentUser.idUser, playlistName);
                      if (!isDuplicate) {
                        await userProvider.createPlaylist(
                            userProvider.currentUser.idUser, playlistName);
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


    Future<void> handlePopupMenuSelection(int value, trackId) async {
      switch (value) {
        case 1:
          bool isFavorite = userProvider.isFavoriteTrack(trackId);
          if (isFavorite) {
            userProvider.removeFavoriteTrackId(trackId);
          } else {
            userProvider.addFavoriteTrackId(trackId);
          }
          break;
        case 2:
          final userProvider =
          Provider.of<UserProvider>(context, listen: false);
          List<Map<String, dynamic>> playlists = await userProvider
              .getPlaylistDataList(userProvider.currentUser.idUser);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add to Playlist'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (playlists.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = playlists[index];
                            return ListTile(
                              title: Text(playlist['name']),
                              onTap: () async {
                                String? playlistId =
                                await userProvider.getPlaylistIdAtIndex(
                                    userProvider.currentUser.idUser, index);
                                userProvider.addToPlaylist(
                                    playlistId!, trackId);
                                Fluttertoast.showToast(
                                  msg: 'Song added to playlist successfully!',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                );
                                Navigator.pop(context);
                              },
                            );
                          },
                        )
                      else
                        const Text('No playlists available'),
                      ElevatedButton(
                        onPressed: () {
                          showCreatePlaylistDialog(context);
                        },
                        child: const Text('Create Playlist'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );
          break;
        default:
          break;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Songs'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: listTrack.length,
        itemBuilder: (context, index) {
          final Track track = listTrack[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(track.image),
            ),
            title: Text(track.title),
            subtitle: Text(track.singerId),
            onTap: () {
              final trackId = track.id ?? "";
              userProvider.setCurrentTrackId(trackId);
              userProvider.notifyTrackListChanged(listTrack);
            },
            trailing: SizedBox(
              width: 25,
              height: 25,
              child: PopupMenuButton<int>(
                color: Colors.grey,
                offset: const Offset(-10, 15),
                elevation: 1,
                onSelected: (value) {
                  handlePopupMenuSelection(value, track.id);
                },
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                ),
                padding: EdgeInsets.zero,
                itemBuilder: (context) {
                  bool isFavorite = userProvider.isFavoriteTrack(track.id);
                  return [
                    PopupMenuItem(
                      value: 1,
                      height: 30,
                      child: Text(
                        isFavorite
                            ? "Remove from Favorites"
                            : "Add to Favorite",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      height: 30,
                      child: Text(
                        "Add to Playlist",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ];
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
