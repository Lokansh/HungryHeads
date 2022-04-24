import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDesc extends StatefulWidget {
  const ProductDesc(
      {Key? key,
      required this.productDetails,
      required this.idToken,
      required this.username,
      required this.favourite})
      : super(key: key);

  final String idToken;
  final Map<String, dynamic> productDetails;
  final String username;
  final bool favourite;

  @override
  State<ProductDesc> createState() => _ProductDescState();
}

class _ProductDescState extends State<ProductDesc> {
  late bool favourite;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      favourite = widget.favourite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(title: Text(widget.productDetails["ItemName"])),
      appBar: AppBar(
        title: Text(widget.productDetails["ItemName"]),
        actions: [
          IconButton(
            icon: favourite
                ? Icon(Icons.favorite, color: Colors.red)
                : Icon(Icons.favorite_border),
            onPressed: () async {
              var details = widget.productDetails;
              details["UserId"] = widget.username;
              if (favourite == true) {
                final response = await removeFromWishlist(widget.idToken, {
                  "wishlistId":
                      widget.username + widget.productDetails["ItemId"]
                });
              } else {
                final response =
                    await addToWishlist(widget.idToken, widget.productDetails);
              }
              setState(() {
                favourite = !favourite;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text("Product Type",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54)),
                  Text(widget.productDetails["ItemType"],
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueAccent)),
                  // Text(widget.productDetails["ItemType"], style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Colors.blueAccent)),
                ],
              ),
              Image.network(widget.productDetails["Image1"].split("?")[0]),
              Column(
                children: [
                  Text("Ingredients",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54)),
                  // Text(widget.productDetails["Ingreds"].join(","), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400, color: Colors.black), textAlign: TextAlign.center,),
                  Text(
                    widget.productDetails["Ingreds"].join(","),
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  Text("Added by",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54)),
                  Text(widget.productDetails["User"],
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueAccent)),
                  // Text(widget.productDetails["ItemType"], style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Colors.blueAccent)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<http.Response> addToWishlist(String idToken, Object body) {
  return http.post(
      Uri.parse(
          'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/product/addWishlist'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': '****',
        'Auth': idToken
      },
      body: jsonEncode(body));
}

Future<http.Response> removeFromWishlist(
    String idToken, Map<String, dynamic> params) {
  return http.delete(
      Uri.parse(
              'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/product/deleteWishlist')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': '****',
        'Auth': idToken
      });
}
