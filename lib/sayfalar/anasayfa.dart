//@dart=2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyal_medya_uygulamasi/sayfalar/akis.dart';
import 'package:sosyal_medya_uygulamasi/sayfalar/ara.dart';
import 'package:sosyal_medya_uygulamasi/sayfalar/duyurular.dart';
import 'package:sosyal_medya_uygulamasi/sayfalar/profil.dart';
import 'package:sosyal_medya_uygulamasi/sayfalar/yukle.dart';
import 'package:sosyal_medya_uygulamasi/services/yetkilendirmeservisi.dart';

class Anasayfa extends StatefulWidget {
  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  int _aktifSayfaNo = 0;
  PageController sayfaKumandasi;

  @override
  void initState() {
    super.initState();
    sayfaKumandasi = PageController();
  }

  @override
  void dispose() {
    sayfaKumandasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    return Scaffold(
      body: PageView(
        onPageChanged: (acilanSayfaNo) {
          setState(() {
            _aktifSayfaNo = acilanSayfaNo;
          });
        },
        controller: sayfaKumandasi,
        children: [
          Akis(),
          Ara(),
          Yukle(),
          Duyurular(),
          Profil(
            profilSahibiId: aktifKullaniciId,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aktifSayfaNo,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Akış")),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), title: Text("Keşfet")),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_upload), title: Text("Yükle")),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), title: Text("Duyurular")),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text("Profil")),
        ],
        onTap: (secilenSayfaNo) {
          setState(() {
            sayfaKumandasi.jumpToPage(secilenSayfaNo);
          });
        },
      ),
    );
  }
}
