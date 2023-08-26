import 'package:flutter/material.dart';

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({Key? key}) : super(key: key);

  @override
  FeedBackScreenState createState() => FeedBackScreenState();
}

class FeedBackScreenState extends State<FeedBackScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ trợ và phản hồi'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mọi yêu cầu về hỗ trợ và phản hồi xin liên hệ:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text('Email: mrbmt1@gmail.com', style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
    );
  }
}
