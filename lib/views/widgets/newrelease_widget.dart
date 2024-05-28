import 'package:flutter/material.dart';
import 'package:app/models/track_model.dart';

import 'package:provider/provider.dart';
import 'package:app/view_models/user_provider.dart';

Widget getNewRelease(BuildContext context, List<Track> trackList) {
  return Consumer<UserProvider>(
    builder: (context, userProvider, _) {
      String? userId = userProvider.currentUser.idUser;
      // List<String>? favoriteTrackIds = userProvider.getFavoriteTrackIds(userId);
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 150,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: trackList.length,
          itemBuilder: (context, index) {
            Track element = trackList[index];
            // bool isFavorite = favoriteTrackIds?.contains(element.id ?? "") ?? false;

            return GestureDetector(
              onTap: () {
                final trackId = trackList[index].id ?? "";
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                userProvider.setCurrentTrackId(trackId);
                userProvider.notifyTrackListChanged(trackList);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Track image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: FadeInImage(
                        image: NetworkImage(element.image),
                        height: 100,
                        width: 150,
                        placeholder: const AssetImage("assets/icons/spinner100.gif"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Track title
                    Text(
                      element.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Track singer
                    Text(
                      element.singerId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
