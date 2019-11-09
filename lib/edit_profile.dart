
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_video_compress/aspect_ratio.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:video_player/video_player.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
class EditProfileScreen extends StatefulWidget {



  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {


  bool autovalidate = false;
  String notificationToken;
  bool isVideo = false;
  bool isCompressing = false;
  VideoPlayerController _controller;
  VoidCallback listener;
  bool loading = false;
  File mainFile;
  bool isAward = false;
  File thumbnailFile;

  double progress = 0;
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    listener = () {

      setState(() {});
    };

  }

  void _onVideoButtonPressed(ImageSource source) {
    setState(() {
      if (_controller != null) {
        _controller.setVolume(0.0);
        _controller.removeListener(listener);
      }

        ImagePicker.pickVideo(source: source).then((File file) async{
          if (file != null && mounted)  {


            setState(() {
              mainFile = file;


              _controller = VideoPlayerController.file(file)
                ..addListener(listener)
                ..setVolume(1.0)
                ..initialize()
                ..setLooping(true)
                ..play();
            });


            var dir = await path_provider.getApplicationDocumentsDirectory();
            var targetPath = dir.absolute.path + "/temp.mp4";



         //   var arguments = ["-i", file.path, "-c:v", "mpeg4", targetPath];
            _flutterFFmpeg.execute("-i "+file.path+" -c:v mpeg4 "+targetPath).then((rc) => print("FFmpeg process exited with rc $rc"));

           // _flutterFFmpeg.getMediaInformation(targetPath).then((info){
            //  print(info);
          //  });
/*
            _flutterFFmpeg.getMediaInformation(file.path).then((info) {
              print("Media Information");

              print("Path: ${info['path']}");


            });
            */

          }
        });

    });
  }
  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
      ),
      backgroundColor: Theme.of(context).accentColor,
    ));
  }

  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _autovalidate = false;
  bool _loading = false;
  String sex = "Male";
  String smoke = "Yes";
  String drink = "Yes";








  String userKey;
  String name;


  void _saveUserDetailsWithVideo() async{
    final FormState form = formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      //   showInSnackBar("Fix Errors");
    } else {
      form.save();





    }
  }

  void _saveUserDetailsWithoutVideo() async{
    final FormState form = formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      //   showInSnackBar("Fix Errors");
    } else {
      form.save();

      setState(() {
        _loading = true;
      });



    }
  }

  Widget _previewVideo(VideoPlayerController controller) {
    if (controller == null) {
      return  Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    } else if (controller.value.initialized) {

      return  AspectRatioVideo(controller);

    } else {
      return  Text(
        'Error Loading Video',
        textAlign: TextAlign.center,
      );
    }
  }



  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);

      _controller.removeListener(listener);

    }
    super.deactivate();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(title: Text('Video'),),
      body:

      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 20.0),
          child:  Column(

            children: <Widget>[


              Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF55b9b6).withOpacity(0.2),

                  ),
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.all(10.0),
                  width: screenSize.width,
                  height: screenSize.height/3,
                  child: _previewVideo(_controller)),


              Column(
                children: <Widget>[
                  _loading == true ? Container(
                    padding: EdgeInsets.only(top: 30.0),
                    child: CircularProgressIndicator(),
                  ) :

                      Column(
                        children: <Widget>[
                          Container(
                          //  padding: EdgeInsets.all(15.0),
                            width: screenSize.width / 1.8,
                            
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Theme.of(context).primaryColorDark)
                                  
                            ),
                            //  color: Theme.of(context).primaryColor,

                            child:  Center(
                              child: FlatButton(
                                 onPressed: (){
                                  _onVideoButtonPressed(ImageSource.gallery);
                                   //_incrementCounter();
                                 },
                                child: Text(
                                        "Add a video",
                                        style: new TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Theme.of(context).primaryColorDark,
                                            fontSize: 20.0,
                                          )),
                              ),
                            ),

                          ),

                          Text(_counter.toString(),style: TextStyle(fontSize: 20,color: Colors.black),),
                          Container(
                            padding: EdgeInsets.only(top: 15.0),
                            width: screenSize.width / 1.8,
                            //  color: Theme.of(context).primaryColor,

                            child: RaisedButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0)),
                              onPressed: () {
                                if(mainFile == null){

                                  print("mainfile is null");
                                  _saveUserDetailsWithoutVideo();
                                } else
                                  {
                                    print("mainfile is not null");
                                    _saveUserDetailsWithVideo();
                                  }
                              },



                              color: Theme.of(context).primaryColorDark,
                              child: new Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: new Text(
                                    "Edit Profile",
                                    style: new TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      )

                ],
              )

            ],
          ),
        ),
      ),

    );
  }
}
