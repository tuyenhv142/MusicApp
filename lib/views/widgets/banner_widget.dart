import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/banner_provide.dart';



class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<BannerProvider>(context, listen: false).getBanner();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BannerProvider>(context);
    final listBanner = provider.getListBanner;

    if (listBanner.isNotEmpty) {
      return CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 16 / 9,
          autoPlay: true,
          autoPlayCurve: Curves.fastOutSlowIn,
          autoPlayAnimationDuration: const Duration(milliseconds: 1000),
          enlargeCenterPage: true,
          viewportFraction: 0.8,
          enableInfiniteScroll: true,
          height: 100.0,
          initialPage: 0,
        ),
        items: listBanner.map((banner) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                margin: const EdgeInsets.all(3.0),
                width: MediaQuery.of(context).size.width,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.network(banner.imgURL, fit: BoxFit.cover),
                ),
              );
            },
          );
        }).toList(),
      );
    } else {
      return Container();
    }
  }
}
