import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/track_model.dart';
import '../../view_models/user_provider.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  List<Track> _searchResults = [];
  List<Track> _latestSongs = [];
  bool _searched = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    getLatestSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> searchTrack(String value) async {
    setState(
      () {
        _loading = true;
        _searchResults = [];
      },
    );

    final lowerCaseValue = value.toLowerCase();

    final result = await FirebaseFirestore.instance.collection("track").get();

    setState(
      () {
        _searchResults = result.docs
            .map((e) => Track.fromSnapshot(e))
            .where(
                (track) => track.title.toLowerCase().contains(lowerCaseValue))
            .toList();
        _searched = true;
        _loading = false;
      },
    );
  }

  Future<void> getLatestSongs() async {
    final result =
        await FirebaseFirestore.instance.collection("track").limit(5).get();

    setState(
      () {
        _latestSongs = result.docs.map((e) => Track.fromSnapshot(e)).toList();
      },
    );
  }

  Widget buildListTiles(List<Track> tracks) {
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              tracks[index].image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(tracks[index].title),
          subtitle: Text(tracks[index].singerId),
          onTap: () {
            final userProvider =
            Provider.of<UserProvider>(context,
                listen: false);
            final trackId = tracks[index].id ?? "";
            userProvider.setCurrentTrackId(trackId);
            userProvider.notifyTrackListChanged(tracks);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => searchTrack(value),
                decoration: const InputDecoration(
                  labelText: 'Search',
                  hintText: 'Search by title',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _searched && _searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No data',
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      : _searched && _searchResults.isNotEmpty
                          ? buildListTiles(_searchResults)
                          : buildListTiles(_latestSongs),
            ),
          ],
        ),
      ),
    );
  }
}
