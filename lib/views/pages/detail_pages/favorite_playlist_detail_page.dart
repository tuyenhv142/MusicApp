import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../../../models/playList_model.dart';
import '../../../models/track_model.dart';
import '../../../view_models/track_provide.dart';
import '../../../view_models/user_provider.dart';
import '../myhome_page.dart';

class FavoritePlaylistDetailPage extends StatefulWidget {
  const FavoritePlaylistDetailPage({super.key});

  @override
  State<FavoritePlaylistDetailPage> createState() =>
      _FavoritePlaylistDetailPageState();
}

UserProvider userProvider = UserProvider();
TrackProvider trackProvider = TrackProvider();

class _FavoritePlaylistDetailPageState
    extends State<FavoritePlaylistDetailPage> {
  PlayList? playlist;
  late String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print("Loading data..."); // Diagnostic log
    final loadedPlaylist = await userProvider.getCurrentFavoritePlaylist();
    if (mounted && loadedPlaylist != null) {
      setState(() {
        playlist = loadedPlaylist;
        print("Playlist loaded: ${playlist?.name}"); // Diagnostic log
      });
    }
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
                  Fluttertoast.showToast(
                    msg: 'Playlist renamed successfully!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  );
                  Navigator.pop(context);
                  await _loadData();
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final playlist = userProvider.getCurrentFavoritePlaylist();
    if (playlist == null) {
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                        playlist.img.isNotEmpty
                            ? playlist.img
                            : "https://i.pinimg.com/564x/01/37/d7/0137d782153a7a446e79c404d43fcc33.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          playlist.dateEnter,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Rename'),
              onTap: () {
                String? playlistId = playlist.id;
                Navigator.pop(context);
                _showRenameDialog(context, playlistId!, playlist.name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete playlist'),
              onTap: () async {
                await userProvider.deletePlaylist(
                    userProvider.currentUser.idUser, playlist.id);
                Fluttertoast.showToast(
                  msg: 'Delete to Library successfully!',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                );
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 50,
            )
          ],
        );
      },
    );
  }

  final picker = ImagePicker();

  Future<String> _uploadImage({required File? image}) async {
    String urlImage = '';

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String idUser = user.uid;
      Reference storageReference = FirebaseStorage.instance.ref().child(
          "UserPlaylistImage/$idUser/${DateTime.now().millisecondsSinceEpoch}.jpg");

      UploadTask uploadTask = storageReference.putFile(image!);
      await uploadTask.whenComplete(() => null);

      urlImage = await storageReference.getDownloadURL();

      await Provider.of<UserProvider>(context, listen: false)
          .updatePlaylistImage(playlist?.id, urlImage);
      setState(() {
        _imageUrl = urlImage;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        ),
      );
    }

    return urlImage;
  }

  File? _pickedImage;

  Future<void> getImage({required ImageSource source}) async {
    XFile? imageFile = await picker.pickImage(source: source);
    if (imageFile != null) {
      File pickedImageFile = File(imageFile.path);
      setState(() {
        _pickedImage = pickedImageFile;
      });

      String downloadUrl = await _uploadImage(image: _pickedImage);
      await Provider.of<UserProvider>(context, listen: false)
          .updatePlaylistImage(playlist?.id, downloadUrl);
      setState(() {
        _imageUrl = downloadUrl;
      });
    }
  }

  Future<void> myDialogBox(context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Pick Form Camera"),
                  onTap: () {
                    getImage(source: ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Pick Form Gallery"),
                  onTap: () {
                    getImage(source: ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    final trackProvider = Provider.of<TrackProvider>(context);
    // playlist = userProvider.currentFavoritePlaylist!;
    List<String>? trackListId = playlist?.tracks;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              _showModalBottomSheet(context);
            },
          ),
        ],
      ),
      body: playlist == null
          ? Center(
              child: LoadingAnimationWidget.inkDrop(
                color: Colors.blue,
                size: 50.0,
              ),
            )
          : FutureBuilder<List<Track>>(
              future: trackProvider.getTracksByIdList(trackListId!),
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
                List<Track> tracks = snapshot.data!;
                return Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Image.network(
                                      playlist!.img,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        myDialogBox(context);
                                      },
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: Colors.black,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    playlist!.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${tracks.length} Songs',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge!,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      final userProvider =
                                          Provider.of<UserProvider>(context,
                                              listen: false);
                                      final Track randomTrack = tracks[0];
                                      userProvider.setCurrentTrackId(
                                          randomTrack.id ?? "");
                                      userProvider
                                          .notifyTrackListChanged(tracks);
                                    },
                                    child: Container(
                                      width: 140,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Play All",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      final random = Random();
                                      final userProvider =
                                          Provider.of<UserProvider>(context,
                                              listen: false);
                                      final int index =
                                          random.nextInt(tracks.length);
                                      final Track randomTrack = tracks[index];
                                      userProvider.setCurrentTrackId(
                                          randomTrack.id ?? "");
                                      userProvider
                                          .notifyTrackListChanged(tracks);
                                    },
                                    child: Container(
                                      width: 140,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xB7DEDFF6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Shuffle",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Icon(
                                            Icons.shuffle,
                                            color: Colors.black,
                                            size: 15,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              playlist!.content.isNotEmpty
                                  ? Text(playlist!.content)
                                  : SizedBox.shrink(),
                              SizedBox(
                                height: 10,
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
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  track.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(track.singerId),
                                trailing: SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: PopupMenuButton<int>(
                                    color: Colors.grey,
                                    offset: const Offset(-10, 15),
                                    elevation: 1,
                                    onSelected: (value) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Confirm"),
                                            content: const Text(
                                              "Are you sure you want to delete this track from the playlist?",
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  final trackId =
                                                      track.id ?? "";
                                                  final playlistId =
                                                      playlist?.id ?? "";
                                                  await Provider.of<
                                                              UserProvider>(
                                                          context,
                                                          listen: false)
                                                      .removeTrackFromPlaylist(
                                                          playlistId, trackId);
                                                  await _loadData();
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
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
                                            "Remove this track",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                                onTap: () {
                                  final userProvider =
                                      Provider.of<UserProvider>(context,
                                          listen: false);
                                  final trackId = track.id ?? "";
                                  userProvider.setCurrentTrackId(trackId);
                                  userProvider.notifyTrackListChanged(tracks);
                                },
                              );
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
