import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:winged/screen/building.dart';
import 'package:winged/screen/building_screen.dart';
import 'cart_items.dart';
import 'qr.dart';

class Start extends StatefulWidget {
  String num;
  Start({Key key, @required this.num}) : super(key: key);

  @override
  _StartState createState() => _StartState(num);
}

class _StartState extends State<Start> {
  String num;
  int _currentIndex = 1;
  _StartState(this.num);
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final tabs = [
    Center(
      child: Text('Home'),
    ),
    Qr(),
    cart()
  ];
  void showdialog(String points) {
    showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: (Dialog(
              insetPadding:
                  EdgeInsets.only(top: 100, bottom: 20, left: 30, right: 30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: 100, bottom: 16, left: 16, right: 16),
                    margin: EdgeInsets.only(top: 50),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: Offset(0.0, 10.0))
                        ]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 60.0),
                        Text(
                          'Your Wing\'ed Points',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: HexColor("#30C591"),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          points,
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 25.0),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Done'),
                              style: ElevatedButton.styleFrom(
                                  primary: HexColor("#30C591"),
                                  onPrimary: Colors.white),
                            )),
                      ],
                    ),
                  ),
                  Positioned(
                      top: 10,
                      left: 16,
                      right: 16,
                      child: CircleAvatar(
                        //backgroundColor: Colors.lightBlueAccent,
                        radius: 80.0,
                        backgroundImage: AssetImage('assets/gif/points.gif'),
                      ))
                ],
              ),
            )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          drawer: StreamBuilder(
            stream: db
                .collection("Users")
                .where('mobile', isEqualTo: num)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return new Container(child: Text('loading...'));
              return Drawer(
                elevation: 20,
                child: Column(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      accountName: Text(snapshot.data.docs[0]['name']),
                      accountEmail: Text(snapshot.data.docs[0]['mobile']),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    ListTile(
                      title: Text('Winged Points'),
                      leading: Icon(Icons.score_outlined),
                      onTap: () {
                        showdialog(snapshot.data.docs[0]['points']);
                      },
                    ),
                    Divider(
                      height: 0.1,
                    ),
                    ListTile(
                      title: Text('History'),
                      leading: Icon(Icons.history),
                    ),
                    Divider(
                      height: 0.1,
                    ),
                    ListTile(
                      title: Text('Terms & Conditions'),
                      leading: Icon(Icons.book_outlined),
                    ),
                    Divider(
                      height: 0.1,
                    ),
                    ListTile(
                      title: Text('About us'),
                      leading: Icon(Icons.people_outline),
                    ),
                    Divider(
                      height: 0.1,
                    )
                  ],
                ),
              );
            },
          ),
          appBar: AppBar(
            title: Text('Wing\'ed',
                style: GoogleFonts.pacifico(
                    fontStyle: FontStyle.italic, fontSize: 25.0)),
            backgroundColor: Colors.lightBlueAccent,
            centerTitle: true,
          ),
          backgroundColor: Colors.lightBlueAccent,
          bottomNavigationBar: CurvedNavigationBar(
            index: _currentIndex,
            backgroundColor: Colors.lightBlueAccent,
            items: <Widget>[
              Icon(Icons.list, size: 30),
              Icon(Icons.qr_code, size: 25),
              Icon(Icons.shopping_cart, size: 30),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              _currentIndex = index;
              /*if (index == 1) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Qr()));
            }*/
            },
          ),
          body: tabs[_currentIndex],
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => BuildingScreen()));
            },
          )),
    );
  }
}

/*
currentAccountPicture: GestureDetector(
                        onTap: () async {
                          final pickedFile = await picker.getImage(
                              source: ImageSource.gallery);
                          setState(() {
                            if (pickedFile != null) {
                              _image = File(pickedFile.path);
                            } else {
                              print('No image selected.');
                            }
                            Reference storageReference =
                                storage.ref().child('Profile_pic/${num}');
                            UploadTask uploadTask =
                                storageReference.putFile(_image);
                            print('File Uploaded');
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child:
                              (snapshot.data.docs[0]['name'].toString() == "")
                                  ? "DP"
                                  : Text(
                                      snapshot.data.docs[0]['name']
                                          .toString()
                                          .substring(1, 2)
                                          .toUpperCase(),
                                      style: TextStyle(fontSize: 35),
                                    ),
                        ),
                      ),
 */
