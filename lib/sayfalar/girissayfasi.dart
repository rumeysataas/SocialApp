//@dart=2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyal_medya_uygulamasi/models/kullanici.dart';
import 'package:sosyal_medya_uygulamasi/sayfalar/hesapolustur.dart';
import 'package:sosyal_medya_uygulamasi/services/firestoreservisi.dart';
import 'package:sosyal_medya_uygulamasi/services/yetkilendirmeservisi.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String email, sifre;

  bool yukleniyor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldAnahtari,
        body: Stack(
          children: [
            _sayfaElemanlari(),
            _yuklemeAnimasyonu(),
          ],
        ));
  }

  Widget _yuklemeAnimasyonu() {
    if (yukleniyor) {
      return Center(child: CircularProgressIndicator());
    } else {
      return SizedBox(
        height: 0.0,
      );
    }
  }

  Widget _sayfaElemanlari() {
    return Form(
      key: _formAnahtari,
      child: ListView(
        padding: EdgeInsets.only(
          left: 20.0,
          top: 60.0,
          right: 20.0,
        ),
        children: [
          FlutterLogo(
            size: 90.0,
          ),
          SizedBox(
            height: 80.0,
          ),
          TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                hintText: "E-mail adresinizi girin ",
                prefixIcon: Icon(Icons.mail)),
            validator: (girilenDeger) {
              if (girilenDeger.isEmpty) {
                return "Email alanı boş bırakılamaz.";
              } else if (!girilenDeger.contains("@")) {
                return "Girilen değer mail formatında olmalı!";
              }
              return null;
            },
            onSaved: (girilenDeger) {
              email = girilenDeger;
            },
          ),
          SizedBox(
            height: 40.0,
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
                hintText: "Şifrenizi girin ", prefixIcon: Icon(Icons.lock)),
            validator: (girilenDeger) {
              if (girilenDeger.isEmpty) {
                return "Şifre alanı boş bırakılamaz.";
              } else if (girilenDeger.trim().length < 4) {
                return "Şifre 4 karakterden az olamaz!";
              }
              return null;
            },
            onSaved: (girilenDeger) {
              sifre = girilenDeger;
            },
          ),
          SizedBox(
            height: 40.0,
          ),
          Row(
            children: [
              Expanded(
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HesapOlustur()));
                  },
                  child: Text(
                    "Hesap Oluştur",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: FlatButton(
                  onPressed: _girisYap,
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColorDark,
                ),
              )
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(child: Text("veya")),
          SizedBox(
            height: 20.0,
          ),
          Center(
              child: InkWell(
            onTap: _googleIleGiris,
            child: Text(
              "Google ile giriş yap",
              style: TextStyle(
                  fontSize: 19.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
          )),
          SizedBox(
            height: 20.0,
          ),
          Center(child: Text("Şifremi unuttum")),
        ],
      ),
    );
  }

  void _girisYap() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    if (_formAnahtari.currentState.validate()) {
      _formAnahtari.currentState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        await _yetkilendirmeServisi.mailleGiris(email, sifre);
      } catch (hata) {
        yukleniyor = false;
        uyariGoster(hataKodu: hata.code);
      }
    }
  }

  void _googleIleGiris() async {
    var _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    setState(() {
      yukleniyor = true;
    });

    try {
      Kullanici kullanici = await _yetkilendirmeServisi.googleIleGiris();
      if (kullanici != null) {
        Kullanici firestoreKullanici =
            await FireStoreServisi().kullaniciGetir(kullanici.id);
        if (firestoreKullanici == null) {
          FireStoreServisi().kullaniciOlustur(
              id: kullanici.id,
              email: kullanici.email,
              kullaniciAdi: kullanici.kullaniciAdi,
              fotoUrl: kullanici.fotoUrl);
        }
      }
    } catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata.code);
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;
    if (hataKodu == "ERROR_USER_NOT_FOUND") {
      hataMesaji = "Böyle bir kullanıcı bulunmuyor";
    } else if (hataKodu == "ERROR_INVALID_EMAIL") {
      hataMesaji = "Girdiğiniz mail zadresi geçersizdir.";
    } else if (hataKodu == "ERROR_WRONG_PASSWORD") {
      hataMesaji = "Girilen şifre hatalı";
    } else if (hataKodu == "ERROR_USER_DISABLED") {
      hataMesaji = "Kullanıcı engellenmiş";
    } else {
      hataMesaji = "Tanımlanamayan bir hata oluştu $hataKodu";
    }
    var snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }
}
