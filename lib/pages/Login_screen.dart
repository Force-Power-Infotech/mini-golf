import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart'; // Use just_audio
import 'package:minigolf/api.dart';
import 'package:minigolf/connection/connection.dart';
import 'package:minigolf/routes/routes.dart';
import 'package:minigolf/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String userId = '';
  final AudioPlayer _audioPlayer =
      AudioPlayer(); // Initialize just_audio player
  bool _isOtpSent = false;

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose the player when not needed
    super.dispose();
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.setAsset(soundPath); // Load the sound asset
      await _audioPlayer.play(); // Play the sound
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _sendOtp() async {
    _playSound('assets/sounds/mixkit-long-pop-2358.mp3'); // Play sound
    var data = dio.FormData.fromMap({'q': 'login', 'mobileNo': '9330262571'});

    var dioInstance = dio.Dio();
    var response = await dioInstance.request(
      Api.baseUrl,
      options: dio.Options(
        method: 'POST',
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      log(json.encode(response.data));
    } else {
      log(response.statusMessage ?? 'Unknown error');
    }
  }
  // void _sendOtp() async {
  //   _playSound('assets/sounds/mixkit-long-pop-2358.mp3'); // Play sound
  //   final response = await ApiService().post(
  //     Api.baseUrl,
  //     data: {
  //       'q': 'login',
  //       'mobileNo': _phoneController.text,
  //     },
  //   );

  //   if (response?.statusCode == 200) {
  //     setState(() {
  //       _isOtpSent = true;
  //     });
  //   } else {
  //     log(response?.statusMessage ?? 'Unknown error');
  //   }
  // }
  void _submitOtp() {
    _playSound('assets/sounds/mixkit-long-pop-2358.mp3'); // Play sound
    // Handle OTP submission logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Log in to continue',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Input Fields
              if (!_isOtpSent)
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[850],
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.phone, color: Colors.tealAccent),
                  ),
                ),
              if (_isOtpSent)
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[850],
                    labelText: 'OTP',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.tealAccent),
                  ),
                ),

              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isOtpSent) {
                      _submitOtp();
                      Get.toNamed(Routes.home);
                    } else {
                      _sendOtp();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isOtpSent ? 'Submit OTP' : 'Get OTP',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Additional Info
              if (_isOtpSent)
                Center(
                  child: Text(
                    'Enter the OTP sent to your phone',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
