//@dart=2.9
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyal_medya_uygulamasi/models/gonderi.dart';
import 'package:sosyal_medya_uygulamasi/models/kullanici.dart';
import 'package:sosyal_medya_uygulamasi/sayfalar/widgetlar/gonderikarti.dart';
import 'package:sosyal_medya_uygulamasi/services/firestoreservisi.dart';
import 'package:sosyal_medya_uygulamasi/services/yetkilendirmeservisi.dart';

class Profil extends StatefulWidget {
  final String profilSahibiId;

  const Profil({Key key, this.profilSahibiId}) : super(key: key);
  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gonderiSayisi = 0;
  int _takipci = 0;
  int _takipEdilen = 0;
  List<Gonderi> _gonderiler = [];
  String gonderiStili = "liste";

  _takipciSayisiGetir() async {
    int takipciSayisi =
        await FireStoreServisi().takipciSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  _takipEdilenSayisiGetir() async {
    int takipEdilenSayisi =
        await FireStoreServisi().takipEdilenSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipEdilen = takipEdilenSayisi;
      });
    }
  }

  _gonderileriGetir() async {
    List<Gonderi> gonderiler =
        await FireStoreServisi().gonderileriGetir(widget.profilSahibiId);
    setState(() {
      _gonderiler = gonderiler;
      _gonderiSayisi = _gonderiler.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
    _gonderileriGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
        actions: [
          IconButton(
              onPressed: _cikisYap,
              color: Colors.black,
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: FutureBuilder<Object>(
          future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: [
                _profilDetaylari(snapshot.data),
                _gonderileriGoster(snapshot.data)
              ],
            );
          }),
    );
  }

  Widget _gonderileriGoster(Kullanici profilData) {
    if (gonderiStili == "liste") {
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          return GonderiKarti(
            gonderi: _gonderiler[index],
            yayinlayan: profilData,
          );
        },
        itemCount: _gonderiler.length,
      );
    } else {
      List<GridTile> fayanslar = [];
      _gonderiler.forEach((gonderi) {
        fayanslar.add(_fayansOlustur(gonderi));
      });
      return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1.0,
          physics: NeverScrollableScrollPhysics(),
          children: fayanslar);
    }
  }

  GridTile _fayansOlustur(Gonderi gonderi) {
    return GridTile(
      child: GridTile(
          child: Image.network(
        gonderi.gonderiResmiUrl,
        fit: BoxFit.cover,
      )),
    );
  }

  Widget _profilDetaylari(Kullanici profilData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 50.0,
                backgroundImage: profilData.fotoUrl.isNotEmpty
                    ? NetworkImage(profilData.fotoUrl)
                    : AssetImage("assets\images/user.png"),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sosyalSayac(baslik: "Gönderiler", sayi: _gonderiSayisi),
                    _sosyalSayac(baslik: "Takipçi", sayi: _takipci),
                    _sosyalSayac(baslik: "Takip", sayi: _takipEdilen),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            profilData.kullaniciAdi,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(profilData.hakkinda),
          SizedBox(
            height: 25.0,
          ),
          _profiliDuzenleButon()
        ],
      ),
    );
  }

  Widget _profiliDuzenleButon() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {},
        child: Text("Profili Düzenle"),
      ),
    );
  }

  Widget _sosyalSayac({String baslik, int sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2.0,
        ),
        Text(
          baslik,
          style: TextStyle(fontSize: 15.0),
        ),
      ],
    );
  }

  void _cikisYap() {
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
