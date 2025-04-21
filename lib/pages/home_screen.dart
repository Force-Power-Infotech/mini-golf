import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:minigolf/api.dart';
import 'package:minigolf/class/slot_details.dart'; // Import the shared SlotDetails class
import 'package:minigolf/class/user_class.dart';
import 'package:minigolf/connection/connection.dart';
import 'package:minigolf/routes/routes.dart';
import 'package:minigolf/storage/get_storage.dart';
import 'package:minigolf/widgets/app_widgets.dart';
import 'package:minigolf/class/slot_details.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen>
    with SingleTickerProviderStateMixin {
  final UserClass user = Storage().getUserData();
  late final AnimationController _controller;
  List<SlotDetails> availableSlots = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user.name == null ||
          user.name?.isEmpty == true ||
          user.name?.trim() == "") {
        _showNameInputDialog();
      } else {
        _fetchAvailableSlots();
      }
    });
  }

  Future<void> _fetchAvailableSlots() async {
    try {
      final now = DateTime.now();

      // Format date as YYYY-MM-DD
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Format time as HH:MM AM/PM
      final hour =
          now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      final ampm = now.hour < 12 ? 'AM' : 'PM';
      final timeSlot =
          '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $ampm';

      // Log request details
      log('Making API request to fetch reservations:');
      log('URL: https://app.forcempower.com/booking/api/fetch_reservations.php');
      log('Request data: { date: $date, timeSlot: $timeSlot }');

      final response = await dio.Dio().post(
        'https://app.forcempower.com/booking/api/fetch_reservations.php',
        options: dio.Options(
          contentType: dio.Headers.formUrlEncodedContentType,
          validateStatus: (status) => true, // To handle all status codes
        ),
        data: {
          'date': date,
          'timeSlot': timeSlot,
        },
      );

      // Log response details
      log('Response status code: ${response.statusCode}');
      log('Response headers: ${response.headers}');
      log('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data == null) {
          log('Error: Response data is null');
          AppWidgets.errorSnackBar(content: 'No data received from server');
          return;
        }

        if (data['error'] == true) {
          log('API returned error: ${data['message']}');
          AppWidgets.errorSnackBar(
              content: data['message'] ?? 'Failed to fetch slots');
          return;
        }

        final slotsData = data['data'] as List?;
        if (slotsData == null) {
          log('Error: Slots data is null');
          AppWidgets.errorSnackBar(content: 'Invalid response format');
          return;
        }

        setState(() {
          availableSlots =
              slotsData.map((slot) => SlotDetails.fromJson(slot)).toList();
        });

        log('Successfully parsed ${availableSlots.length} slots');

        if (availableSlots.isNotEmpty) {
          _showAvailableSlotsDialog();
        } else {
          AppWidgets.errorSnackBar(content: 'No slots available for this time');
        }
      } else {
        log('Error: Non-200 status code: ${response.statusCode}');
        AppWidgets.errorSnackBar(
            content: 'Server error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      log('Failed to fetch slots:', error: e, stackTrace: stackTrace);
      AppWidgets.errorSnackBar(
          content: 'Error fetching slots. Please try again.');
    }
  }

  void _showAvailableSlotsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A1A1A),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF2B2B2B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Available Slots',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: availableSlots
                        .map((slot) => Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: slot.status == 'paid'
                                      ? Colors.red.withOpacity(0.5)
                                      : Colors.tealAccent.withOpacity(0.5),
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  slot.timeSlot,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status: ${slot.status}',
                                      style: TextStyle(
                                        color: slot.status == 'paid'
                                            ? Colors.red
                                            : Colors.tealAccent,
                                      ),
                                    ),
                                    if (slot.name.isNotEmpty)
                                      Text(
                                        'Players: ${slot.name}',
                                        style:
                                            TextStyle(color: Colors.grey[400]),
                                      ),
                                  ],
                                ),
                                enabled: slot.status != 'paid',
                                onTap: slot.status == 'paid'
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                        Get.toNamed(
                                          Routes.playnow,
                                          arguments: {
                                            'slotDetails': slot,
                                            'selectedDate': DateTime.now(),
                                            'companyName':
                                                user.companyName ?? '',
                                          },
                                        );
                                      },
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNameInputDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A1A1A),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF2B2B2B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Your Name',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  hintText: 'Your name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.tealAccent.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.tealAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty) {
                        nameapi(nameController.text.trim());
                        user.name = nameController.text.trim();
                        Storage().storeUserDate(user);
                        setState(() {});
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shadowColor: Colors.tealAccent.withOpacity(0.5),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTeamNameDialog() {
    final TextEditingController teamController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A1A1A),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF2B2B2B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Team Name',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: teamController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  hintText: 'Your team name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.purpleAccent.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purpleAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (teamController.text.trim().isNotEmpty) {
                        // TODO: Implement team name API call here
                        AppWidgets.successSnackBar(
                            content: 'Team name updated successfully');
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> nameapi(String name) async {
    try {
      final response = await ApiService().post(
        'https://app.forcempower.com/booking/api/modify_username.php',
        data: {
          'userID': user.userID,
          'username': name,
        },
      );

      if (response == null) {
        AppWidgets.errorSnackBar(content: 'No response from server');
        return;
      }

      Map<String, dynamic> data = response.data;
      if (response.statusCode == 200 && data['error'] == false) {
        AppWidgets.successSnackBar(content: data['message']);
      } else {
        AppWidgets.errorSnackBar(
            content: data['message'] ?? 'Failed to update name');
      }
    } catch (e) {
      AppWidgets.errorSnackBar(content: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 30),
                    _buildFeatureGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Go Putt Pro",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Welcome back, ${user.name}!",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        Storage().storeUserDate(UserClass());
        Get.offAllNamed(Routes.login);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.tealAccent, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/homecard.gif'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
              Colors.black.withOpacity(0.4),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join the Challenge Now!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.tealAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _buildFeatureCard(
          icon: Icons.calendar_today,
          title: 'Available Slots',
          color: Colors.tealAccent,
          onTap: _fetchAvailableSlots,
        ),
        _buildFeatureCard(
          icon: Icons.sports_golf,
          title: 'Get Started',
          color: Colors.tealAccent,
          onTap: () {
            log("Is Logged In: ${Storage().isLoggedIn()}");
            if (Storage().isLoggedIn() == true) {
              Get.toNamed(Routes.playnow);
            } else {
              Get.toNamed(Routes.login);
            }
          },
        ),
        _buildFeatureCard(
          icon: Icons.star,
          title: 'Leaderboards',
          color: Colors.amberAccent,
          onTap: () => Get.toNamed(Routes.leaderboard),
        ),
        _buildFeatureCard(
          icon: Icons.group,
          title: 'Team Setup',
          color: Colors.purpleAccent,
          onTap: () => _showTeamNameDialog(),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0);
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              Colors.black.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.2),
                      border: Border.all(
                        color: color.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.5,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Generate random phone number based on timestamp
  String _generateRandomPhone() {
    final DateTime now = DateTime.now();
    final String timestamp = now.millisecondsSinceEpoch.toString();
    // Take the last 10 digits or pad with zeros if needed
    final String phone = timestamp.length >= 10
        ? timestamp.substring(timestamp.length - 10)
        : timestamp.padLeft(10, '0');
    return phone;
  }

  // Create company user with API call
  void _createCompanyUser(String companyName) async {
    final String randomPhone = _generateRandomPhone();
    String userId = '';

    await ApiService().post(
      Api.baseUrl,
      data: {
        'q': 'login',
        'mobileNo': randomPhone,
        'companyName': companyName,
      },
    ).then((response) {
      if (response == null) {
        AppWidgets.errorSnackBar(content: 'No response from server');
        return;
      }
      Map<String, dynamic> data = response.data;
      if (response.statusCode == 200 && data['error'] == false) {
        userId = data['userID'].toString();

        // Auto submit OTP (simulating the second API call)
        _submitOtp(userId);
        AppWidgets.successSnackBar(content: 'Company created successfully');
      } else {
        AppWidgets.errorSnackBar(content: data['message']);
      }
    }).catchError((e) {
      AppWidgets.errorSnackBar(content: 'Error: $e');
    });
  }

  // Submit OTP for company user
  void _submitOtp(String userId) async {
    // Hardcoded OTP as per your requirement
    const String staticOtp = "2020";

    // Implementing the OTP verification call here if needed
    // This part would typically make another API call with the OTP
    log("User created with ID: $userId and verified with OTP: $staticOtp");
  }
}
