import 'package:flutter/material.dart';
import 'package:gringe/data/entities/room_entity.dart';
import 'package:signalr_netcore/hub_connection.dart';

class GamehubModel extends ChangeNotifier {
  List<RoomEntity> roomList = [];
  RoomEntity? currentRoom;
  HubConnection? hubConnection;
}
