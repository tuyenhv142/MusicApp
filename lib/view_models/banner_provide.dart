import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/banner_model.dart';

class BannerProvider with ChangeNotifier {
  List<Bannerr> listBanner = [];
  late Bannerr banner1;
  List<String> listBannerIMG = [];

  Future<void> getBanner() async {
    List<Bannerr> newList = [];
    QuerySnapshot bannerSnapshot =
        await FirebaseFirestore.instance.collection("banner").get();

    for (var element in bannerSnapshot.docs) {
      banner1 = Bannerr(
        id: element.reference.id,
        imgURL: element["img"].toString(),
      );

      newList.add(banner1);
    }

    listBanner = newList;
    notifyListeners();
  }

  List<Bannerr> get getListBanner {
    return listBanner;
  }

  List<String> get getListBannerIMG {
    return listBannerIMG;
  }
}
