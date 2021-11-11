import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:socialentapp/pages/account.dart';
import 'package:socialentapp/pages/search.dart';
import 'package:socialentapp/pages/create.dart';
import 'package:socialentapp/pages/messages.dart';
import 'package:socialentapp/partials/post.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Map user = {};
  // List postsFollowing = [];
  String authToken = '';
  Map data = {};
  Map user = {};
  final keyMainScreen = GlobalKey<_MainScreenContainerState>();
  final keyNavBar = GlobalKey<_NavBarState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)!.settings.arguments != null
            ? ModalRoute.of(context)!.settings.arguments as Map
            : {};
    user = data.isNotEmpty ? data['user'] : {};

    return Container(
      child: Stack(
        children: [
          Column(
            children: [
              // Two background colors under home page
              Expanded(
                  flex: 20,
                  child: Container(
                      color: Colors.grey[200],
                      width: MediaQuery.of(context).size.width)),
              Expanded(
                  flex: 1,
                  child: Container(
                      color: Color.fromRGBO(15, 76, 117, 1),
                      width: MediaQuery.of(context).size.width)),
            ],
          ),
          Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    flex: 12,
                    child: MainScreenContainer(user, keyNavBar,
                        key: keyMainScreen),
                  ),
                  // Icons at bottomj
                  // Dark color
                  // Color.fromRGBO(15, 76, 117, 1)
                  // Light color
                  // Color.fromRGBO(180, 221, 255, 1.0)
                  Expanded(
                    flex: 1,
                    child: NavBar(
                        keyMainScreen: keyMainScreen,
                        user: user,
                        key: keyNavBar),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBar extends StatefulWidget {
  const NavBar({
    Key? key,
    required this.keyMainScreen,
    required this.user,
  }) : super(key: key);

  final GlobalKey<_MainScreenContainerState> keyMainScreen;
  final Map user;

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String currentPage = 'home';
  List redirectPageIcons = [
    'home',
    'search',
    'create',
    'messages',
    'account',
  ];
  void redirectPage(page) {
    String newPage = page == 0
        ? 'home'
        : page == 1
            ? 'search'
            : page == 2
                ? 'create'
                : page == 3
                    ? 'messages'
                    : 'account';
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(15, 76, 117, 1),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: redirectPageIcons.map<Widget>((icon) {
            // if (icon != 'account') {
            return Container(
              width: MediaQuery.of(context).size.width / 5,
              height: 100,
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0.0),
                  backgroundColor:
                      MaterialStateProperty.all(Color.fromRGBO(15, 76, 117, 1)),
                  fixedSize: MaterialStateProperty.all(Size(2, 2)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                    ),
                  ),
                ),
                onPressed: () {
                  // REDIRECT HERE
                  int page = icon == 'home'
                      ? 0
                      : icon == 'search'
                          ? 1
                          : icon == 'create'
                              ? 2
                              : icon == 'messages'
                                  ? 3
                                  : 4;
                  widget.keyMainScreen.currentState!._pageController
                      .animateToPage(page,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  height: icon == currentPage ? 50 : 40,
                  width: icon == currentPage ? 50 : 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Color.fromRGBO(180, 221, 255, 1.0),
                  ),
                  child: Icon(
                    icon == 'home'
                        ? Icons.home
                        : icon == 'search'
                            ? Icons.search
                            : icon == 'create'
                                ? Icons.add
                                : icon == 'messages'
                                    ? Icons.message
                                    : Icons.person,
                    size: 25,
                    color: Color.fromRGBO(15, 76, 117, 1),
                  ),
                ),
              ),
            );
          }).toList()),
    );
  }
}

// MAINSCREENCONTAINER
class MainScreenContainer extends StatefulWidget {
  MainScreenContainer(this.user, this.navBarState, {Key? key})
      : super(key: key);
  final Map user;
  final navBarState;

  @override
  _MainScreenContainerState createState() => _MainScreenContainerState();
}

class _MainScreenContainerState extends State<MainScreenContainer> {
  PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: (page) {
        widget.navBarState.currentState!.redirectPage(page);
      },
      children: [
        SafeArea(
          child: HomeContainer(widget.user),
        ),
        SearchContainer(),
        CreateContainer(),
        MessagesContainer(widget.user),
        AccountContainer(widget.user),
      ],
    );
  }
}

// HOME
class HomeContainer extends StatefulWidget {
  HomeContainer(this.user);
  final Map user;

  @override
  _HomeContainerState createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  Map user = {};
  List postsFollowing = [];
  bool gotInitData = false;
  final keyEditDescription = GlobalKey<_EditDescriptionState>();

  @override
  void initState() {
    super.initState();
    getData() async {
      await getSavedData();
      await getHomeData();
    }

    getData();
  }

  getSavedData() async {
    // Get saved data from shared prefs
    final prefs = await SharedPreferences.getInstance();
    final stringPosts = prefs.getString('postsFollowing') ?? '';
    setState(() {
      postsFollowing = stringPosts.isNotEmpty ? jsonDecode(stringPosts) : [];
    });
  }

  Future<void> getHomeData() async {
    // Get updated data from server
    String postURL = 'https://www.socialentapp.com/home/getfromapp';
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    Response response = await post(Uri.parse(postURL), body: {
      'auth_token': authToken,
    });
    Map dataGot = jsonDecode(response.body);
    final pref = await SharedPreferences.getInstance();
    await pref.setString(
        'postsFollowing', jsonEncode(dataGot['postsFollowing']));
    await pref.setString('user', jsonEncode(dataGot['user']));
    if (!mounted) return;
    if (user.toString().length != dataGot['user'].toString().length ||
        postsFollowing.toString().length !=
            dataGot['postsFollowing'].toString().length ||
        gotInitData == false) {
      setState(() {
        postsFollowing = dataGot['postsFollowing'];
        user = dataGot['user'];
        gotInitData = true;
      });
    }
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    user = user.isNotEmpty ? user : widget.user;

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          // Main posts here
          RefreshIndicator(
            onRefresh: () => getHomeData(),
            color: Color.fromRGBO(180, 221, 255, 1.0),
            backgroundColor: Color.fromRGBO(15, 76, 117, 1),
            child: ListView(
                children: postsFollowing.length == 0
                    ? gotInitData
                        ? [
                            Container(
                              padding: EdgeInsets.all(20),
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Text(
                                  'Create a post or start following people to see posts here!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontFamily: 'Patrick',
                                  ),
                                ),
                              ),
                            )
                          ]
                        : [
                            Container(
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          ]
                    : postsFollowing.reversed.map((post) {
                        // The post container
                        return Post(
                          user,
                          post,
                          getHomeData,
                          keyEditDescription
                              .currentState!.showDescriptionEditor,
                          keyEditDescription
                              .currentState!.cancelDescriptionEditor,
                          key: Key(post['_id']),
                        );
                      }).toList()),
          ),
          if (user['rank'] == 'owner' || user['rank'] == 'admin')
            // Admin Button
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: Colors.grey[850],
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin');
                  },
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // Edit description field
          EditDescription(
            refresh: getHomeData,
            key: keyEditDescription,
          ),
        ],
      ),
    );
  }
}

class EditDescription extends StatefulWidget {
  const EditDescription({
    Key? key,
    required this.refresh,
  }) : super(key: key);

  final refresh;

  @override
  _EditDescriptionState createState() => _EditDescriptionState();
}

class _EditDescriptionState extends State<EditDescription> {
  String _descriptionValue = '';
  double _descriptionPlace = -300;
  String _descriptionPostID = '';
  FocusNode _descriptionFocusNode = FocusNode();
  TextEditingController _descriptionController = TextEditingController();
  String _submitBtnText = 'Submit';

  void showDescriptionEditor(postID, previousDescription) {
    _descriptionController.value = TextEditingValue(text: previousDescription);
    _descriptionPostID = postID;
    setState(() {
      _descriptionPlace = 0;
    });
  }

  cancelDescriptionEditor() {
    _descriptionPostID = '';
    setState(() {
      _descriptionPlace = -300;
    });
  }

  submitChangeDescription(String postID, String value) async {
    setState(() {
      _submitBtnText = 'Loading...';
    });
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    await post(Uri.parse('https://www.socialentapp.com/home/editdesc'), body: {
      'auth_token': authToken,
      'postID': postID,
      'desc': value.trim(),
    });
    setState(() {
      _descriptionPlace = -300;
      _submitBtnText = 'Submit';
    });
    widget.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
      top: _descriptionPlace,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white)),
          color: Colors.grey[850],
        ),
        padding: EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width,
        height: 300,
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              onChanged: (value) {
                _descriptionValue = value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Description...',
                border: InputBorder.none,
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // Cancel
                        _descriptionFocusNode.unfocus();
                        cancelDescriptionEditor();
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // Submit
                        submitChangeDescription(
                            _descriptionPostID, _descriptionValue);
                        _descriptionFocusNode.unfocus();
                      },
                      child: Text(_submitBtnText),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
