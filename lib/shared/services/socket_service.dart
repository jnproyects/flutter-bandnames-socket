

import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {

  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket _socket;

  SocketService(){

    _initConfig();

  }

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  void _initConfig(){

    // Dart client

    // con emuladores reemplazar por dirección ip ó por 'http://10.0.2.2:3000'
    //10.0.2.2 es una dirección IP especial utilizada en entornos de emuladores de Android.

    // IO.Socket socket = IO.io('http://localhost:3000/', { // no funcionó

    // para probar en dispositivo físico
    // _socket = IO.io('ipmaquina:3000/', {  // server corriendo de forma local

    // server corriendo en la nube
    _socket = IO.io('https://flutter-socket-server-f1d1.onrender.com/', {
      'transports': ['websocket'],
      'autoConnect': true
    });


    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    // socket.on('nuevo-mensaje', (data) {
      // print( 'nuevo-mensaje:' );
      // print( 'nombre: ${data['nombre']}' );
      // print( 'mensaje: ${data['mensaje']}' );
      // print( data.containsKey('mensaje2') ? data['mensaje2'] : 'no existe' );
    // });

    // socket.emit(event)


  }

}