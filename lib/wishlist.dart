import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled/productdesc.dart';
import 'package:http/http.dart' as http;

class Wishlist extends StatefulWidget {
  const Wishlist({Key? key, required this.username, required this.idToken}) : super(key: key);

  final String username;
  final String idToken;
  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  List items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getItems();
  }

  getItems() async {
    final response = await getWishlist(widget.idToken, widget.username);
    final body = jsonDecode(response.body) as List;
    setState(() {
      items = body;
    });
  }

  @override
  Widget build(BuildContext context) {
    getItems();
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,16.0,0,0),
                child: Text("${widget.username}'s Wishlist", style: TextStyle(fontSize: 20, color: Colors.black54  , fontWeight: FontWeight.w700),),
              ),
              width: double.infinity,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,16.0,0,0),
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    // print(items.length);
                    final item = items[index];

                    return ListTile(
                      title: Text(item["ItemName"], style: TextStyle(fontSize: 23, color: Colors.blueAccent), textAlign: TextAlign.left,),
                      subtitle: Text(item["ItemType"], style: TextStyle(fontSize: 16, color: Colors.black54), textAlign: TextAlign.left,),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDesc(productDetails: item, username: widget.username, idToken: widget.idToken, favourite: true,),
                          ),
                        );
                      },
                      leading: Image.network(item["Image1"].split("?")[0]),
                      trailing: IconButton(
                        icon: Icon(Icons.favorite, color: Colors.red),
                            // : Icon(Icons.favorite_border),
                        onPressed: () async {
                          //add to wishlist
                          setState(() {
                            items.removeAt(index);
                          });
                        },
                      ),
                    );
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

Future<http.Response> getWishlist(String idToken, String username) {
  return http.get(
    Uri.parse(
        'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/product/getWishlist')
        .replace(queryParameters: {"UserId": username}),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-api-key': 'c5ec1kyeAD1GADOf9l1qR7lBJOjC8WSK26ryi0lE',
      'Auth': idToken
    },
  );
}
