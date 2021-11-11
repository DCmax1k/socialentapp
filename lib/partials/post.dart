import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class Post extends StatefulWidget {
  const Post(this.user, this.post, this.refresh, this.showDescriptionEditor,
      this.cancelDescriptionEditor,
      {Key? key})
      : super(key: key);
  final Map user;
  final Map post;
  final AsyncCallback refresh;
  final showDescriptionEditor;
  final cancelDescriptionEditor;

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  Map user = {};
  Map post = {};
  bool userLikedPost = false;
  int numberOfLikes = 0;
  var txt = TextEditingController();
  final keyButtons = GlobalKey<_PostButtonsState>();
  final keyPostVideo = GlobalKey<_PostVideoState>();
  final keyOptionsMenu = GlobalKey<_OptionsMenuState>();

  @override
  void initState() {
    super.initState();
  }

  viewComments(comments) {
    Navigator.pushNamed(context, '/comments', arguments: {
      'comments': comments,
    });
  }

  postComment(comment) async {
    if (comment.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      String postURL = 'https://www.socialentapp.com/home/addcomment';
      String dateFormatted = DateFormat('yMd').format(DateTime.now());
      print(dateFormatted);
      http.post(Uri.parse(postURL), body: {
        'auth_token': authToken,
        'postID': post['_id'],
        'comment': comment,
        'date': dateFormatted,
      });
      setState(() {
        post['comments'].add({
          'date': dateFormatted,
          'username': user['username'],
          'value': comment
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    user = user.isNotEmpty ? user : widget.user;
    post = widget.post;

    post['likes'].contains(user['_id']) == true
        ? userLikedPost = true
        : userLikedPost = false;
    numberOfLikes = post['likes'].length;
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Column(
            children: [
              // Username bar at top of post
              Container(
                child: Stack(
                  children: [
                    // appspot
                    ElevatedButton(
                      onPressed: () {
                        // Go to users account page here. I think pushNamed so you can go back easy.
                        print('Redirecting to : ${post['author']['username']}');
                      },
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0.0),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.all(5),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[200]),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(1000),
                            child: post['author']['profileImg'] != 'none'
                                ? post['author']['profileImg'].contains('http')
                                    ? Image.network(
                                        post['author']['profileImg'],
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.memory(
                                        base64.decode(post['author']
                                                ['profileImg']
                                            .split(',')
                                            .last),
                                        height: 30,
                                        width: 30,
                                      )
                                : Image.asset(
                                    'assets/profilePlaceholder.png',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          if (post['author']['prefix']['title'] != '')
                            Text(
                              '[${post['author']['prefix']['title']}]',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: post['author']['rank'] == 'owner'
                                    ? Colors.red
                                    : post['author']['rank'] == 'admin'
                                        ? Colors.blue
                                        : Colors.green,
                              ),
                            ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            post['author']['username'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    if (user['username'] == post['author']['username'])
                      Positioned.fill(
                        top: 5,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero)),
                            onPressed: () {
                              keyOptionsMenu.currentState!.showHideMenu();
                            },
                            child: Icon(Icons.keyboard_control,
                                color: Colors.black),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              // Post image or video
              GestureDetector(
                onDoubleTap: () {
                  keyButtons.currentState!.likePost(post['_id']);
                },
                onTap: () {
                  if (post['urlType'] == 'video') {
                    keyPostVideo.currentState!.playPauseVideo();
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.width + 100,
                  ),
                  color: Colors.black,
                  child: post['urlType'] == 'image'
                      ? FadeInImage.assetNetwork(
                          fadeInDuration: Duration(milliseconds: 50),
                          fadeOutDuration: Duration(milliseconds: 50),
                          placeholder: 'assets/grouplogo.png',
                          image: post['url']) // Image.network(post['url'])
                      // : Image.asset('assets/SocialentLogo.png'),
                      : PostVideo(post['url'], key: keyPostVideo),
                ),
              ),
              // Buttons here
              PostButtons(user, post, widget.refresh, key: keyButtons),
              // Description
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 1, 5),
                  child: RichText(
                    text: TextSpan(
                      text: post['author']['username'] + ' ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: post['description'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[850],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (post['comments'].length > 0)
                // Comments
                Container(
                  padding: EdgeInsets.fromLTRB(5, 0, 1, 0),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: post['comments'].length == 1
                        ? post['comments']
                            .sublist(post['comments'].length - 1,
                                post['comments'].length)
                            .reversed
                            .map<Widget>(
                            (comment) {
                              return Container(
                                child: RichText(
                                  text: TextSpan(
                                    text: comment['username'] + ' ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: comment['value'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey[850],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ).toList()
                        : post['comments']
                            .sublist(post['comments'].length - 2,
                                post['comments'].length)
                            .reversed
                            .map<Widget>(
                            (comment) {
                              return Container(
                                child: RichText(
                                  text: TextSpan(
                                    text: comment['username'] + ' ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: comment['value'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey[850],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                  ),
                ),

              if (post['comments'].length > 2)
                // View comments
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                    onTap: () {
                      viewComments(post['comments']);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 1, 0, 1),
                      child: Text(
                        'View${post['comments'].length > 1 ? ' all' : ''} ${post['comments'].length} comment${post['comments'].length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              // Date of post
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(5, 1, 0, 1),
                child: Text(DateFormat('yMd')
                    .format(DateTime.fromMillisecondsSinceEpoch(post['date']))),
              ),
              // Add a comment
              Container(
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey),
                      bottom: BorderSide(color: Colors.grey)),
                ),
                child: TextField(
                  controller: txt,
                  onSubmitted: (value) {
                    postComment(value);
                    txt.text = '';
                  },
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (user['_id'] == post['author']['_id'])
          // Options menu
          OptionsMenu(
            key: keyOptionsMenu,
            post: post,
            refresh: widget.refresh,
            showEditor: widget.showDescriptionEditor,
            cancelEditor: widget.cancelDescriptionEditor,
          ),
      ],
    );
  }
}

class OptionsMenu extends StatefulWidget {
  const OptionsMenu({
    Key? key,
    required this.post,
    required this.refresh,
    required this.showEditor,
    required this.cancelEditor,
  }) : super(key: key);

  final Map post;
  final AsyncCallback refresh;
  final showEditor;
  final cancelEditor;

  @override
  _OptionsMenuState createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  double _postOptionsOpacity = 0;
  String _deletePostText = 'Delete post';
  showHideMenu() {
    setState(() {
      _postOptionsOpacity == 0
          ? _postOptionsOpacity = 1
          : _postOptionsOpacity = 0;
    });
  }

  deletePost(postID) async {
    setState(() {
      _deletePostText = 'Loading...';
    });
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    await http
        .post(Uri.parse('https://www.socialentapp.com/home/deletepost'), body: {
      'auth_token': authToken,
      'postID': postID,
    });
    widget.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: _postOptionsOpacity,
          child: IgnorePointer(
            ignoring: _postOptionsOpacity == 0 ? true : false,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[850],
                border: Border.all(
                  color: Color.fromRGBO(180, 180, 180, 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    blurRadius: 5,
                    spreadRadius: 5,
                    offset: Offset(-5, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 200,
                    child: TextButton(
                      onPressed: () {
                        widget.showEditor(
                            widget.post['_id'], widget.post['description']);
                        showHideMenu();
                      },
                      child: Text(
                        'Edit',
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    child: TextButton(
                      onPressed: () {
                        // Delete post
                        deletePost(widget.post['_id']);
                      },
                      child: Text(
                        _deletePostText,
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Videos for post
class PostVideo extends StatefulWidget {
  PostVideo(this.postURL, {Key? key}) : super(key: key);

  final postURL;

  @override
  _PostVideoState createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  String postURL = '';
  late VideoPlayerController _controller;

  playPauseVideo() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  void initState() {
    super.initState();
    postURL = widget.postURL;

    _controller = VideoPlayerController.network(postURL)
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _controller.value.isInitialized
          ? Center(
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      color: _controller.value.isPlaying == true
                          ? Colors.transparent
                          : Color.fromRGBO(0, 0, 0, 0.5),
                      child: Center(
                        child: Icon(
                          Icons.play_arrow,
                          size: 70,
                          color: _controller.value.isPlaying == true
                              ? Colors.transparent
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(),
    );
  }
}

// Butons for like, share, etc
class PostButtons extends StatefulWidget {
  PostButtons(this.user, this.post, this.refresh, {Key? key})
      : super(
          key: key,
        );
  final Map user;
  final Map post;
  final AsyncCallback refresh;

  @override
  _PostButtonsState createState() => _PostButtonsState();
}

class _PostButtonsState extends State<PostButtons> {
  Map user = {};
  Map post = {};
  bool userLikedPost = false;
  int numberOfLikes = 0;

  @override
  void initState() {
    super.initState();
  }

  likePost(postID) async {
    HapticFeedback.lightImpact();
    if (userLikedPost == false) {
      // Like post
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      String postURL = 'https://www.socialentapp.com/home/likepost';
      http.post(Uri.parse(postURL), body: {
        'auth_token': authToken,
        'postID': postID,
      });
      setState(() {
        post['likes'].add(user['_id']);
      });
    } else if (userLikedPost == true) {
      // Dislike post
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      String postURL = 'https://www.socialentapp.com/home/unlikepost';
      http.post(Uri.parse(postURL), body: {
        'auth_token': authToken,
        'postID': postID,
      });
      setState(() {
        post['likes'].remove(user['_id']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    user = widget.user;
    post = widget.post;

    post['likes'].contains(user['_id']) == true
        ? userLikedPost = true
        : userLikedPost = false;
    numberOfLikes = post['likes'].length;
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                // Like button
                Container(
                  width: 50,
                  child: Stack(
                    children: [
                      // Heart
                      IconButton(
                          onPressed: () {
                            likePost(post['_id']);
                          },
                          icon: // userLikedPost == false
                              AnimatedContainer(
                            curve: Curves.elasticInOut,
                            height: userLikedPost ? 50 : 25,
                            duration: Duration(milliseconds: 1000),
                            child: FittedBox(
                              child: Icon(
                                userLikedPost
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: userLikedPost
                                    ? Colors.red[700]
                                    : Colors.grey[500],
                              ),
                            ),
                          )),
                      // Number of likes
                      Positioned.fill(
                        bottom: 1,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            '$numberOfLikes Like${numberOfLikes == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // Share
                Container(
                  width: 50,
                  child: IconButton(
                    onPressed: () {
                      Share.share(
                          'Check out this post on Socialent! https://www.socialentapp.com/post/${post['_id']}');
                    },
                    icon: Icon(
                      Icons.share,
                      color: Colors.grey[500],
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Admin delete button
          if (user['rank'] == 'owner' || user['rank'] == 'admin')
            AdminDeleteButton(
              post: post,
              user: user,
              refresh: widget.refresh,
            ),
        ],
      ),
    );
  }
}

class AdminDeleteButton extends StatefulWidget {
  const AdminDeleteButton({
    Key? key,
    required this.post,
    required this.user,
    required this.refresh,
  }) : super(key: key);

  final Map user;
  final Map post;
  final AsyncCallback refresh;

  @override
  _AdminDeleteButtonState createState() => _AdminDeleteButtonState();
}

class _AdminDeleteButtonState extends State<AdminDeleteButton> {
  double _currentOpacity = 0;
  String message = 'Are you sure you would like to delete this post?';
  bool postDeleted = false;

  adminDeletePost(postID) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    String postURL = 'https://www.socialentapp.com/home/admindeletepost';
    await http.post(Uri.parse(postURL), body: {
      'auth_token': authToken,
      'admin': widget.user['_id'],
      'user': widget.post['author']['_id'],
      'postID': postID,
    });
    // DELETE POST HERE
    print('Delete post');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 100,
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () {
              setState(() {
                _currentOpacity = 1;
              });
            },
            icon: Icon(
              postDeleted == true ? Icons.check : Icons.not_interested,
              color: Colors.red,
              size: 28,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 30,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: _currentOpacity,
            child: IgnorePointer(
              ignoring: _currentOpacity == 0 ? true : false,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.8),
                        offset: Offset(10, 10),
                        blurRadius: 20),
                  ],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white),
                ),
                padding: EdgeInsets.all(10),
                width: 200,
                child: Column(
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              message = 'Loading...';
                            });
                            await adminDeletePost(widget.post['_id']);
                            setState(() {
                              message = 'Post deleted!';
                              postDeleted = true;
                            });
                            setState(() {
                              _currentOpacity = 0;
                            });
                            widget.refresh();
                          },
                          child: Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _currentOpacity = 0;
                            });
                          },
                          child: Text('No'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
