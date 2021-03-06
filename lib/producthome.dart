import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled/productdesc.dart';
import 'package:http/http.dart' as http;

class ProductHome extends StatefulWidget {
  const ProductHome({Key? key, required this.idToken, required this.username})
      : super(key: key);
  final String idToken;
  final String username;

  @override
  State<ProductHome> createState() => _ProductHomeState();
}

class _ProductHomeState extends State<ProductHome> {
  TextEditingController searchController = TextEditingController();

  List items = [];
  List dbItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getItems();
  }

  getItems() async {
    final response = await search(widget.idToken, {"userId": widget.username});
    final body = jsonDecode(response.body) as List;
    setState(() {
      items = body;
      dbItems = body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
        child: Column(
          children: <Widget>[
            Focus(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  labelText: 'Search',
                  suffixIcon: searchController.text.isEmpty
                      ? null // Show nothing if the text field is empty
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                            getItems();
                          },
                        ),
                ),
              ),
              onFocusChange: (hasFocus) async {
                if (!hasFocus) {
                  final response = await search(widget.idToken, {
                    "name": searchController.text,
                    "userId": widget.username
                  });
                  final body = jsonDecode(response.body) as List;
                  setState(() {
                    items = body;
                    dbItems = body;
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionChip(
                    label: const Text('Veg'),
                    onPressed: () {
                      List filteredItems = dbItems
                          .where(
                              (element) => element["ItemType"] == "vegetarian")
                          .toList();
                      setState(() {
                        items = filteredItems;
                      });
                    },
                  ),
                  ActionChip(
                    label: const Text('Non-Veg'),
                    onPressed: () {
                      List filteredItems = dbItems
                          .where((element) =>
                              element["ItemType"] == "non-vegetarian")
                          .toList();
                      setState(() {
                        items = filteredItems;
                      });
                    },
                  ),
                  ActionChip(
                    label: const Text('Vegan'),
                    onPressed: () {
                      List filteredItems = dbItems
                          .where((element) => element["ItemType"] == "vegan")
                          .toList();
                      setState(() {
                        items = filteredItems;
                      });
                    },
                  ),
                  ActionChip(
                    label: const Text('Egg'),
                    onPressed: () {
                      List filteredItems = dbItems
                          .where((element) => element["ItemType"] == "egg")
                          .toList();
                      setState(() {
                        items = filteredItems;
                      });
                    },
                  ),
                  ActionChip(
                    label: const Text('Halal'),
                    onPressed: () {
                      List filteredItems = dbItems
                          .where((element) => element["ItemType"] == "halal")
                          .toList();
                      setState(() {
                        items = filteredItems;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  searchController.text.isEmpty ? "Recommended" : "Results",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700),
                ),
              ),
              width: double.infinity,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    // print(items.length);
                    final item = items[index];

                    return ListTile(
                      title: Text(
                        item["ItemName"],
                        style:
                            TextStyle(fontSize: 23, color: Colors.blueAccent),
                        textAlign: TextAlign.left,
                      ),
                      subtitle: Text(
                        item["ItemType"],
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.left,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDesc(
                              idToken: widget.idToken,
                              productDetails: item,
                              username: widget.username,
                              favourite: false,
                            ),
                          ),
                        );
                      },
                      leading: Image.network(item["Image1"].split("?")[0]),
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

Future<http.Response> search(String idToken, Map<String, dynamic> params) {
  return http.get(
    Uri.parse(
            'https://q6ed0onbpd.execute-api.us-east-1.amazonaws.com/dev/api/product/search')
        .replace(queryParameters: params),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-api-key': '****',
      'Auth': idToken
    },
  );
}
