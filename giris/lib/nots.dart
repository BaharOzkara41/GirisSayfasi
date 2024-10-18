import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Not Defteri',
      home: NotDefteriSayfasi(),
    );
  }
}

class NotDefteriSayfasi extends StatefulWidget {
  @override
  _NotDefteriSayfasiState createState() => _NotDefteriSayfasiState();
}

class _NotDefteriSayfasiState extends State<NotDefteriSayfasi> {
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _metinController = TextEditingController();
  List<String> _notlar = [];
  int? _duzenlenecekIndex;
  bool _isFormVisible = false;

  @override
  void initState() {
    super.initState();
    _loadNotlar();
  }

  Future<void> _loadNotlar() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      String? notlarJson = preferences.getString('notlar');
      if (notlarJson != null) {
        _notlar = List<String>.from(jsonDecode(notlarJson));
      }
    });
  }

  Future<void> _ekle() async {
    String baslik = _baslikController.text;
    String metin = _metinController.text;

    if (baslik.isNotEmpty && metin.isNotEmpty) {
      setState(() {
        if (_duzenlenecekIndex != null) {
          _notlar[_duzenlenecekIndex!] = '$baslik: $metin';
          _duzenlenecekIndex = null;
        } else {
          _notlar.add('$baslik: $metin');
        }
        _isFormVisible = false;
      });
      _baslikController.clear();
      _metinController.clear();

      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString('notlar', jsonEncode(_notlar));
    }
  }

  Future<void> _sil(int index) async {
    setState(() {
      _notlar.removeAt(index);
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('notlar', jsonEncode(_notlar));
  }

  void _duzenle(int index) {
    setState(() {
      var parts = _notlar[index].split(': ');
      _baslikController.text = parts[0];
      _metinController.text = parts.length > 1 ? parts[1] : '';
      _duzenlenecekIndex = index;
      _isFormVisible = true;
    });
  }

  Widget _noteListTile(String not, int index) {
    var parts = not.split(': ');
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.cyanAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  parts[0],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _duzenle(index),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _sil(index),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(parts.length > 1 ? parts[1] : ''),
        ],
      ),
    );
  }

  void _yeniNotEkle() {
    _baslikController.clear();
    _metinController.clear();
    _duzenlenecekIndex = null;
    setState(() {
      _isFormVisible = true;
    });
  }

  void _notEklemeKapat() {
    setState(() {
      _isFormVisible = false;
      _baslikController.clear();
      _metinController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text('Not Defteri'),
        titleTextStyle: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
          fontSize: 25,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (_isFormVisible)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(100, 242, 155, 255),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _baslikController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Notunuzun başlığını giriniz',
                        fillColor: Colors.purpleAccent,
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _metinController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Notunuzu giriniz',
                        fillColor: Colors.purple,
                        filled: true,
                      ),
                      maxLines: 8,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white54,
                      ),
                      onPressed: _ekle,
                      child: Text(_duzenlenecekIndex != null ? 'Düzenle' : 'Ekle'),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: _yeniNotEkle,
                  child: Text('Yeni Not Ekle'),
                ),
                if (_isFormVisible)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.cyanAccent,
                    ),
                    onPressed: _notEklemeKapat,
                    child: Text('Not Ekleme İptal'),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _notlar.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _noteListTile(_notlar[index], index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}