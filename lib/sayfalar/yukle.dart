//@dart=2.9
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sosyal_medya_uygulamasi/services/firestoreservisi.dart';
import 'package:sosyal_medya_uygulamasi/services/storageservisi.dart';
import 'package:sosyal_medya_uygulamasi/services/yetkilendirmeservisi.dart';

class Yukle extends StatefulWidget {
  @override
  _YukleState createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  File dosya;
  bool yukleniyor = false;
  TextEditingController aciklamaTextKumandasi = TextEditingController();
  TextEditingController konumTextKumandasi = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return dosya == null ? yukleButonu() : gonderiFormu();
  }

  Widget yukleButonu() {
    return IconButton(
        onPressed: () {
          fotografSec();
        },
        icon: Icon(
          Icons.file_upload,
          size: 50.0,
        ));
  }

  Widget gonderiFormu() {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          title: Text(
            "Gönderi Oluştur",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                dosya = null;
              });
            },
          ),
          actions: [
            IconButton(
                onPressed: _gonderiOlustur,
                icon: Icon(
                  Icons.send,
                  color: Colors.black,
                ))
          ],
        ),
        body: ListView(
          children: [
            yukleniyor
                ? LinearProgressIndicator()
                : SizedBox(
                    height: 0.0,
                  ),
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Image.file(
                dosya,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              controller: aciklamaTextKumandasi,
              decoration: InputDecoration(
                  hintText: "Açıklama Ekle",
                  contentPadding: EdgeInsets.only(left: 15.0, right: 15.0)),
            ),
            TextFormField(
              controller: konumTextKumandasi,
              decoration: InputDecoration(
                  hintText: "Konum",
                  contentPadding: EdgeInsets.only(left: 15.0, right: 15.0)),
            ),
          ],
        ),
      ),
    );
  }

  void _gonderiOlustur() async {
    setState(() {
      yukleniyor = true;
    });

    String resimUrl = await StorageServisi().gonderiResmiYukle(dosya);
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    await FireStoreServisi().gonderiOlustur(
        gonderiResmiUrl: resimUrl,
        aciklama: aciklamaTextKumandasi.text,
        yayinlayanId: aktifKullaniciId,
        konum: konumTextKumandasi.text);
    setState(() {
      yukleniyor = false;
      aciklamaTextKumandasi.clear();
      konumTextKumandasi.clear();
      dosya = null;
    });
  }

  fotografSec() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Gönderi Oluştur"),
            children: [
              SimpleDialogOption(
                child: Text("Fotoğraf Çek"),
                onPressed: () {
                  fotografSec();
                },
              ),
              SimpleDialogOption(
                child: Text("Galeriden Yükle"),
                onPressed: () {
                  galeridenSec();
                },
              ),
              SimpleDialogOption(
                child: Text("İptal"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  fotoCek() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image.path);
    });
  }

  galeridenSec() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image.path);
    });
  }
}
