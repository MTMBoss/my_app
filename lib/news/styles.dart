import 'package:flutter/material.dart';

final BoxDecoration newsCardDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [Colors.black87, Colors.black54],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(12.0),
  boxShadow: [
    BoxShadow(
      color: const Color.fromARGB(255, 85, 85, 85).withAlpha(128),
      spreadRadius: 2,
      blurRadius: 5,
      offset: const Offset(0, 3),
    ),
  ],
);

final BoxDecoration newsCardHeaderDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [Colors.deepPurple[700]!, Colors.deepPurple[500]!],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(12.0),
    topRight: Radius.circular(12.0),
  ),
);

final TextStyle newsDateStyle = const TextStyle(color: Colors.white, fontSize: 16);
final TextStyle newsBodyStyle = const TextStyle(color: Colors.white, fontSize: 16);
final TextStyle pdfLinkStyle = const TextStyle(color: Colors.blue, decoration: TextDecoration.underline);
final TextStyle pageTitleStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
final TextStyle errorMessageStyle = const TextStyle(color: Colors.white, fontSize: 16);
final TextStyle linkTextStyle = const TextStyle(color: Colors.blue, decoration: TextDecoration.underline);
