import 'package:flutter/material.dart';

class FavoriteTeam {
  const FavoriteTeam({
    required this.code,
    required this.name,
    required this.league,
    required this.shortName,
    required this.primary,
    required this.secondary,
    required this.logoUrl,
  });

  final String code;
  final String name;
  final String league;
  final String shortName;
  final Color primary;
  final Color secondary;
  final String logoUrl;

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'league': league,
        'shortName': shortName,
        'primary': primary.value,
        'secondary': secondary.value,
        'logoUrl': logoUrl,
      };

  factory FavoriteTeam.fromJson(Map<String, dynamic> json) {
    int colorValue(dynamic value, int fallback) {
      if (value is int) return value;
      return int.tryParse('$value') ?? fallback;
    }

    final code = (json['code'] ?? '').toString();
    final fromCatalog = FavoriteTeamsCatalog.byCode(code);

    return FavoriteTeam(
      code: code,
      name: (json['name'] ?? fromCatalog?.name ?? '').toString(),
      league: (json['league'] ?? fromCatalog?.league ?? '').toString(),
      shortName: (json['shortName'] ?? fromCatalog?.shortName ?? '').toString(),
      primary: Color(colorValue(json['primary'], (fromCatalog?.primary ?? const Color(0xFFC4000B)).value)),
      secondary: Color(colorValue(json['secondary'], (fromCatalog?.secondary ?? const Color(0xFF111111)).value)),
      logoUrl: (json['logoUrl'] ?? fromCatalog?.logoUrl ?? '').toString(),
    );
  }
}

class FavoriteTeamsCatalog {
  FavoriteTeamsCatalog._();

  static const List<FavoriteTeam> teams = [
    // 10 أندية فقط مختارة من الدوريات: السعودي، الإسباني، والإنجليزي.
    FavoriteTeam(
      code: 'hilal',
      name: 'الهلال',
      league: 'الدوري السعودي',
      shortName: 'هلال',
      primary: Color(0xFF005BAC),
      secondary: Color(0xFFFFFFFF),
      logoUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Al-Hilal_SFC_logo.svg?width=128',
    ),
    FavoriteTeam(
      code: 'nassr',
      name: 'النصر',
      league: 'الدوري السعودي',
      shortName: 'نصر',
      primary: Color(0xFFFFD400),
      secondary: Color(0xFF123C8C),
      logoUrl: 'https://en.wikipedia.org/wiki/Special:FilePath/Al_Nassr_FC_Logo.svg?width=128',
    ),
    FavoriteTeam(
      code: 'ittihad',
      name: 'الاتحاد',
      league: 'الدوري السعودي',
      shortName: 'اتحاد',
      primary: Color(0xFF111111),
      secondary: Color(0xFFFFD400),
      logoUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Al-Ittihad_logo.png?width=128',
    ),
    FavoriteTeam(
      code: 'ahli',
      name: 'الأهلي',
      league: 'الدوري السعودي',
      shortName: 'أهلي',
      primary: Color(0xFF006B3F),
      secondary: Color(0xFFFFFFFF),
      logoUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Alahlilogo.svg?width=128',
    ),

    FavoriteTeam(
      code: 'realmadrid',
      name: 'ريال مدريد',
      league: 'الدوري الإسباني',
      shortName: 'ريال',
      primary: Color(0xFFFFFFFF),
      secondary: Color(0xFFD4AF37),
      logoUrl: 'https://en.wikipedia.org/wiki/Special:FilePath/Real_Madrid_CF.svg?width=128',
    ),
    FavoriteTeam(
      code: 'barcelona',
      name: 'برشلونة',
      league: 'الدوري الإسباني',
      shortName: 'برشا',
      primary: Color(0xFF004D98),
      secondary: Color(0xFFA50044),
      logoUrl: 'https://en.wikipedia.org/wiki/Special:FilePath/FC_Barcelona_%28crest%29.svg?width=128',
    ),
    FavoriteTeam(
      code: 'atletico',
      name: 'أتلتيكو مدريد',
      league: 'الدوري الإسباني',
      shortName: 'أتليتي',
      primary: Color(0xFFC8102E),
      secondary: Color(0xFF1B458F),
      logoUrl: 'https://en.wikipedia.org/wiki/Special:FilePath/Atletico_Madrid_Logo_2024.svg?width=128',
    ),

    FavoriteTeam(
      code: 'mancity',
      name: 'مانشستر سيتي',
      league: 'الدوري الإنجليزي',
      shortName: 'سيتي',
      primary: Color(0xFF6CABDD),
      secondary: Color(0xFFFFFFFF),
      logoUrl: 'https://en.wikipedia.org/wiki/Special:FilePath/Manchester_City_FC_badge.svg?width=128',
    ),
    FavoriteTeam(
      code: 'liverpool',
      name: 'ليفربول',
      league: 'الدوري الإنجليزي',
      shortName: 'ليفربول',
      primary: Color(0xFFC8102E),
      secondary: Color(0xFF00B2A9),
      logoUrl: 'https://en.wikipedia.org/wiki/Special:FilePath/Liverpool_FC.svg?width=128',
    ),
    FavoriteTeam(
      code: 'arsenal',
      name: 'آرسنال',
      league: 'الدوري الإنجليزي',
      shortName: 'آرس',
      primary: Color(0xFFEF0107),
      secondary: Color(0xFFFFFFFF),
      logoUrl: 'https://en.wikipedia.org/wiki/Special:FilePath/Arsenal_FC.svg?width=128',
    ),
  ];

  static List<String> get leagues => teams.map((team) => team.league).toSet().toList();

  static FavoriteTeam? byCode(String? code) {
    final normalized = code?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final team in teams) {
      if (team.code.toLowerCase() == normalized) return team;
    }
    return null;
  }
}
