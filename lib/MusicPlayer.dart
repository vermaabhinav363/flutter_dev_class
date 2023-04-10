import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

//Global Variables
String audioAsset = "assets/music.mp3";
bool isPlaying = false;
bool isAudioPlayed = false;
late Uint8List audioBytes;
Duration currentDuration = const Duration(seconds: 0);
AudioPlayer player = AudioPlayer();
//---------------------------------------------------------------
void loadAudio() {
  Future.delayed(Duration.zero, () async {
    ByteData bytes = await rootBundle.load(audioAsset);
    audioBytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  });
}
//---------------------------------------------------------------
class _MusicPlayerState extends State<MusicPlayer> {
  @override
  void initState() {
    super.initState();
    loadAudio();

    player.onPlayerStateChanged.listen((event) {
      print(event.toString());
    });
    player.onDurationChanged.listen((event) {
      print(event.toString());
    });
    player.onAudioPositionChanged.listen((event) {
      setState(() {
        currentDuration = event;
      });
      print(event.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 320,
                width: 320,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    image: const DecorationImage(
                      image: AssetImage('assets/image.png'),
                    )),
              ),
              const SizedBox(
                height: 80,
              ),
              SizedBox(
                width: 350,
                child: Slider(
                    max: 203,
                    min: 0,
                    value: currentDuration.inSeconds.toDouble(),
                    activeColor: Colors.black,
                    inactiveColor: Colors.grey,
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await player.seek(position);

                      await player.resume();
                      setState(() {
                        isPlaying = true;
                      });
                    }),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  IconButton(
                    iconSize: 48,
                    color: Colors.grey[700],
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () async {},
                  ),
                  const SizedBox(width: 20,),
                  IconButton(
                    iconSize: 48,
                    color: Colors.black,
                    icon: !isPlaying
                        ? const Icon(Icons.play_arrow)
                        : const Icon(Icons.pause),
                    onPressed: () async {
                      if (!isPlaying && !isAudioPlayed) {
                        int result = await player.playBytes(audioBytes);
                        isAudioPlayed = true;
                        if (result == 1) {
                          setState(() {
                            isPlaying = true;
                          });
                        } else {
                          print("Error while playing audio.");
                        }
                      } else if (!isPlaying && isAudioPlayed) {
                        int result = await player.resume();
                        if (result == 1) {
                          //resume success
                          setState(() {
                            isPlaying = true;
                          });
                        } else {
                          print("Error on resume audio.");
                        }
                      } else {
                        int result = await player.pause();
                        if (result == 1) {
                          //pause success
                          setState(() {
                            isPlaying = false;
                          });
                        } else {
                          print("Error on pause audio.");
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 20,),
                  IconButton(
                    iconSize: 48,
                    color: Colors.grey[700],
                    icon: const Icon(Icons.skip_next),
                    onPressed: () async {},
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
