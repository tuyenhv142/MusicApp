import 'package:app/models/playList_model.dart';
import 'package:app/views/pages/account_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../view_models/playList_provider.dart';
import '../../../view_models/user_provider.dart';
import '../detail_pages/playlist_detail_page.dart';

class PlaylistViewAll extends StatefulWidget {
  const PlaylistViewAll({super.key});

  @override
  State<PlaylistViewAll> createState() => _PlaylistViewAllState();
}

class _PlaylistViewAllState extends State<PlaylistViewAll> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo(context);
  }

  Future<void> loadUserInfo(BuildContext context) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .getDocCurrentUser(userProvider.currentUser.idUser);
      if (mounted) {
        await Provider.of<PlayListProvider>(context, listen: false)
            .getPlayListData();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playListProvider = Provider.of<PlayListProvider>(context);
    final List<PlayList> listPlayList = playListProvider.getListPlayList;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Playlist"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                itemCount: (listPlayList.length / 2).ceil(),
                itemBuilder: (context, index) {
                  final firstIndex = index * 2;
                  final secondIndex = firstIndex + 1;
                  return Row(
                    children: [
                      if (firstIndex < listPlayList.length)
                        Expanded(
                          child: PlaylistItem(
                            playlist: listPlayList[firstIndex],
                          ),
                        ),
                      const SizedBox(width: 10),
                      if (secondIndex < listPlayList.length)
                        Expanded(
                          child: PlaylistItem(
                            playlist: listPlayList[secondIndex],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

class PlaylistItem extends StatelessWidget {
  final PlayList playlist;

  const PlaylistItem({
    required this.playlist,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playlistProvider =
        Provider.of<PlayListProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        final playlistId = playlist.id;
        playlistProvider.playlistDetail(playlistId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlaylistPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: FadeInImage(
                image: NetworkImage(playlist.img),
                height: 170,
                width: 150,
                placeholder: const AssetImage("assets/icons/spinner100.gif"),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            // Playlist name
            Text(
              playlist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Playlist date
            Text(
              playlist.dateEnter,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
