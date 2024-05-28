import 'package:equatable/equatable.dart';

class Bannerr extends Equatable {
  final String id;
  final String imgURL;

  const Bannerr({
    required this.id,
    required this.imgURL,
  });

  @override
  List<Object?> get props => [id, imgURL];
}
