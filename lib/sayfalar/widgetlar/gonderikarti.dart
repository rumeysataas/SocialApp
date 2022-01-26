//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyal_medya_uygulamasi/models/gonderi.dart';
import 'package:sosyal_medya_uygulamasi/models/kullanici.dart';
import 'package:sosyal_medya_uygulamasi/sayfalar/yorumlar.dart';
import 'package:sosyal_medya_uygulamasi/services/firestoreservisi.dart';
import 'package:sosyal_medya_uygulamasi/services/yetkilendirmeservisi.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;

  const GonderiKarti({Key key, this.gonderi, this.yayinlayan})
      : super(key: key);

  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  String _aktifKullaniciId;

  @override
  void initState() {
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _begeniSayisi = widget.gonderi.begeniSayisi;
    begeniVarmi();
  }

  begeniVarmi() async {
    bool begeniVarmi =
        await FireStoreServisi().begeniVarmi(widget.gonderi, _aktifKullaniciId);
    if (begeniVarmi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          _gonderiBasligi(),
          _gonderiResmi(),
          _gonderiAlt(),
        ],
      ),
    );
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: NetworkImage(widget.yayinlayan.fotoUrl)),
      ),
      title: Text(
        widget.yayinlayan.kullaniciAdi,
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () {},
      ),
      contentPadding: EdgeInsets.all(0.0),
    );
  }

  Widget _gonderiResmi() {
    return GestureDetector(
      onDoubleTap: _begeniDegistir,
      child: Image.network(
        widget.gonderi.gonderiResmiUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                onPressed: _begeniDegistir,
                icon: !_begendin
                    ? Icon(
                        Icons.favorite_border,
                        size: 35.0,
                      )
                    : Icon(
                        Icons.favorite,
                        size: 35.0,
                        color: Colors.red,
                      )),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Yorumlar(
                                gonderi: widget.gonderi,
                              )));
                },
                icon: Icon(
                  Icons.comment,
                  size: 35.0,
                ))
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("$_begeniSayisi beğeni",
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 2.0,
        ),
        widget.gonderi.aciklama.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                    text: TextSpan(
                        text: widget.yayinlayan.kullaniciAdi + " ",
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        children: [
                      TextSpan(
                          text: widget.gonderi.aciklama,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 14.0))
                    ])),
              )
            : SizedBox(
                height: 0.0,
              )
      ],
    );
  }

  void _begeniDegistir() {
    if (_begendin) {
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
      });
      FireStoreServisi().gonderiBegeniKaldir(widget.gonderi, _aktifKullaniciId);
    } else {
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FireStoreServisi().gonderiBegen(widget.gonderi, _aktifKullaniciId);
    }
  }
}
