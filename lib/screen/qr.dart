import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:winged/screen/cart_items.dart';
import 'package:hexcolor/hexcolor.dart';

class Qr extends StatefulWidget {
  const Qr({Key key}) : super(key: key);

  @override
  _QrState createState() => _QrState();
}

class _QrState extends State<Qr> {
  String _scanBarcode = 'Unknown';
  int quantity = 1;
  final db = FirebaseFirestore.instance;
  FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  _showToast(num val) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high_outlined),
          SizedBox(
            width: 12.0,
          ),
          (val == 1)
              ? Text("Minimum quality is 1")
              : (val == 20)
                  ? Text("Maximum quality at once is 20")
                  : Text(""),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      showdialog();
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;
    setState(() {
      _scanBarcode = barcodeScanRes;
      showdialog();
    });
  }

  void showdialog() {
    showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: (Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: 100, bottom: 16, left: 16, right: 16),
                    margin: EdgeInsets.only(top: 16),
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
                        Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: HexColor("#30C591"),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          ' PRODUCT ',
                          style: TextStyle(
                            fontSize: 20.0,
                            //backgroundColor: HexColor("#30C591"),
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          _scanBarcode,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Text(
                          ' QUANTITY ',
                          style: TextStyle(
                            fontSize: 20.0,
                            //backgroundColor: HexColor("#30C591"),
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          //margin: EdgeInsets.all(0),
                          padding: EdgeInsets.only(
                              left: 90, top: 10, right: 90, bottom: 0),
                          child: NumberInputPrefabbed.roundedButtons(
                            scaleHeight: 0.9,
                            controller: TextEditingController(),
                            incIconColor: HexColor('#30C591'),
                            decIconColor: HexColor('#30C591'),
                            initialValue: 1,
                            min: 1,
                            max: 20,
                            onIncrement: (num val) {
                              quantity = val;
                              if (val == 20) {
                                _showToast(val);
                              }
                            },
                            onDecrement: (num val) {
                              quantity = val;
                              if (val == 1) {
                                _showToast(val);
                              }
                            },
                            onSubmitted: (num val) {
                              quantity = val;
                            },
                            numberFieldDecoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                                borderSide: BorderSide(
                                    color: HexColor('#30C591'), width: 2.0),
                              ),
                            ),
                            decIconSize: 25,
                            incIconSize: 25,
                            buttonArrangement:
                                ButtonArrangement.incRightDecLeft,
                          ),
                        ),
                        SizedBox(
                          height: 24.0,
                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () {
                                if (quantity > 0) {
                                  db.collection('User_products').add({
                                    'Product_code': _scanBarcode,
                                    'name': '',
                                    'quantity': quantity,
                                    'datetime': DateTime.now()
                                  });
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.pink,
                                      content: const Text(
                                        'Quantity should be greater than 0',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            40.0, // Inner padding for SnackBar content.
                                      ),
                                      duration:
                                          const Duration(milliseconds: 1500),
                                      width: 280.0, // Width of the SnackBar.
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text('ADD'),
                              style: ElevatedButton.styleFrom(
                                  primary: HexColor("#30C591"),
                                  onPrimary: Colors.white),
                            )),
                      ],
                    ),
                  ),
                  Positioned(
                      top: 2,
                      left: 16,
                      right: 16,
                      child: CircleAvatar(
                        //backgroundColor: Colors.lightBlueAccent,
                        radius: 50.0,
                        backgroundImage: AssetImage('assets/gif/addcart.gif'),
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
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          scanBarcodeNormal();
                        },
                        child: Text('Barcode Scan')),
                    ElevatedButton(
                        onPressed: () => scanQR(), child: Text(' QR  Scan')),
                  ],
                ),
                SizedBox(height: 24),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.label_important,
                      color: Colors.redAccent,
                    ),
                    Text('if Barcode/Qrcode not recognized click here',
                        style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

/*void showdialog() {
    showDialog(
        context: context,
        builder: (context) {
          return (AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Text('Add Product'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                    _scanBarcode,
                    style: TextStyle(fontSize: 30),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    db.collection('User_products').add({
                      'Product_code': _scanBarcode,
                      'name': '',
                      'quantity': 1,
                      'datetime': DateTime.now()
                    });
                    Navigator.pop(context);
                  },
                  child: Text('ADD'))
            ],
          ));
        });
  }

  floatingActionButton: FloatingActionButton(
            child: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => cart()));
            },
          )



  */
