import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:provider/provider.dart';

import 'package:band_names/presentation/models/band.dart';
import 'package:band_names/shared/services/socket_service.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Band> bands = [];

  @override
  void initState() {
    super.initState();

    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on( 'active-bands', _handleActivesBands );
  }

  void _handleActivesBands( dynamic payload ) {
    bands = ( payload as List ).map( (band) => Band.fromMap( band ) ).toList();
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

      body: Column(
        children: [

          if ( socketService.serverStatus == ServerStatus.online )
            _showChart(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: ( BuildContext context, int index ) {
                final band = bands[index];
                return _bandTile(band);
              },
            ),
          ),

        ],
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

    final socketService = Provider.of<SocketService>( context, listen: false );
    
    return Dismissible(
      key: Key( band.id ),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.emit( 'delete-band', { 'id': band.id } ),
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
    
        onTap: () => socketService.emit( 'vote-band', { 'id': band.id } ),
    
      ),
    );
  }


  addNewBand(){

    final textController = TextEditingController();

    // Android
    if ( Platform.isAndroid ) {
      return showDialog(
        context: context, 
        builder: ( _ ) => AlertDialog(
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
        )
      );
    }

    //IOS
    showCupertinoDialog(
      context: context, 
      builder: ( _ ) => CupertinoAlertDialog(
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
      )
    );
    
  }



  void addBandToList( String bandName ){
    
    if ( bandName.length > 1 ) {
      final socketService = Provider.of<SocketService>( context, listen: false );
      socketService.emit( 'add-band', { 'name': bandName } );
      
      // bands.add(
      //   Band(id: DateTime.now().toString(), name: bandName, votes: 0)
      // );
      // setState(() {});
    }

    Navigator.pop(context);

  }

  Widget _showChart(){
    
    // Map<String, double> dataMap = {
    //   "Flutter": 5,
    //   "React": 3,
    //   "Xamarin": 2,
    //   "Ionic": 2,
    // };

    Map<String, double> dataMap = {};
    
    bands.forEach(( band ) {
      dataMap.putIfAbsent( band.name, () => band.votes.toDouble() );
    });



    final List<Color> colorList = [
      Colors.blue[50]!,
      Colors.blue[200]!,
      Colors.purple[50]!,
      Colors.purple[200]!,
      Colors.yellow[50]!,
      Colors.yellow[200]!,
    ];


    return Container(
      padding: const EdgeInsets.only( top: 5 ),
      width: double.infinity,
      height: 200,
      child: PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 800),
      // chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      // ringStrokeWidth: 32,
      // centerText: "HYBRID",
      legendOptions: const LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        // legendShape: _BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 1,
      ),
      // gradientList: ---To add gradient colors---
      // emptyColorGradient: ---Empty Color gradient---
    )
    );

  }

}