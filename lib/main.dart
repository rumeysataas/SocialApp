//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyal_medya_uygulamasi/models/kullanici.dart';
import 'package:sosyal_medya_uygulamasi/services/yetkilendirmeservisi.dart';
import 'package:sosyal_medya_uygulamasi/yonlendirme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<YetkilendirmeServisi>(
      create: (_) => YetkilendirmeServisi(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sociaword',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Yonlendirme(),
      ),
    );
  }
}
