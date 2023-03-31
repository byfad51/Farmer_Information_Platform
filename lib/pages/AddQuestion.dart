import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordadder/pages/Questions.dart';

class AskQuestionPage extends StatefulWidget {
  const AskQuestionPage({Key? key}) : super(key: key);

  @override
  _AskQuestionPageState createState() => _AskQuestionPageState();
}

class _AskQuestionPageState extends State<AskQuestionPage> {
  final _questionTitleController = TextEditingController();
  final _questionTextController = TextEditingController();
  File? _pickedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedImageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _pickedImage = File(pickedImageFile!.path);
    });
  }

  Future<void> _submitQuestion() async {
    setState(() {
      _isUploading = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    final questionId = FirebaseFirestore.instance.collection('questions').doc().id;
    final storageReference = FirebaseStorage.instance.ref().child('questions').child(questionId + '.jpg');
    final uploadTask = storageReference.putFile(_pickedImage!);

    final downloadUrl = await (await uploadTask).ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('questions').doc(questionId).set({
      'title': _questionTitleController.text,
      'text': _questionTextController.text,
      'imageUrl': downloadUrl,
      'userId': currentUser!.uid,
      'email': currentUser.email,
      'phonenumber': currentUser.phoneNumber,
      'timestamp': DateTime.now(),
    });

    setState(() {
      _isUploading = false;
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _questionTitleController.dispose();
    _questionTextController.dispose();
    super.dispose();
  }
 // var snapshot =FirebaseFirestore.instance.collection('questions').get();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ask a Question'),
      ),
      body: Column(children:[SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _questionTitleController,
                decoration: InputDecoration(
                  labelText: 'Question Title',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _questionTextController,
                decoration: InputDecoration(
                  labelText: 'Question Text',
                ),
                maxLines: 6,
              ),
              SizedBox(height: 16.0),
              _pickedImage != null
                  ? Image.file(
                _pickedImage!,
                fit: BoxFit.cover,
                height: 200.0,
              )
                  : SizedBox(height: 0.0),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: Text('Choose Image'),
                  ),
                  _isUploading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _submitQuestion,
                    child: Text('Submit'),
                  ),
                ],
              ),
Text("My Questions"),

            ],
          ),
        ),
      ),


      ]),
    );
  }
}
