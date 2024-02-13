import 'package:firebase_database/firebase_database.dart';

class Product {
  String key;
  double price;
  String name;
  String description;
  String image;
  int stock;

  Product({
    required this.key,
    required this.price,
    required this.name,
    required this.description,
    required this.image,
    required this.stock,
  });

  Product.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        price = snapshot.value['price'],
        name = snapshot.value['name'],
        description = snapshot.value['description'],
        image = snapshot.value['image'],
        stock = snapshot.value['stock'];

  toJson() {
    return {
      "price": price,
      "name": name,
      "description": description,
      "image": image,
      "stock": stock
    };
  }
}
