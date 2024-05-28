import 'package:app/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:app/models/track_model.dart';
import 'package:provider/provider.dart';

Widget getTrackList(BuildContext context, List<Track> trackList) {
  return Consumer<UserProvider>(
    builder: (context, userProvider, _) {
      String? userId = userProvider.currentUser.idUser;
      List<String>? favoriteTrackIds = userProvider.getFavoriteTrackIds(userId);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 210,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: (trackList.length / 3).ceil(),
          itemBuilder: (context, columnIndex) {
            return SizedBox(
              width: 350,
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  int trackIndex = columnIndex * 3 + index;
                  if (trackIndex < trackList.length) {
                    return buildTrackCard(trackList[trackIndex], context,
                        userProvider, favoriteTrackIds, trackList);
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            );
          },
        ),
      );
    },
  );
}

Widget buildTrackCard(
    Track track,
    BuildContext context,
    UserProvider userProvider,
    List<String>? favoriteTrackIds,
    List<Track> trackList) {
  bool isFavorite = favoriteTrackIds?.contains(track.id ?? "") ?? false;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: FadeInImage(
                image: NetworkImage(track.image),
                height: 50,
                width: 50,
                placeholder: const AssetImage("assets/icons/spinner100.gif"),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            // Track title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // Track singer
                  Text(
                    track.singerId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // Play button
                IconButton(
                  onPressed: () {
                    // Provider.of<UserProvider>(context, listen: false);
                    final trackId = track.id ?? "";
                    userProvider.setCurrentTrackId(trackId);
                    userProvider.notifyTrackListChanged(trackList);
                    print("${trackId}");
                    print("${trackList.length}");
                  },
                  icon: const Icon(Icons.play_circle, color: Colors.black),
                ),
                IconButton(
                  onPressed: () {
                    if (isFavorite) {
                      userProvider.removeFavoriteTrackId(track.id ?? "");
                    } else {
                      userProvider.addFavoriteTrackId(track.id ?? "");
                    }
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
