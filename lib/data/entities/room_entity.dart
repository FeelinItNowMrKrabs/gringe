class RoomEntity {
  final String? id;
  final String? name;
  final int? playersCountCurrent;
  final int? state;
  final List<PlayerInRoomEntity>? players;

  const RoomEntity({
    this.id,
    this.name,
    this.playersCountCurrent,
    this.state,
    this.players,
  });

  RoomEntity.fromJson(Map json)
      : id = json['id'] as String?,
        name = json['name'] as String?,
        playersCountCurrent = json['playersCountCurrent'] as int?,
        state = json['state'] as int?,
        players = (json['players'] as List).map((e) => PlayerInRoomEntity.fromJson(e as Map)).toList();
}

class PlayerInRoomEntity {
  final String name;
  final String id;
  const PlayerInRoomEntity({
    required this.name,
    required this.id,
  });

  PlayerInRoomEntity.fromJson(Map json)
      : name = json['name'] as String,
        id = json['id'] as String;
}
