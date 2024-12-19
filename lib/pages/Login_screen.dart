import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart'; // Use just_audio
import 'package:minigolf/api.dart';
import 'package:minigolf/class/user_class.dart';
import 'package:minigolf/connection/connection.dart';
import 'package:minigolf/routes/routes.dart';
import 'package:minigolf/storage/get_storage.dart';
import 'package:minigolf/widgets/app_widgets.dart';
import 'dart:async';

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
  int _timeLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose(); // Dispose the player when not needed
    super.dispose();
  }

  void startTimer() {
    _timeLeft = 30; // 30 seconds cooldown
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
        }
      });
    });
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
    await ApiService().post(
      Api.baseUrl,
      data: {
        'q': 'login',
        'mobileNo': _phoneController.text,
      },
    ).then((response) {
      if (response == null) {
        AppWidgets.errorSnackBar(content: 'No response from server');
        return;
      }
      Map<String, dynamic> data = response.data;
      if (response.statusCode == 200 && data['error'] == false) {
        AppWidgets.successSnackBar(content: data['message']);
        setState(() {
          _isOtpSent = true;
          userId = data['userID'].toString();
        });
        startTimer(); // Start the timer when OTP is sent
      } else {
        AppWidgets.errorSnackBar(content: data['message']);
      }
    }).catchError((e) {
      AppWidgets.errorSnackBar(content: 'Error: $e');
    });
  }

  Future<void> _submitOtp() async {
    _playSound('assets/sounds/mixkit-long-pop-2358.mp3'); // Play sound
    // Handle OTP submission logic here
    await ApiService().post(
      Api.baseUrl,
      data: {
        'q': 'verifyOTP',
        'userID': userId,
        'otp': _otpController.text,
      },
    ).then((response) async {
      if (response == null) {
        AppWidgets.errorSnackBar(content: 'No response from server');
        return;
      }
      Map<String, dynamic> data = response.data;
      if (response.statusCode == 200 && data['error'] == false) {
        Storage().storeUserDate(UserClass.fromJson(data));
        AppWidgets.successSnackBar(content: data['message']);
        setState(() {
          _isOtpSent = true;
        });
        Get.toNamed(Routes.home);
        // Use store data from storage below
        // Assuming you have a method to store data in local storage
      } else {
        AppWidgets.errorSnackBar(content: data['message']);
      }
    }).catchError((e) {
      AppWidgets.errorSnackBar(content: 'Error: $e');
    });
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
                'Welcome Back !',
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
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.phone, color: Colors.tealAccent),
                  ),
                ),
              if (_isOtpSent) ...[
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
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.tealAccent),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _timeLeft == 0 ? _sendOtp : null,
                      child: Text(
                        _timeLeft > 0 
                            ? 'Resend OTP in ${_timeLeft}s'
                            : 'Resend OTP',
                        style: TextStyle(
                          color: _timeLeft == 0 ? Colors.tealAccent : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isOtpSent) {
                      _submitOtp();
                    } else {
                      _sendOtp();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
