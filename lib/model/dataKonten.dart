class KontenModel {
  final String id;
  final String imageUrl;
  final String caption;
  final int likes;
  final int dislikes;
  final int comments;

  KontenModel({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.dislikes,
    required this.comments,
  });
}

List<KontenModel> dataKonten = [
  KontenModel(
    id: '1',
    imageUrl: 'assets/img/home.png',
    caption: 'Caption 1',
    likes: 20,
    dislikes: 5,
    comments: 15,
  ),
  KontenModel(
    id: '2',
    imageUrl: 'assets/img/home.png',
    caption: 'Caption 2',
    likes: 15,
    dislikes: 3,
    comments: 10,
  ),
  KontenModel(
    id: '3',
    imageUrl: 'assets/img/home.png',
    caption: 'Caption 3',
    likes: 30,
    dislikes: 7,
    comments: 25,
  ),
  KontenModel(
    id: '4',
    imageUrl: 'assets/img/home.png',
    caption: 'Caption 4',
    likes: 25,
    dislikes: 2,
    comments: 18,
  ),
  KontenModel(
    id: '5',
    imageUrl: 'assets/img/home.png',
    caption: 'Caption 5',
    likes: 18,
    dislikes: 4,
    comments: 12,
  ),
];
