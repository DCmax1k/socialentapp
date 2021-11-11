import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

class AccountContainer extends StatefulWidget {
  const AccountContainer(this.user, {Key? key}) : super(key: key);

  final Map user;

  @override
  _AccountContainerState createState() => _AccountContainerState();
}

class _AccountContainerState extends State<AccountContainer> {
  Map user = {};
  List accountsFollowers = [];
  List accountsFollowing = [];
  List accountsPosts = [];

  logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('postsFollowing');
    Navigator.pushReplacementNamed(context, '/index');
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    // Initial functions for posts
    gettingsPrefsData() async {
      final prefs = await SharedPreferences.getInstance();
      // set state with current saved data
      final stringAccountsFollowers =
          prefs.getString('accountsFollowers') ?? '';
      final stringAccountsFollowing =
          prefs.getString('accountsFollowing') ?? '';
      final stringAccountsPosts = prefs.getString('accountsPosts') ?? '';
      setState(() {
        accountsFollowers = stringAccountsFollowers.isNotEmpty
            ? jsonDecode(stringAccountsFollowers)
            : [];
        accountsFollowing = stringAccountsFollowing.isNotEmpty
            ? jsonDecode(stringAccountsFollowing)
            : [];
        accountsPosts = stringAccountsPosts.isNotEmpty
            ? jsonDecode(stringAccountsPosts)
            : [];
      });
    }

    gettingsPrefsData();

    // Start functions
    updateUserIfNeeded();
    updateAccountData();
  }

  updateUserIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    // get user from prefs
    final userPref = prefs.getString('user') ?? jsonEncode(user);
    if (!mapEquals(user, jsonDecode(userPref))) {
      setState(() {
        user = jsonDecode(userPref);
      });
    }
  }

  updateAccountData() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    // get new data from server
    http.Response response = await http.post(
        Uri.parse(
            'https://www.socialentapp.com/account/${user['username']}/getfromapp'),
        body: {
          'auth_token': authToken,
        });
    Map resJSON = jsonDecode(response.body);
    // update values
    final newPrefs = await SharedPreferences.getInstance();
    await newPrefs.setString('user', jsonEncode(resJSON['user']));
    await newPrefs.setString(
        'accountsFollowing', jsonEncode(resJSON['accountsFollowing']));
    await newPrefs.setString(
        'accountsFollowers', jsonEncode(resJSON['accountsFollowers']));
    await newPrefs.setString(
        'accountsPosts', jsonEncode(resJSON['accountsPosts']));
    if (user.toString().length != resJSON['user'].toString().length ||
        accountsFollowers.toString().length !=
            resJSON['accountsFollowers'].toString().length ||
        accountsPosts.toString().length !=
            resJSON['accountsPosts'].toString().length ||
        accountsFollowing.toString().length !=
            resJSON['accountsFollowing'].toString().length) {
      if (!mounted) return;
      setState(() {
        user = resJSON['user'];
        accountsFollowers = resJSON['accountsFollowers'];
        accountsFollowing = resJSON['accountsFollowing'];
        accountsPosts = resJSON['accountsPosts'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
          child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => updateAccountData(),
            color: Color.fromRGBO(180, 221, 255, 1.0),
            backgroundColor: Color.fromRGBO(15, 76, 117, 1),
            child: ListView(
              children: [
                Column(
                  children: [
                    // Profile half
                    Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(children: [
                          // Profile image + posts, followers, following half
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Profile image
                                Container(
                                  clipBehavior: Clip.none,
                                  height: 120,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        clipBehavior: Clip.hardEdge,
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10000),
                                        ),
                                        child: user['profileImg'] != 'none'
                                            ? user['profileImg']
                                                    .contains('http')
                                                ? Image.network(
                                                    user['profileImg'])
                                                : Image.memory(
                                                    base64.decode(
                                                        user['profileImg']
                                                            .split(',')
                                                            .last),
                                                  )
                                            : Image.asset(
                                                'assets/profilePlaceholder.png',
                                              ),
                                      ),
                                      Container(
                                        child: Text(
                                          'Online',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Posts
                                Container(
                                  height: 70,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${accountsPosts.length}',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 30,
                                        ),
                                      ),
                                      Text(
                                        'Posts',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Followers
                                Container(
                                  height: 70,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${accountsFollowers.length}',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 30,
                                        ),
                                      ),
                                      Text(
                                        'Follower${accountsFollowers.length == 1 ? '' : 's'}',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Following
                                Container(
                                  height: 70,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${accountsFollowing.length}',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 30,
                                        ),
                                      ),
                                      Text(
                                        'Following',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          // Name, Username, Description half
                          Container(
                            width: MediaQuery.of(context).size.width - 50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Prefix + name + username + verified?
                                RichText(
                                  // Preifx
                                  text: TextSpan(
                                    text: user['prefix']['title'].isNotEmpty
                                        ? '[${user['prefix']['title']}]'
                                        : '',
                                    style: TextStyle(
                                      color: user['rank'] == 'owner'
                                          ? Colors.red
                                          : user['rank'] == 'admin'
                                              ? Colors.blue
                                              : Colors.green,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    children: [
                                      // Name
                                      TextSpan(
                                        text: ' ${user['name']}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      // Username
                                      TextSpan(
                                        text: ' @${user['username']}',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Verified?
                                      if (user['verified'] == true)
                                        WidgetSpan(
                                          child: SizedBox(
                                            width: 3,
                                          ),
                                        ),
                                      if (user['verified'] == true)
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: Offset(0, -3),
                                            child: Image.asset(
                                              'assets/verified.png',
                                              height: 15,
                                              width: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                // Description
                                Container(
                                  width: MediaQuery.of(context).size.width - 50,
                                  child: Text('${user['description']}'),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                // Edit Profile Btn
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/editprofile',
                                        arguments: {
                                          'user': user,
                                        });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[850],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: Colors.grey[850],
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ])),
                    // Posts half
                    Container(),
                  ],
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class EditProfileCont extends StatefulWidget {
  EditProfileCont({Key? key}) : super(key: key);

  @override
  _EditProfileContState createState() => _EditProfileContState();
}

class _EditProfileContState extends State<EditProfileCont> {
  Map user = {};
  Map data = {};
  IconData _pencilIcon = Icons.create;
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    // Get previous page data
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)!.settings.arguments != null
            ? ModalRoute.of(context)!.settings.arguments as Map
            : {};
    user = data.isNotEmpty ? data['user'] : {};
    _usernameController.value = TextEditingValue(text: user['username']);
    _nameController.value = TextEditingValue(text: user['name']);
    _emailController.value = TextEditingValue(text: user['emailData']['email']);
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
          backgroundColor: Colors.grey[800],
          titleTextStyle: TextStyle(
            color: Colors.white,
          ),
          brightness: Brightness.dark,
        ),
        backgroundColor: Colors.grey[850],
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              // Username
              Container(
                key: Key('username'),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Pencil
                    Icon(
                      _pencilIcon,
                      color: Colors.blue,
                      size: 40,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    // Input
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: TextField(
                        onSubmitted: (value) {
                          print(value);
                        },
                        controller: _usernameController,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 20,
                        ),
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          hintText: 'Username...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Name
              Container(
                key: Key('name'),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Pencil
                    Icon(
                      _pencilIcon,
                      color: Colors.blue,
                      size: 40,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    // Input
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: TextField(
                        onSubmitted: (value) {
                          print(value);
                        },
                        controller: _nameController,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 20,
                        ),
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          hintText: 'Name...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Email
              Container(
                key: Key('email'),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Pencil
                    Icon(
                      _pencilIcon,
                      color: Colors.blue,
                      size: 40,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    // Input
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: TextField(
                        onSubmitted: (value) {
                          print(value);
                        },
                        controller: _emailController,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 20,
                        ),
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          hintText: 'Email...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 20,
                          ),
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
