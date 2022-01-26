//@dart=2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyal_medya_uygulamasi/models/kullanici.dart';
import 'package:sosyal_medya_uygulamasi/sayfalar/anasayfa.dart';
import 'package:sosyal_medya_uygulamasi/sayfalar/girissayfasi.dart';
import 'package:sosyal_medya_uygulamasi/services/yetkilendirmeservisi.dart';

class Yonlendirme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    return StreamBuilder(
      stream: _yetkilendirmeServisi.durumTakipcisi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          Kullanici aktifKullanici = snapshot.data;
          _yetkilendirmeServisi.aktifKullaniciId = aktifKullanici.id;
          return Anasayfa();
        } else {
          return GirisSayfasi();
        }
      },
    );
  }
}
