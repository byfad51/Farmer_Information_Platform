import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionListPage extends StatefulWidget {
  @override
  _QuestionListPageState createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {

void _showChangeBioDialog(String questionId, String title) {
  TextEditingController _commentController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Change Answer - ' + title),
        content: TextFormField(
          controller: _commentController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Enter your new answer',
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter an answer';
            }
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_commentController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('questions')
                    .doc(questionId)
                    .update({'answer': _commentController.text});

                /*setState(() {
                  _bio = bioController.text;
                });*/

                Navigator.of(context).pop();
              }
            },
            child: Text('Change Answer'),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('questions').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Image.network(document['imageUrl'],  fit: BoxFit.fitWidth),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(document['title'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text(document['text']),
                          SizedBox(height: 10),
                          Text('E-mail: ${document['email']} Phone Number: ${document['phonenumber']}'),
                          SizedBox(height: 15),
                          document['answer'] != "" ? Text("Our Answer:" + document['answer']) :
                          ElevatedButton(
                            onPressed: () async {
                              _showChangeBioDialog(document.id,document['title']);
                            },
                            child: Text('Add Answer'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
