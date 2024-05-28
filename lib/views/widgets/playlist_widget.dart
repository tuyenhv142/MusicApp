import 'package:flutter/material.dart';
import 'package:app/models/playList_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:app/view_models/playList_provider.dart'; // Import provider

import '../pages/detail_pages/playlist_detail_page.dart';


Widget getPlayList(BuildContext context, List<PlayList> playList) {
  if (playList.isNotEmpty) {
    return Consumer<PlayListProvider>(
      builder: (context, playlistProvider, _) {
        return Container(
          margin: const EdgeInsets.only(left: 5, right: 5),
          height: 300,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: -1,
              direction: Axis.vertical,
              children: playList
                  .map(
                    (element) => GestureDetector(
                      onTap: () {
                        final playlistId = element.id;
                        playlistProvider.playlistDetail(playlistId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlaylistPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 200,
                        height: 290,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 250,
                              width: 170,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xffe3eaef),
                                    spreadRadius: 0.06,
                                    blurRadius: 24,
                                    offset: Offset(12, 12),
                                  ),
                                  BoxShadow(
                                    color: Color(0xffffffff),
                                    spreadRadius: 0.06,
                                    blurRadius: 24,
                                    offset: Offset(-12, -12),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: FadeInImage(
                                  image: NetworkImage(element.img),
                                  placeholder:
                                      const AssetImage("assets/icons/spinner100.gif"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: 150,
                              height: 30,
                              child: AutoSizeText(
                                element.name,
                                maxFontSize: 13,
                                minFontSize: 12,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Open Sans",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  } else {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      height: 300,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: -1,
          direction: Axis.vertical,
          children: [1, 2, 3]
              .map(
                (element) => Container(
                  width: 200,
                  height: 290,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 20),
                        height: 250,
                        width: 170,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xffe3eaef),
                              spreadRadius: 0.06,
                              blurRadius: 24,
                              offset: Offset(12, 12),
                            ),
                            BoxShadow(
                              color: Color(0xffffffff),
                              spreadRadius: 0.06,
                              blurRadius: 24,
                              offset: Offset(-12, -12),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/icons/spinner100.gif",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
