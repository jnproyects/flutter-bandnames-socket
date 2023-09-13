import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/presentation/models/band.dart';


class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Band> bands = [
    Band(id: '1', name: 'Megadeth', votes: 5 ),
    Band(id: '2', name: 'Suicidal Tendencies', votes: 7 ),
    Band(id: '3', name: 'Obituary', votes: 10 ),
    Band(id: '4', name: 'Kreator', votes: 8 ),
    Band(id: '5', name: 'The Rolling Stones', votes: 6 ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'Band Names',
          style: TextStyle(
            color: Colors.black87
          )
        ),
        backgroundColor: Colors.white
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

  ListTile _bandTile(Band band) {
    return ListTile(
      
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