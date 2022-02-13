import 'package:gringe/data/entities/room_entity.dart';

class GameRoomEntity {
  final String id;
  final List<PlayerInRoomEntity> players;

  const GameRoomEntity({
    required this.id,
    required this.players,
  });

  GameRoomEntity.fromJson(Map json)
      : id = json['id'] as String,
        players = (json['players'] as List).map((e) => PlayerInRoomEntity.fromJson(e as Map)).toList();
}
