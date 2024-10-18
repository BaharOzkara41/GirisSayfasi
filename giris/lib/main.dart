import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nots.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giriş Ekranı',
      home: GirisSayfasi(),
    );
  }
}

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final TextEditingController _kullaniciA = TextEditingController();
  final TextEditingController _sifre = TextEditingController();
  String _mesaj = '';
  bool _beniHatirla = false;

  @override
  void initState() {
    super.initState();
    _kullaniciKayitlari();
  }

  Future<void> _kullaniciKayitlari() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? kullaniciJson = preferences.getString('kullanici');
    String? sifreJson = preferences.getString('sifre');
    if (kullaniciJson != null && sifreJson != null) {
      _kullaniciA.text = kullaniciJson;
      _sifre.text = sifreJson;
      _beniHatirla = true;
    }
  }

  Future<void> _girisYap() async {
    String _kullanici = _kullaniciA.text;
    String _sifreText = _sifre.text;

    if (_kullanici == 'admin' && _sifreText == 'admin') {
      setState(() {
        _mesaj = 'Giriş yapıldı!';
      });

      if (_beniHatirla) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('kullanici', _kullanici);
        preferences.setString('sifre', _sifreText);
      } else {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.remove('kullanici');
        preferences.remove('sifre');
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotDefteriSayfasi()),
      );
    } else {
      setState(() {
        _mesaj = 'Kullanıcı adı veya şifre hatalı, tekrar deneyiniz.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _kullaniciA,
              decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
            ),
            TextField(
              controller: _sifre,
              decoration: InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            Row(
              children: [
                Checkbox(
                  value: _beniHatirla,
                  onChanged: (bool? value) {
                    setState(() {
                      _beniHatirla = value ?? false;
                    });
                  },
                ),
                Text('Beni Hatırla'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _girisYap,
              child: Text('Giriş Yap'),
            ),
            SizedBox(height: 20),
            Text(
              _mesaj,
              style: TextStyle(
                color: _mesaj == 'Giriş yapıldı!' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}