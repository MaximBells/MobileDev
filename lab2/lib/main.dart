import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:unicorndial/unicorndial.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(new MaterialApp(
      debugShowCheckedModeBanner: false, home: Scaffold(body: VideoDemo())));
}

class VideoDemo extends StatefulWidget {
  VideoDemo() : super();

  final String title = "Video Demo";

  @override
  VideoDemoState createState() => VideoDemoState();
}

class VideoDemoState extends State<VideoDemo> {
  //
  double _currentSliderValue = 0;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // _controller = VideoPlayerController.network(
    //     "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4");
    _controller = VideoPlayerController.asset('videos/butterfly.mp4');
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1.0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _reDrawWidget() async {
    Timer.periodic(Duration(milliseconds: 1), (timer) {
      setState(() {
        _currentSliderValue = _controller.value.position.inSeconds.toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _reDrawWidget();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      appBar: AppBar(
        title: Text("Max Media"),
        backgroundColor: Colors.black45,
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 175.0,
                ),
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Center(
                  child: Slider(
                      activeColor: Colors.black,
                      inactiveColor: Colors.black45,
                      value: _currentSliderValue,
                      min: 0,
                      max: _controller.value.duration.inSeconds.toDouble(),
                      label: _currentSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue =
                              _controller.value.position.inSeconds.toDouble();
                          _controller.seekTo(Duration(seconds: value.toInt()));
                        });
                      }),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black45,
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child:
        Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.audiotrack),
              onPressed: () {},
              iconSize: 40.0,
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TakePictureScreen(camera: cameras.first)));
                _controller.pause();
              },
              iconSize: 40.0,
            ),
          ],
        ),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var childButtons = List<UnicornButton>();
    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
            heroTag: "airplane",
            backgroundColor: Colors.greenAccent,
            mini: true,
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final image = await _controller.takePicture();
                print(image.path);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      imagePath: image?.path,
                    ),
                  ),
                );
              } catch (e) {
                // If an error occurs, log the error to the console.
                print(e);
              }
            },
            child: Icon(Icons.camera_alt))));

    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
            heroTag: "directions",
            //Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow)
            backgroundColor: _controller.value.isRecordingVideo ? Colors.red : Colors.green,
            mini: true,
            onPressed: () {
              setState(() {
                if (_controller.value.isRecordingVideo) {
                  final video = _controller.stopVideoRecording();
                  _controller.stopVideoRecording();
                } else {
                  _controller.startVideoRecording();
                }
              });
            },
            child: Icon(Icons.video_call))));
    return Scaffold(
        appBar: AppBar(
          title: Text('Max Media'),
          backgroundColor: Colors.black45,
        ),
        // Wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner
        // until the controller has finished initializing.
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return Container(
                  color: Colors.black45,
                  child: Center(child: CameraPreview(_controller)));
            } else {
              // Otherwise, display a loading indicator.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.black45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.audiotrack),
                onPressed: () {
                  Navigator.pop(context);
                },
                iconSize: 40.0,
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () {},
                iconSize: 40.0,
              ),
            ],
          ),
        ),
        floatingActionButton: UnicornDialer(
            parentButtonBackground: Colors.redAccent,
            orientation: UnicornOrientation.VERTICAL,
            parentButton: Icon(Icons.add),
            childButtons: childButtons),
       );
  }
}


class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display the Picture'), backgroundColor: Colors.black45,),
      body: Container(
          color: Colors.black45,
          child: Center(child: Image.file(File(imagePath)))),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.audiotrack),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VideoDemo()));
              },
              iconSize: 40.0,
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                Navigator.pop(context);
              },
              iconSize: 40.0,
            ),
          ],
        ),
      ),
    );
  }
}
