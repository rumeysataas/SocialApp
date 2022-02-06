//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

class Duyuru {
  final String id;
  final String aktiviteYapanId;
  final String akticiteTipi;
  final String gonderiId;
  final String gonderiFoto;
  final String yorum;
  final Timestamp olusturulmaZamani;

  Duyuru(
      {this.id,
      this.aktiviteYapanId,
      this.akticiteTipi,
      this.gonderiId,
      this.gonderiFoto,
      this.yorum,
      this.olusturulmaZamani});

  factory Duyuru.dokumandanUret(DocumentSnapshot doc) {
    return Duyuru(
      id: doc.documentID,
      aktiviteYapanId: doc['aktiviteYapanId'],
      akticiteTipi: doc['aktiviteTipi'],
      gonderiId: doc['gonderiId'],
      gonderiFoto: doc['gonderiFoto'],
      yorum: doc['yorum'],
      olusturulmaZamani: doc['olusturulmaZamani'],
    );
  }
}
