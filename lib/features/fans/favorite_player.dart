class FavoritePlayer {
  const FavoritePlayer({
    required this.code,
    required this.name,
    required this.club,
    required this.league,
    required this.position,
    required this.photoUrl,
  });

  final String code;
  final String name;
  final String club;
  final String league;
  final String position;
  final String photoUrl;

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'club': club,
        'league': league,
        'position': position,
        'photoUrl': photoUrl,
      };

  factory FavoritePlayer.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] ?? '').toString();
    final fromCatalog = FavoritePlayersCatalog.byCode(code);

    return FavoritePlayer(
      code: code,
      name: (fromCatalog?.name ?? json['name'] ?? '').toString(),
      club: (fromCatalog?.club ?? json['club'] ?? '').toString(),
      league: (fromCatalog?.league ?? json['league'] ?? '').toString(),
      position: (fromCatalog?.position ?? json['position'] ?? '').toString(),
      photoUrl: (fromCatalog?.photoUrl ?? json['photoUrl'] ?? '').toString(),
    );
  }
}

class FavoritePlayersCatalog {
  FavoritePlayersCatalog._();

  static const List<FavoritePlayer> players = [
    FavoritePlayer(
      code: 'ronaldo',
      name: 'كريستيانو رونالدو',
      club: 'النصر',
      league: 'الدوري السعودي',
      position: 'مهاجم',
      photoUrl: 'https://img.a.transfermarkt.technology/portrait/big/8198-1748102259.jpg?lm=1',
    ),
    FavoritePlayer(
      code: 'benzema',
      name: 'كريم بنزيما',
      club: 'الاتحاد',
      league: 'الدوري السعودي',
      position: 'مهاجم',
      photoUrl: 'https://img.a.transfermarkt.technology/portrait/big/18922-1702414196.jpg?lm=1',
    ),
    FavoritePlayer(
      code: 'salem',
      name: 'سالم الدوسري',
      club: 'الهلال',
      league: 'الدوري السعودي',
      position: 'جناح',
      photoUrl: 'https://img.a.transfermarkt.technology/portrait/big/195332-1697051935.png?lm=1',
    ),
    FavoritePlayer(
      code: 'mahrez',
      name: 'رياض محرز',
      club: 'الأهلي',
      league: 'الدوري السعودي',
      position: 'جناح',
      photoUrl: 'https://img.a.transfermarkt.technology/portrait/big/171424-1699948752.jpg?lm=1',
    ),
    FavoritePlayer(
      code: 'mbappe',
      name: 'كيليان مبابي',
      club: 'ريال مدريد',
      league: 'الدوري الإسباني',
      position: 'مهاجم',
      photoUrl: 'https://img.a.transfermarkt.technology/portrait/big/342229-1682683695.jpg?lm=1',
    ),
    FavoritePlayer(
      code: 'vinicius',
      name: 'فينيسيوس جونيور',
      club: 'ريال مدريد',
      league: 'الدوري الإسباني',
      position: 'جناح',
      photoUrl: 'https://img.a.transfermarkt.technology/portrait/big/371998-1761575144.jpg?lm=1',
    ),
    FavoritePlayer(
      code: 'bellingham',
      name: 'جود بيلينغهام',
      club: 'ريال مدريد',
      league: 'الدوري الإسباني',
      position: 'وسط',
      photoUrl: 'https://img.a.transfermarkt.technology/portrait/big/581678-1748102891.jpg?lm=1',
    ),
    FavoritePlayer(
      code: 'yamal',
      name: 'لامين يامال',
      club: 'برشلونة',
      league: 'الدوري الإسباني',
      position: 'جناح',
      photoUrl: 'https://img.a.transfermarkt.technology/portrait/big/937958-1773173768.jpg?lm=1',
    ),
    FavoritePlayer(
      code: 'salah',
      name: 'محمد صلاح',
      club: 'ليفربول',
      league: 'الدوري الإنجليزي',
      position: 'جناح',
      photoUrl: 'https://img.a.transfermarkt.technology/portrait/big/148455-1727337594.jpg?lm=1',
    ),
    FavoritePlayer(
      code: 'haaland',
      name: 'إيرلينغ هالاند',
      club: 'مانشستر سيتي',
      league: 'الدوري الإنجليزي',
      position: 'مهاجم',
      photoUrl: 'https://img.a.transfermarkt.technology/portrait/big/418560-1709108116.png?lm=1',
    ),
  ];

  static List<String> get leagues => players.map((player) => player.league).toSet().toList();

  static FavoritePlayer? byCode(String? code) {
    final normalized = code?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final player in players) {
      if (player.code.toLowerCase() == normalized) return player;
    }
    return null;
  }
}
