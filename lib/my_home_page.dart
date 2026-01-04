import 'package:flutter/material.dart';
import 'package:et_learn/authentication/auth.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Facebook"),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.search), onPressed: () => {}),
          IconButton(icon: const Icon(Icons.menu), onPressed: () => {}),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Top nav bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(icon: const Icon(Icons.home), onPressed: () => {}),
                  IconButton(
                    icon: const Icon(Icons.group),
                    onPressed: () => {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.messenger_rounded),
                    onPressed: () => {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.ondemand_video),
                    onPressed: () => {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.storefront),
                    onPressed: () => {},
                  ),
                ],
              ),

              // What's in your mind
              Row(
                children: [
                  CircleAvatar(
                    radius: 20, // Adjust size as needed
                    backgroundImage: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKaiKiPcLJj7ufrj6M2KaPwyCT4lDSFA5oog&s',
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: Container(
                      margin: EdgeInsets.all(8),
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          hintText: 'What\'s on your mind, Sir?',
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Stories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/Profile image.png",
                      width: 103,
                      height: 148,
                    ),
                    Image.asset(
                      "assets/images/Profile image.png",
                      width: 103,
                      height: 148,
                    ),
                    Image.asset(
                      "assets/images/Profile image.png",
                      width: 103,
                      height: 148,
                    ),
                    Image.asset(
                      "assets/images/Profile image.png",
                      width: 103,
                      height: 148,
                    ),
                  ],
                ),
              ),

              // Posts
              Container(
                padding: EdgeInsets.all(6),
                margin: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                child: Column(
                  children: [
                    // Poster profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20, // Adjust size as needed
                              backgroundImage: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKaiKiPcLJj7ufrj6M2KaPwyCT4lDSFA5oog&s',
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(8),
                              child: Column(
                                children: [Text("USERNAME"), Text("Oct 12")],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => {},
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    Image.asset(
                      "assets/images/Car.png",
                      width: 390,
                      height: 250,
                    ),
                    Text("Old is Gold..!!"), // Description
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                margin: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                child: Column(
                  children: [
                    // Poster profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20, // Adjust size as needed
                              backgroundImage: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKaiKiPcLJj7ufrj6M2KaPwyCT4lDSFA5oog&s',
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(8),
                              child: Column(
                                children: [Text("USERNAME"), Text("Oct 12")],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => {},
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    Image.asset(
                      "assets/images/Car.png",
                      width: 390,
                      height: 250,
                    ),
                    Text("Old is Gold..!!"), // Description
                  ],
                ),
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: OutlinedButton(
                        onPressed: Auth().signOut,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3D5CFF)),
                        ),
                        child: Text(
                          "Sign out",
                          style: TextStyle(color: Color(0xFF3D5CFF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
