import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_names/presentation/models/band.dart';
import 'package:band_names/shared/services/socket_service.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Band> bands = [
    // Band(id: '1', name: 'Megadeth', votes: 5 ),
    // Band(id: '2', name: 'Suicidal Tendencies', votes: 7 ),
    // Band(id: '3', name: 'Obituary', votes: 10 ),
    // Band(id: '4', name: 'Kreator', votes: 8 ),
    // Band(id: '5', name: 'The Rolling Stones', votes: 6 ),
  ];

  @override
  void initState() {
    super.initState();

    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', ( data ) {
      bands = ( data as List ).map( (band) => Band.fromMap( band ) ).toList();
    });
    setState((){});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      
      appBar: AppBar(
        actions: [
          Container(
            margin: const EdgeInsets.only( right: 10 ),
            child: ( socketService.serverStatus == ServerStatus.online )
            ? Icon(
                Icons.check_circle_outlined,
                color: Colors.blue[300]
              )

            : Icon(
                Icons.offline_bolt,
                color: Colors.red[300]
              ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Band Names',
          style: TextStyle(
            color: Colors.black87
          )
        ),
      ),

      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: ( BuildContext context, int index ) {
          final band = bands[index];
          return _bandTile(band);
        },
      ),

      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: addNewBand,
        child: const Icon(
          Icons.add
        ),
      ),
    );

  }

  Widget _bandTile(Band band) {
    
    return Dismissible(
      key: Key( band.id ),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        //TODO: Llamar borrado en el server
      },
      background: Container(
        padding: const EdgeInsets.only( left: 8.0 ),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete band',
            style: TextStyle(
              color: Colors.white
            ),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0,2)),
        ),
    
        title: Text(
          band.name
        ),
    
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(
            fontSize: 20
          ),
        ),
    
        onTap: () {
          print(band.name);
        },
    
      ),
    );
  }


  addNewBand(){

    final textController = TextEditingController();

    // Android
    if ( Platform.isAndroid ) {
      return showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            title: const Text('New band name'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList( textController.text ),
                child: const Text('Add'),
              )
            ],
          );
        }
      );
    }

    //IOS
    showCupertinoDialog(
      context: context, 
      builder: ( _ ) {
        return CupertinoAlertDialog(
          title: const Text(
            'New band name'
          ),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [

            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => addBandToList( textController.text ),
              child: const Text(
                'Add'
              )
            ),

            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Dismiss'
              )
            ),

          ],
        );
      },
    );
    
  }



  void addBandToList( String bandName ){
    
    if ( bandName.length > 1 ) {
      bands.add(
        Band(id: DateTime.now().toString(), name: bandName, votes: 0)
      );
      setState(() {});
    }

    Navigator.pop(context);

  }

}