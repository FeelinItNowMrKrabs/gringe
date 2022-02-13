import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gringe/data/entities/game_room_entity.dart';
import 'package:gringe/data/entities/game_state_entity.dart';
import 'package:gringe/data/entities/room_entity.dart';
import 'package:gringe/data/models/gamehub_model.dart';
import 'package:gringe/router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:provider/src/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HubConnection hubConnection;
  final player = AudioPlayer();
  List<RoomEntity> roomList = [];
  RoomEntity? currentRoom;
  bool gameStarted = false;
  GameStateEntity? gameState;
  GameRoomEntity? gameRoom;
  late Logger logger;
  final _controllerGameField = TextEditingController();
  final _controlleRoomSizeField = TextEditingController();
  final _controllerUserNameField = TextEditingController();

  @override
  initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _connectToServer();
    });
    super.initState();
  }

  void _connectToServer() async {
    try {
      //const serverUrl = "http://localhost:10700/game";

      const serverUrl = "https://cringe-game-backend-3wdp7xa54a-ew.a.run.app/game";

      hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
      context.read<GamehubModel>().hubConnection =
          hubConnection; //hubConnection = context.read<GamehubModel>().hubConnection!;
      await hubConnection.start();
      final hubProtLogger = Logger("SignalR - hub");
      _sendGetRooms();
      hubConnection.on("RoomHub_SendRoomListNew", _handleSendRoomList);
      hubConnection.on("RoomHub_StartGame", _handleGameStart);
      hubConnection.on("GameHub_UpdateGameState", _handleGameState);
      hubConnection.onclose(_lostConection);
    } catch (_) {
      _cantConnect();
    }
  }

  void _lostConection({Exception? error}) {
    _showToast("Lost connection to server");
  }

  void _cantConnect() {
    _showToast("Cannot connect to server");
  }

  void _handleGameStart(List<Object>? parameters) {
    _showToast("Game start");
    //print(RoomEntity.fromJson(parameters as Map));

    try {
      print('when try ${RoomEntity.fromJson(parameters![0] as Map).id}');
      setState(() {
        gameRoom = GameRoomEntity.fromJson(parameters[0] as Map);
        gameStarted = true;
        _sendReady();
      });

      //context.read<AppRouterDelegate>().update<AppLink>((appLink) => appLink.copyWith(inGame: true));
    } catch (e) {
      print('fuck shit $e');
    }
  }

  void _sendReady() async {
    var req = {'gameId': '${gameRoom!.id}'};
    await hubConnection.invoke('GameHub_Ready', args: [req]);
  }

  void _handleSendRoomList(List<Object>? parameters) {
    _showToast("Got room list");
  }

  void _sendGetRooms() async {
    try {
      final result = await hubConnection.invoke('RoomHub_GetRooms', args: []) as List<dynamic>;
      setState(() {
        roomList = result.map((e) => RoomEntity.fromJson(e)).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendCreateRoom() async {
    if (_controllerGameField.text == '' ||
        _controlleRoomSizeField.text == '' ||
        int.tryParse(_controlleRoomSizeField.text) == null) {
      _showToast('Fuck you!');
    } else {
      try {
        var cunt = {'name': _controllerGameField.text, 'playersCount': int.parse(_controlleRoomSizeField.text)};
        await hubConnection.invoke('RoomHub_CreateRoom', args: [cunt]);
        _sendGetRooms();
      } catch (e) {
        print(e);
      }
    }
  }

  void _pressLobby(int index) async {
    if (_controllerUserNameField.text == '') {
      _showToast('FUCK YOU ENTER USER NAME');
    } else {
      try {
        var req = {
          "roomId": roomList[index].id,
          "userName": _controllerUserNameField.text,
        };
        final result = await hubConnection.invoke('RoomHub_JoinRoom', args: [req]);
        setState(() {
          currentRoom = roomList[index];
        });

        //context.read<AppRouterDelegate>().update<AppLink>((appLink) => appLink);
      } catch (e) {
        _showToast('Cant join room because $e');
      }
    }
  }

  void _pressChooseMeme(int index) async {
    try {
      var req = {
        "gameId": gameRoom!.id,
        "memeCardId": gameState!.hand[index].id,
      };
      final result = await hubConnection.invoke('GameHub_ChooseMeme', args: [req]);
      print(result);
      _showToast('Sent vote!');
    } catch (e) {
      _showToast('Couldnt send vote :( $e');
    }
  }

  void _pressVote(int index) async {
    try {
      var req = {
        "gameId": gameRoom!.id,
        "userId": gameState!.players[index].id,
      };
      final result = await hubConnection.invoke('GameHub_Vote', args: [req]);
    } catch (e) {
      _showToast('Couldnt send vote for meme  :( $e');
    }
  }

  void _handleGameState(List<Object>? parameters) {
    print('game statae');
    print(parameters![0]);
    try {
      setState(() {
        gameState = GameStateEntity.fromJson(parameters[0] as Map);
        print(gameState!.players[0].selectedCard);
      });
    } catch (e) {
      print('fuckpiss $e');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget lobbyScreen(BuildContext context) {
    return Center(
      child: Row(
        children: [
          const Spacer(),
          Column(
            children: [
              const SizedBox(height: 46),
              SizedBox(
                width: 420,
                child: TextField(
                  controller: _controllerGameField,
                  decoration: InputDecoration(
                    hintText: 'Room name',
                    filled: true,
                    fillColor: Colors.lightBlue,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        _controllerGameField.clear();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 420,
                child: TextField(
                  controller: _controlleRoomSizeField,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Number of players',
                    filled: true,
                    fillColor: Colors.lightBlue,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        _controlleRoomSizeField.clear();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 420,
                child: TextField(
                  controller: _controllerUserNameField,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Player Name',
                    filled: true,
                    fillColor: Colors.lightBlue,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        _controlleRoomSizeField.clear();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(420, 40),
                  onPrimary: Colors.blue,
                  primary: Colors.yellow,
                ),
                onPressed: _sendCreateRoom,
                child: const Text('Create room'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(420, 40),
                  onPrimary: Colors.blue,
                  primary: Colors.yellow,
                ),
                onPressed: _sendGetRooms,
                child: const Text('Get rooms'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                // height: MediaQuery.of(context).size.height,
                height: 700,
                width: 500,
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: roomList.length,
                    separatorBuilder: (_, __) => const SizedBox(
                          height: 16,
                        ),
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () {
                          _pressLobby(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Server: ${roomList[index].name}',
                                style:
                                    const TextStyle(fontSize: 32, color: Colors.blue, backgroundColor: Colors.yellow),
                              ),
                              Text(
                                'Players: ${roomList[index].players!.length}',
                                style:
                                    const TextStyle(fontSize: 32, color: Colors.blue, backgroundColor: Colors.yellow),
                              ),
                              Text(
                                'RoomId: ${roomList[index].id}',
                                style:
                                    const TextStyle(fontSize: 24, color: Colors.blue, backgroundColor: Colors.yellow),
                              ),
                              Text(
                                'Players: ${roomList[index].playersCountCurrent}',
                                style:
                                    const TextStyle(fontSize: 24, color: Colors.blue, backgroundColor: Colors.yellow),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              const Text('pizda'),
              if (currentRoom != null) const Text('In room'),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget selectScreen(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Text(
              gameState!.state,
              style: const TextStyle(fontSize: 36, color: Colors.blue, backgroundColor: Colors.yellow),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              gameState!.statement,
              style: const TextStyle(fontSize: 56, color: Colors.blue, backgroundColor: Colors.yellow),
            ),
            const Spacer(),
            SizedBox(
              width: MediaQuery.of(context).size.width - 200,
              //width: 900,
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: gameState!.players.length,
                separatorBuilder: (_, __) => const SizedBox(
                  width: 16,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (gameState!.state == 'ChoosingMeme' || gameState!.state == 'Ended') {
                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      clipBehavior: Clip.antiAlias,
                      child: Center(
                        child: Column(
                          children: [
                            Text('Name: ${gameState!.players[index].name}'),
                            Text('Points: ${gameState!.players[index].points}'),
                          ],
                        ),
                      ),
                    );
                  } else if (gameState!.state == 'Voting') {
                    return GestureDetector(
                      onTap: () {
                        print('vote for thins');
                        _pressVote(index);
                      },
                      child: Container(
                        height: 200,
                        width: 200,
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            gameState!.players[index].selectedCard!.uri,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Text('Fucked');
                  }
                },
              ),
            ),
            SizedBox(
              height: 50,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 200,
              //width: 900,
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: gameState!.hand.length,
                separatorBuilder: (_, __) => const SizedBox(
                  width: 16,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _pressChooseMeme(index);
                    },
                    child: Container(
                      height: 200,
                      width: 200,
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          gameState!.hand[index].uri,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // Column(
        //   children: [
        //     const Spacer(),
        //     const Text(
        //       'Players',
        //       style: TextStyle(fontSize: 36, color: Colors.blue, backgroundColor: Colors.yellow),
        //     ),
        //     ListView.separated(
        //       itemCount: gameState!.players.length,
        //       separatorBuilder: (_, __) => const SizedBox(
        //         width: 16,
        //       ),
        //       itemBuilder: (BuildContext context, int index) {
        //         return Container(
        //           height: 150,
        //           width: 150,
        //           child: Card(
        //             elevation: 4.0,
        //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        //             clipBehavior: Clip.antiAlias,
        //             child: Center(
        //               child: Column(
        //                 children: [
        //                   Text(
        //                     '${gameState!.players[index].name}',
        //                     style: TextStyle(fontSize: 36, color: Colors.blue, backgroundColor: Colors.yellow),
        //                   ),
        //                   Text(
        //                     '${gameState!.players[index].points} points',
        //                     style: TextStyle(fontSize: 36, color: Colors.blue, backgroundColor: Colors.yellow),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         );
        //       },
        //     ),
        //     const Spacer(),
        //   ],
        // ),
      ],
    );
  }

  Widget gameScreen(BuildContext context) {
    if (gameState == null) {
      return const Text('Fucked');
    }
    return Container(
      child: selectScreen(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!gameStarted) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/ukraine.jpeg"),
              fit: BoxFit.fill,
            ),
          ),
          child: lobbyScreen(context),
        ),
      );
    } else {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/ukraine.jpeg"),
              fit: BoxFit.fill,
            ),
          ),
          child: gameScreen(context),
        ),
      );
    }
  }
}
