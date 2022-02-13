import 'dart:convert';

class GameStateEntity {
  final String state;
  final List<PlayerInGameEntity> players;
  final String statement;
  final int currentRound;
  final List<PlayerHandEntity> hand;

  const GameStateEntity({
    required this.state,
    required this.players,
    required this.statement,
    required this.currentRound,
    required this.hand,
  });

  GameStateEntity.fromJson(Map json)
      : state = json['state'] as String,
        players = (json['players'] as List).map((e) => PlayerInGameEntity.fromJson(e as Map)).toList(),
        statement = json['statement'] as String,
        currentRound = json['currentRound'] as int,
        hand = (json['hand'] as List).map((e) => PlayerHandEntity.fromJson(e as Map)).toList();
}

class PlayerInGameEntity {
  final String name;
  final String id;
  final int points;
  final PlayerHandEntity? selectedCard;
  const PlayerInGameEntity({
    required this.name,
    required this.id,
    required this.points,
    this.selectedCard,
  });

  PlayerInGameEntity.fromJson(Map json)
      : name = json['name'] as String,
        id = json['id'] as String,
        points = json['points'] as int,
        selectedCard = json['selectedCard'] == null ? null : PlayerHandEntity.fromJson(json['selectedCard']);
}

class PlayerHandEntity {
  final String id;
  final String uri;

  const PlayerHandEntity({
    required this.id,
    required this.uri,
  });

  PlayerHandEntity.fromJson(Map json)
      : id = json['id'] as String,
        uri = json['uri'] as String;
}
