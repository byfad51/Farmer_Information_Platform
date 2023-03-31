import 'dart:io';
import 'package:wordadder/Post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DashboardPage extends StatefulWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late List<Post> _posts=[];
  var _titleController = TextEditingController();
  var _textController = TextEditingController();
  int _role = 0;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _takeRole();
    _loadPosts();

  }
  void _takeRole() async{
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    setState(() {
      _role = userSnapshot.get('role');
    });
  }
  void _loadPosts() async {
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .get();

    List<Post> posts = [];
    for (QueryDocumentSnapshot postSnapshot in postsSnapshot.docs) {
      Post post = Post(
        postId: postSnapshot.id,
        userId: postSnapshot.get('userId'),
        title: postSnapshot.get('title'),
        text: postSnapshot.get('text'),
        imageUrl: postSnapshot.get('imageUrl'),
        timestamp: postSnapshot.get('timestamp'),
      );
      posts.add(post);
    }

    setState(() {
      _posts = posts;
    });
  }

  void _pickImage() async {
    final pickedFile =
    await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndSavePost() async {
    setState(() {
      _isLoading = true;
    });

    String imageUrl = '';
    if (_imageFile != null) {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('post_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = storageReference.putFile(_imageFile!);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('posts').add({
      'userId': widget.userId,
      'title': _titleController.text,
      'text': _textController.text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _titleController.clear();
      _textController.clear();
      _imageFile = null;
      _isLoading = false;
    });

    _loadPosts();
  }
  Widget shareWidget(BuildContext context){
    return Column(children: [
      Text(
        'Share a post',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      TextField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: 'Enter a title',
        ),
      ),
      SizedBox(height: 16),
      TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: 'Enter text',
        ),
      ),
      SizedBox(height: 16),_imageFile != null
          ? Image.file(
        _imageFile!,
        height: 200,
        fit: BoxFit.cover,
      )
          : Container(),
      SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Choose image'),
          ),
          ElevatedButton(
            onPressed: _uploadImageAndSavePost,
            child: Text('Share'),
          ),
        ],
      ),
      SizedBox(height: 32),
    ],);
  }
  void _moreInfo(BuildContext ctx, String title, String text, String imageUrl) {
    double high = MediaQuery
        .of(ctx)
        .size
        .height;
    showModalBottomSheet(
      context: ctx,
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Card(
            elevation: 5,
            child: Container(
              height: high,
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                  child: Card(child: Padding(

                    padding: const EdgeInsets.all(16.0),
                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                        imageUrl != ''
                            ? Image.network(
                          imageUrl,
                          //height: 200,
                          fit: BoxFit.fitWidth,
                        )
                            : Container(),
                        SizedBox(height: 8,),

                        SizedBox(height: 8),
                        Text(text),
                      ],
                    ),
                  ))
              ),
            ), //container
          ), //card
        ); //gesturedetector return
      }, //showModalBottomSheet builder
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          _role == 1 ?
          IconButton(
            icon: Icon(Icons.question_answer),
            onPressed: () {
              Navigator.pushNamed(context, '/list_question');

            },
          ) : IconButton(
            icon: Icon(Icons.question_answer),
            onPressed: () {
              Navigator.pushNamed(context, '/add_question');

            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');

            },
          ),
        ],
      ),


      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              (_role == 1) ? shareWidget(context):Text("Hoşgeldiniz sayın üye."),

              SizedBox(height: 16),
              _posts != null
                  ? Column(
                children: _posts.map((post) {
                  return Card(
                    child: ListTile(
                      title:  Text(
                      post.title,
                      style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,

                  )),
                      trailing: TextButton(child:Icon(Icons.arrow_right_alt), onPressed: (){
                        _moreInfo(context, post.title,post.text,post.imageUrl);
                      },),
                    )

                    /*

                    child: Padding(

                      padding: const EdgeInsets.all(16.0),
                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          post.imageUrl != ''
                              ? Image.network(
                            post.imageUrl,
                            //height: 200,
                            fit: BoxFit.fitWidth,
                          )
                              : Container(),
                          SizedBox(height: 8,),
                          Text(
                            post.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                          SizedBox(height: 8),
                          Text(post.text),
                        ],
                      ),
                    ),
                  */);
                }).toList(),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );}
}