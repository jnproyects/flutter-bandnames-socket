import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_names/shared/services/socket_service.dart';

class StatusScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    // socketService.socket.emit(event)

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text('ServerStatus: ${ socketService.serverStatus }'),

            

          ]
        )
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
          // socketService.socket.emit( 'emitir-mensaje', { 'nombre': 'Flutter', 'mensaje': 'Hola desde Flutter' });
          socketService.emit( 'emitir-mensaje', { 'nombre': 'Flutter', 'mensaje': 'Hola desde Flutter' });

        },
        elevation: 1,
        child: const Icon( Icons.message_outlined ),
      ),
    );
  }
}