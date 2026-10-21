import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'active_issues_page.dart';
import 'citizens_page.dart';
import 'civic_health_score_page.dart';
import 'in_progress_issues_page.dart';
import 'my_complaints_page.dart';
import 'profile_page.dart';
import 'report_issue_page.dart';
import 'resolved_issues_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _liveTimer;

  DateTime _lastUpdated = DateTime.now();

  int _selectedIndex = 0;

  // Location
  String _selectedLocation = 'Select your location';

  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();

    _liveTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) {
        if (mounted) {
          setState(() {
            _lastUpdated = DateTime.now();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  // =========================================================
  // NAVIGATION
  // =========================================================

  void _onNavigationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openReportPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportIssuePage(),
      ),
    );
  }

  void _openMyComplaints() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyComplaintsPage(),
      ),
    );
  }

  void _openActiveIssues() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ActiveIssuesPage(),
      ),
    );
  }

  void _openInProgressIssues() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InProgressIssuesPage(),
      ),
    );
  }

  void _openResolvedIssues() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ResolvedIssuesPage(),
      ),
    );
  }

  void _openCitizens() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CitizensPage(),
      ),
    );
  }

  void _openCivicHealthScore() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CivicHealthScorePage(),
      ),
    );
  }

  // =========================================================
  // LOCATION
  // =========================================================

  Future<void> _getCurrentLocation() async {
    try {
      // Check whether GPS/Location service is enabled
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        _showEnableLocationDialog();
        return;
      }

      // Check permission
      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission was denied.',
            ),
          ),
        );

        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        if (!mounted) return;

        _showPermissionSettingsDialog();

        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Detecting your location...',
          ),
        ),
      );

      // Get GPS coordinates
      Position position =
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert coordinates to City + State
      List<Placemark> placemarks =
      await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String locationName = 'Location not found';

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String city = '';

        // Different Android devices may return
        // locality or subAdministrativeArea
        if (place.locality != null &&
            place.locality!.isNotEmpty) {
          city = place.locality!;
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          city = place.subAdministrativeArea!;
        } else if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          city = place.administrativeArea!;
        }

        String state =
            place.administrativeArea ?? '';

        if (city.isNotEmpty && state.isNotEmpty) {
          locationName = '$city, $state';
        } else if (city.isNotEmpty) {
          locationName = city;
        } else if (state.isNotEmpty) {
          locationName = state;
        }
      }

      if (!mounted) return;

      setState(() {
        _selectedLocation = locationName;

        _selectedLatitude = position.latitude;
        _selectedLongitude = position.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location selected: $_selectedLocation',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not get location. Please try again.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // ENABLE LOCATION DIALOG
  // =========================================================

  void _showEnableLocationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.location_off_rounded,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 10),
              Text('Enable Location'),
            ],
          ),

          content: const Text(
            'Location services are currently turned off. '
                'Enable location to automatically detect your city.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // Opens phone Location Settings
                await Geolocator.openLocationSettings();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),

              child: const Text('Enable Now'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // LOCATION PERMISSION SETTINGS
  // =========================================================

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Location Permission Required',
          ),

          content: const Text(
            'Location permission has been permanently denied. '
                'Please enable it from your phone settings.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await Geolocator.openAppSettings();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),

              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // LOCATION SELECTOR
  // =========================================================

  void _openLocationSelector() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                const Text(
                  'Select Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 18),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor:
                    Color(0xFFE8F0FF),

                    child: Icon(
                      Icons.my_location_rounded,
                      color: Color(0xFF2563EB),
                    ),
                  ),

                  title: const Text(
                    'Use my current location',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: const Text(
                    'Automatically detect your city',
                  ),

                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    await _getCurrentLocation();
                  },
                ),

                const Divider(),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor:
                    Color(0xFFE8F0FF),

                    child: Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF16A34A),
                    ),
                  ),

                  title: Text(
                    _selectedLocation,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: Text(
                    _selectedLatitude == null
                        ? 'No location selected yet'
                        : 'Location selected successfully',
                  ),

                  trailing:
                  _selectedLatitude != null
                      ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFF16A34A),
                  )
                      : null,
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F9FF),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFF2563EB),

        foregroundColor: Colors.white,

        elevation: 0,

        titleSpacing: 20,

        title: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Text(
              'Smart Civic',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Making your city better',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: 8,
              top: 14,
              bottom: 14,
            ),

            padding:
            const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),

            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),

              borderRadius:
              BorderRadius.circular(20),
            ),

            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 7,
                  color: Color(0xFF4ADE80),
                ),

                SizedBox(width: 5),

                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notifications coming soon.',
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),

          const SizedBox(width: 5),
        ],
      ),

      // BODY
      body: _selectedIndex == 0
          ? _homeBody()
          : _getNavigationPage(),

      // FLOATING BUTTON
      floatingActionButton:
      _selectedIndex == 0
          ? FloatingActionButton.extended(
        backgroundColor:
        const Color(0xFF2563EB),

        foregroundColor: Colors.white,

        elevation: 5,

        onPressed: _openReportPage,

        icon: const Icon(
          Icons.add_a_photo_outlined,
        ),

        label: const Text(
          'Report Issue',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,

      // BOTTOM NAVIGATION
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,

        selectedIndex: _selectedIndex,

        indicatorColor:
        const Color(0xFFE8F0FF),

        onDestinationSelected:
        _onNavigationSelected,

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),

            selectedIcon: Icon(
              Icons.home_rounded,
            ),

            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.assignment_outlined,
            ),

            selectedIcon: Icon(
              Icons.assignment_rounded,
            ),

            label: 'Complaints',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.people_outline_rounded,
            ),

            selectedIcon: Icon(
              Icons.people_rounded,
            ),

            label: 'Citizens',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
            ),

            selectedIcon: Icon(
              Icons.person_rounded,
            ),

            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // =========================================================
  // NAVIGATION PAGES
  // =========================================================

  Widget _getNavigationPage() {
    switch (_selectedIndex) {
      case 1:
        return const MyComplaintsPage();

      case 2:
        return const CitizensPage();

      case 3:
        return const ProfilePage();

      default:
        return _homeBody();
    }
  }

  // =========================================================
  // HOME BODY
  // =========================================================

  Widget _homeBody() {
    return RefreshIndicator(
      color: const Color(0xFF2563EB),

      onRefresh: () async {
        await Future.delayed(
          const Duration(milliseconds: 800),
        );

        if (mounted) {
          setState(() {
            _lastUpdated = DateTime.now();
          });
        }
      },

      child: SingleChildScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          110,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const Text(
              'Welcome 👋',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Help make your city cleaner, safer and smarter.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),

            const SizedBox(height: 20),

            _locationCard(),

            const SizedBox(height: 20),

            _civicHealthCard(),

            const SizedBox(height: 25),

            _reportCard(),

            const SizedBox(height: 28),

            _sectionTitle(
              title: 'Live Civic Activity',

              trailing:
              'Updated ${_formatTime(_lastUpdated)}',
            ),

            const SizedBox(height: 14),

            // ACTIVE + IN PROGRESS

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon:
                    Icons.report_problem_outlined,

                    value: '248',

                    label: 'Active',

                    color:
                    const Color(0xFFEF4444),

                    onTap: _openActiveIssues,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    icon:
                    Icons.pending_actions_rounded,

                    value: '76',

                    label: 'In Progress',

                    color: Colors.orange,

                    onTap:
                    _openInProgressIssues,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // RESOLVED + CITIZENS

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon:
                    Icons.check_circle_outline_rounded,

                    value: '1,842',

                    label: 'Resolved',

                    color:
                    const Color(0xFF16A34A),

                    onTap: _openResolvedIssues,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    icon:
                    Icons.people_outline_rounded,

                    value: '3.2K',

                    label: 'Citizens',

                    color: Colors.purple,

                    onTap: _openCitizens,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            _sectionTitle(
              title: 'Complaint Categories',
              trailing: 'View all',

              onTrailingTap:
              _openMyComplaints,
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 115,

              child: ListView(
                scrollDirection: Axis.horizontal,

                children: [
                  _categoryCard(
                    icon:
                    Icons.construction_rounded,

                    title: 'Roads',

                    count: '86',

                    color:
                    const Color(0xFF2563EB),
                  ),

                  _categoryCard(
                    icon:
                    Icons.delete_outline_rounded,

                    title: 'Garbage',

                    count: '64',

                    color: Colors.orange,
                  ),

                  _categoryCard(
                    icon:
                    Icons.lightbulb_outline_rounded,

                    title: 'Streetlights',

                    count: '41',

                    color: Colors.purple,
                  ),

                  _categoryCard(
                    icon:
                    Icons.water_drop_outlined,

                    title: 'Water',

                    count: '29',

                    color: Colors.cyan,
                  ),

                  _categoryCard(
                    icon:
                    Icons.water_damage_outlined,

                    title: 'Drainage',

                    count: '18',

                    color: Colors.teal,
                  ),

                  _categoryCard(
                    icon:
                    Icons.traffic_rounded,

                    title: 'Traffic',

                    count: '10',

                    color: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _sectionTitle(
              title: 'Trending Issues 🔥',
              trailing: 'View all',

              onTrailingTap:
              _openActiveIssues,
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 175,

              child: ListView(
                scrollDirection:
                Axis.horizontal,

                children: [
                  _trendingCard(
                    rank: '01',

                    title:
                    'Road & Potholes',

                    reports:
                    '86 reports',

                    increase:
                    '+24%',

                    icon:
                    Icons.construction_rounded,

                    color:
                    const Color(0xFF2563EB),
                  ),

                  _trendingCard(
                    rank: '02',

                    title: 'Garbage',

                    reports:
                    '64 reports',

                    increase:
                    '+18%',

                    icon:
                    Icons.delete_outline_rounded,

                    color: Colors.orange,
                  ),

                  _trendingCard(
                    rank: '03',

                    title:
                    'Street Lights',

                    reports:
                    '41 reports',

                    increase:
                    '+12%',

                    icon:
                    Icons.lightbulb_outline_rounded,

                    color: Colors.purple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _sectionTitle(
              title: 'My Complaints',
              trailing: 'View all',

              onTrailingTap:
              _openMyComplaints,
            ),

            const SizedBox(height: 14),

            _complaintPreviewCard(
              title:
              'Pothole on Main Road',

              category: 'Roads',

              status:
              'In Progress',

              icon:
              Icons.construction_rounded,

              color:
              const Color(0xFF2563EB),
            ),

            _complaintPreviewCard(
              title:
              'Streetlight not working',

              category:
              'Streetlights',

              status: 'Resolved',

              icon:
              Icons.lightbulb_outline_rounded,

              color: Colors.purple,
            ),

            _complaintPreviewCard(
              title:
              'Garbage collection issue',

              category: 'Garbage',

              status:
              'Under Review',

              icon:
              Icons.delete_outline_rounded,

              color: Colors.orange,
            ),

            const SizedBox(height: 30),

            _communityImpact(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TIME FORMAT
  // =========================================================

  String _formatTime(DateTime time) {
    int hour = time.hour;

    String minute =
    time.minute.toString().padLeft(2, '0');

    String period =
    hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute $period';
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _sectionTitle({
    required String title,
    required String trailing,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172B4D),
          ),
        ),

        GestureDetector(
          onTap: onTrailingTap,

          child: Text(
            trailing,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // LOCATION CARD
  // =========================================================

  Widget _locationCard() {
    return InkWell(
      borderRadius:
      BorderRadius.circular(17),

      onTap: _openLocationSelector,

      child: Container(
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(17),

          border: Border.all(
            color:
            const Color(0xFFE2E8F0),
          ),
        ),

        child: Row(
          children: [
            const SizedBox(
              width: 44,
              height: 44,

              child: DecoratedBox(
                decoration: BoxDecoration(
                  color:
                  Color(0xFFE8F0FF),

                  borderRadius:
                  BorderRadius.all(
                    Radius.circular(13),
                  ),
                ),

                child: Icon(
                  Icons.location_on_rounded,
                  color:
                  Color(0xFF2563EB),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  const Text(
                    'YOUR LOCATION',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Color(0xFF718096),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _selectedLocation,

                    maxLines: 2,

                    overflow:
                    TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      Color(0xFF172B4D),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CIVIC HEALTH CARD
  // =========================================================

  Widget _civicHealthCard() {
    return InkWell(
      onTap: _openCivicHealthScore,

      borderRadius:
      BorderRadius.circular(22),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(22),

        decoration: BoxDecoration(
          gradient:
          const LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          borderRadius:
          BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color:
              const Color(0xFF2563EB)
                  .withValues(alpha: 0.20),

              blurRadius: 18,

              offset:
              const Offset(0, 8),
            ),
          ],
        ),

        child: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Civic Health Score',
                        style: TextStyle(
                          color:
                          Colors.white70,
                          fontSize: 13,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        '82 / 100',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Good • Improving this week',
                        style: TextStyle(
                          color:
                          Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ],
            ),

            SizedBox(height: 20),

            LinearProgressIndicator(
              value: 0.82,
              minHeight: 8,
              backgroundColor:
              Color(0x4060A5FA),

              valueColor:
              AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),

            SizedBox(height: 12),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  '↑ 8% from last week',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                Text(
                  'Tap for details',
                  style: TextStyle(
                    color:
                    Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // REPORT CARD
  // =========================================================

  Widget _reportCard() {
    return InkWell(
      borderRadius:
      BorderRadius.circular(21),

      onTap: _openReportPage,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color:
          const Color(0xFF172B4D),

          borderRadius:
          BorderRadius.circular(21),
        ),

        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color:
                Colors.white.withValues(
                  alpha: 0.10,
                ),

                borderRadius:
                BorderRadius.circular(15),
              ),

              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    'See something wrong?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Report it in under 60 seconds.',
                    style: TextStyle(
                      color:
                      Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // STAT CARD
  // =========================================================

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius:
      BorderRadius.circular(17),

      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(17),

          border: Border.all(
            color:
            const Color(0xFFE2E8F0),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,

              decoration: BoxDecoration(
                color:
                color.withValues(alpha: 0.10),

                borderRadius:
                BorderRadius.circular(11),
              ),

              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xFF172B4D),
                  ),
                ),

                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color:
                    Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CATEGORY CARD
  // =========================================================

  Widget _categoryCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return InkWell(
      borderRadius:
      BorderRadius.circular(17),

      onTap: _openActiveIssues,

      child: Container(
        width: 100,

        margin:
        const EdgeInsets.only(right: 12),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(17),

          border: Border.all(
            color:
            const Color(0xFFE2E8F0),
          ),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Container(
              width: 38,
              height: 38,

              decoration: BoxDecoration(
                color:
                color.withValues(alpha: 0.10),

                borderRadius:
                BorderRadius.circular(11),
              ),

              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),

            const Spacer(),

            Text(
              title,

              maxLines: 1,

              overflow:
              TextOverflow.ellipsis,

              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                FontWeight.w700,
                color:
                Color(0xFF172B4D),
              ),
            ),

            Text(
              '$count active',
              style: const TextStyle(
                fontSize: 9,
                color:
                Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TRENDING CARD
  // =========================================================

  Widget _trendingCard({
    required String rank,
    required String title,
    required String reports,
    required String increase,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      borderRadius:
      BorderRadius.circular(19),

      onTap: _openActiveIssues,

      child: Container(
        width: 190,

        margin:
        const EdgeInsets.only(right: 12),

        padding: const EdgeInsets.all(17),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(19),

          border: Border.all(
            color:
            const Color(0xFFE2E8F0),
          ),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [
                Container(
                  width: 40,
                  height: 40,

                  decoration: BoxDecoration(
                    color:
                    color.withValues(
                      alpha: 0.10,
                    ),

                    borderRadius:
                    BorderRadius.circular(12),
                  ),

                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),

                Text(
                  '#$rank',
                  style: TextStyle(
                    color: color,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight:
                FontWeight.bold,
                color:
                Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Text(
                  reports,
                  style: const TextStyle(
                    fontSize: 10,
                    color:
                    Color(0xFF718096),
                  ),
                ),

                const Spacer(),

                Text(
                  increase,
                  style: const TextStyle(
                    color:
                    Color(0xFF16A34A),
                    fontSize: 10,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // COMPLAINT PREVIEW
  // =========================================================

  Widget _complaintPreviewCard({
    required String title,
    required String category,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: _openMyComplaints,

      child: Container(
        margin:
        const EdgeInsets.only(bottom: 11),

        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(17),

          border: Border.all(
            color:
            const Color(0xFFE2E8F0),
          ),
        ),

        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              color.withValues(alpha: 0.10),

              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    category,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // COMMUNITY IMPACT
  // =========================================================

  Widget _communityImpact() {
    return InkWell(
      borderRadius:
      BorderRadius.circular(20),

      onTap: _openCitizens,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color:
          const Color(0xFFEFF6FF),

          borderRadius:
          BorderRadius.circular(20),

          border: Border.all(
            color:
            const Color(0xFFDCEBFF),
          ),
        ),

        child: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Icon(
                  Icons.groups_rounded,
                  color:
                  Color(0xFF2563EB),
                  size: 35,
                ),

                SizedBox(width: 12),

                Text(
                  'Community Impact',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xFF172B4D),
                  ),
                ),
              ],
            ),

            SizedBox(height: 18),

            Text(
              'Together, citizens have helped resolve',
              style: TextStyle(
                fontSize: 11,
                color:
                Color(0xFF718096),
              ),
            ),

            SizedBox(height: 4),

            Text(
              '1,842 civic issues',
              style: TextStyle(
                fontSize: 25,
                fontWeight:
                FontWeight.bold,
                color:
                Color(0xFF172B4D),
              ),
            ),

            SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color:
                  Color(0xFF16A34A),
                  size: 17,
                ),

                SizedBox(width: 5),

                Text(
                  '+16% this month',
                  style: TextStyle(
                    color:
                    Color(0xFF16A34A),
                    fontSize: 11,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}