//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyal_medya_uygulamasi/models/kullanici.dart';
import 'package:sosyal_medya_uygulamasi/services/firestoreservisi.dart';
import 'package:sosyal_medya_uygulamasi/services/yetkilendirmeservisi.dart';

class HesapOlustur extends StatefulWidget {
  @override
  _HesapOlusturState createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String kullaniciAdi, email, sifre;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldAnahtari,
        appBar: AppBar(
          title: Text("Hesap Oluştur"),
        ),
        body: ListView(
          children: [
            yukleniyor
                ? LinearProgressIndicator()
                : SizedBox(
                    height: 0.0,
                  ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                  key: _formAnahtari,
                  child: Column(
                    children: [
                      TextFormField(
                        autocorrect: true,
                        decoration: InputDecoration(
                            hintText: "Kullanıcı adresinizi girin ",
                            labelText: "Kullanıcı Adı :",
                            prefixIcon: Icon(Icons.person)),
                        validator: (girilenDeger) {
                          if (girilenDeger.isEmpty) {
                            return "Kullanıcı boş bırakılamaz.";
                          } else if (girilenDeger.trim().length < 4 ||
                              girilenDeger.trim().length > 10) {
                            return "Girilen değer 4 ile 10 karakter arasında olmalı!";
                          }
                          return null;
                        },
                        onSaved: (girilenDeger) {
                          kullaniciAdi = girilenDeger;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            hintText: "E-mail adresinizi girin ",
                            labelText: "E-mail :",
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
                        height: 10.0,
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: "Şifrenizi girin ",
                            labelText: "Şifre :",
                            prefixIcon: Icon(Icons.lock)),
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
                        height: 50.0,
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          onPressed: _kullaniciOlustur,
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
                    ],
                  )),
            )
          ],
        ));
  }

  void _kullaniciOlustur() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    var _formState = _formAnahtari.currentState;
    if (_formState.validate()) {
      _formState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        Kullanici kullanici =
            await YetkilendirmeServisi().mailleKayit(email, sifre);
        if (kullanici != null) {
          FireStoreServisi().kullaniciOlustur(
              id: kullanici.id, email: email, kullaniciAdi: kullaniciAdi);
        }
        Navigator.pop(context);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata.code);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;
    if (hataKodu == "ERROR_INVALID_EMAIL") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "ERROR_EMAIL_ALREADY_IN_USE") {
      hataMesaji = "Girdiğiniz mail zaten kayıtlı.";
    } else if (hataKodu == "ERROR_WEAK_PASSWORD") {
      hataMesaji = "Daha zor bir şifre tercih edin";
    }
    var snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }
}
