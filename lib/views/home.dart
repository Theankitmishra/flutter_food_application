import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/auth.dart';

class HomePage extends StatefulWidget {
  HomePage(
      {Key? key,
      required this.auth,
      required this.userId,
      required this.logoutCallback})
      : super(key: key);

  final Authentication auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Product> _productList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  late StreamSubscription<Event> _onTodoAddedSubscription;
  late StreamSubscription<Event> _onTodoChangedSubscription;

  late Query _todoQuery;

  //bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();

    _productList = [];
    _todoQuery = _database
        .reference()
        .child("todo")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _productList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _productList[_productList.indexOf(oldEntry)] =
          Product.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _productList.add(Product.fromSnapshot(event.snapshot));
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  showAddTodoDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Add new todo',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget showTodoList() {
    if (_productList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _productList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _productList[index].key;
            String subject = _productList[index].name;
            String completed = _productList[index].description;
            double userId = _productList[index].price;
            return Dismissible(
              key: Key(todoId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {},
              child: ListTile(
                title: Text(
                  subject,
                  style: const TextStyle(fontSize: 20.0),
                ),
                trailing: IconButton(
                    icon: (true)
                        ? const Icon(
                            Icons.done_outline,
                            color: Colors.green,
                            size: 20.0,
                          )
                        : const Icon(Icons.done,
                            color: Colors.grey, size: 20.0),
                    onPressed: () {}),
              ),
            );
          });
    } else {
      return const Center(
          child: Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter login demo'),
          actions: <Widget>[
            TextButton(
                child: const Text('Logout',
                    style: TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body: showTodoList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddTodoDialog(context);
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}
