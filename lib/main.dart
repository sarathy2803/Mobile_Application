import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class Firebase {
  static Future<void> initializeApp() async {
    // Simulate Firebase initialization
    await Future.delayed(const Duration(seconds: 1));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login UI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1273EB),
          primary: const Color(0xFF1273EB),
          secondary: const Color(0xFF1273EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'KALSUN INFRA',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1273EB),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Since 2008',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 5),
              Text(
                'Knowledge Guaranteed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1273EB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      builder: (context) => const RegistrationDialog(),
    );
  }

  Future<void> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // User cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        print('User UID: ${user.uid}');
        print('User Name: ${user.displayName}');
        print('User Email: ${user.email}');
        print('User Photo: ${user.photoURL}');
        // You can pass user info to DashboardPage or store it as needed
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login Page', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1273EB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Column(
                children: [
                  Text(
                    'KALSUN INFRA',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1273EB),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF1273EB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1273EB)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF1273EB)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF1273EB),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1273EB)),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1273EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _showRegistrationDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1273EB),
                    side: const BorderSide(color: Color(0xFF1273EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Register ?',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: Image.asset('assets/images/google.png', height: 24),
                  label: const Text('Sign In'),
                  onPressed: _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Color(0xFF1273EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final GlobalKey _notificationIconKey = GlobalKey();

  static const List<Widget> _pages = <Widget>[
    Center(child: HomePage()),
    Center(child: AboutUsPage()), // <-- Replace Chat Page with AboutUsPage
    Center(child: Text('Sell Page', style: TextStyle(fontSize: 24))),
    MyAdsPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showSellOptions(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showSellOptions(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        // This is not used because we are using transitionBuilder
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.white,
              elevation: 8.0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  10,
                  MediaQuery.of(context).padding.top + 20,
                  10,
                  20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'What do you want to sell?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSellOption(
                      context,
                      'Savudu Soil',
                      Icons.dashboard_customize,
                    ),
                    _buildSellOption(
                      context,
                      'Rough Peice Soil',
                      Icons.terrain,
                    ),
                    _buildSellOption(context, 'Earth Soil', Icons.inventory_2),
                    _buildSellOption(
                      context,
                      'Crusher Dust',
                      Icons.construction,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ListTile _buildSellOption(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Add $title selected')));
      },
    );
  }

  void _showNotifications() {
    // Get the render box of the icon to calculate its position
    final RenderBox renderBox =
        _notificationIconKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Dummy notification messages
    final List<String> dummyNotifications = [
      'Your order #12345 has been shipped.',
      'You have a new message from support.',
      'Flash Sale! 50% off on all cements.',
      'Welcome to KG! Complete your profile.',
    ];

    showMenu<String>(
      context: context,
      // Position the menu relative to the notification icon
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: dummyNotifications.map((String message) {
        return PopupMenuItem<String>(
          value: message,
          child: ListTile(
            leading: Icon(
              Icons.notifications_active_outlined,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(message, style: const TextStyle(fontSize: 14)),
          ),
        );
      }).toList(),
    ).then((selectedValue) {
      if (selectedValue == null) return;
      // Handle tap on a notification item if needed
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tapped on: $selectedValue')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'KALSUN INFRA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            // Text(
            //   'Knowledge Guaranteed',
            //   style: TextStyle(
            //     fontSize: 12,
            //     // ignore: deprecated_member_use
            //     color: Colors.white.withOpacity(0.8),
            //   ),
            // ),
          ],
        ),
        backgroundColor: const Color(0xFF1273EB),
        actions: [
          IconButton(
            key: _notificationIconKey,
            icon: const Icon(Icons.notifications, color: Colors.orange),
            onPressed: _showNotifications,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.orange,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Wishlist clicked')),
                            );
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
            backgroundColor: const Color.fromARGB(255, 58, 18, 235),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: 'About Us',
            backgroundColor: const Color.fromARGB(255, 58, 18, 235),
          ),
          BottomNavigationBarItem(
            icon: Container(
              // Outer container for the gradient border
              padding: const EdgeInsets.all(
                2,
              ), // This padding creates the border width
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [
                    Colors.orange,
                    Colors.yellow,
                    Colors.white,
                    Colors
                        .orange, // Loop back to orange for a smooth transition
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                // Inner container for the icon
                decoration: const BoxDecoration(
                  color: Color(0xFF1273EB),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: 'My Ads',
            backgroundColor: const Color(0xFF1273EB),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Account',
            backgroundColor: const Color(0xFF1273EB),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        // ignore: deprecated_member_use
        unselectedItemColor: Colors.blue.withOpacity(0.7),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const SizedBox(height: 30),
        Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'User Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'View and edit profile',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Divider(),
        _buildMenuOption(
          context,
          icon: Icons.favorite_border,
          title: 'Wishlist',
          onTap: () {},
        ),
        _buildMenuOption(
          context,
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () {},
        ),
        _buildMenuOption(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {},
        ),
        _buildMenuOption(
          context,
          icon: Icons.language,
          title: 'Select Language',
          onTap: () {},
        ),
        _buildMenuOption(
          context,
          icon: Icons.workspace_premium_outlined,
          title: 'Elite Packages for Buyers',
          onTap: () {},
        ),
        // const SizedBox(height: 40),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 24.0),
        //   child: SizedBox(
        //     width: double.infinity,
        //     height: 50,
        //     child: ElevatedButton(
        //       onPressed: _applyChanges,
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Theme.of(context).primaryColor,
        //         foregroundColor: Colors.white,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(10),
        //         ),
        //       ),
        //       child: const Text('Save Changes', style: TextStyle(fontSize: 12)),
        //     ),
        //   ),
        // ),
        _buildMenuOption(
          context,
          icon: Icons.lock_outline,
          title: 'Change Password',
          onTap: () {
            // Navigate to change password screen or show a dialog
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChangePasswordPage()),
            );
          },
        ),
        _buildMenuOption(
          context,
          icon: Icons.logout,
          title: 'Logout',
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  ListTile _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Implement password change logic here
                Navigator.pop(context);
              },
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyAdsPage extends StatefulWidget {
  const MyAdsPage({super.key});

  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _adImage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  Future<void> _postAd() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _adImage = File(image.path);
        _fadeController.forward(from: 0); // Start fade-in animation
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selected! Path: ${image.path}')),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _adImage != null
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _adImage!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Icon(
                  Icons.dynamic_feed_outlined,
                  size: 100,
                  color: Colors.grey.shade300,
                ),
          const SizedBox(height: 20),
          const Text(
            'You have no ads',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Tap the button below to post your first ad.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 30),
          // 2. Animated button press effect
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: _postAd,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Post Ad'),
              style: ElevatedButton.styleFrom(
                animationDuration: const Duration(milliseconds: 200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentListingItem {
  final String title;
  final String category;
  final String price;
  final String imagePath;

  const RecentListingItem({
    required this.title,
    required this.category,
    required this.price,
    required this.imagePath,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, String>> _featuredItems = const [
    {
      'title': 'Land Survey with Topo Sketch',
      'imagePath': 'assets/images/bricks.png',
    },
    {'title': 'Soil Testing', 'imagePath': 'assets/images/stones.png'},
    {'title': 'Site Cleaning', 'imagePath': 'assets/images/soil.png'},
    {'title': 'Architect Drawing', 'imagePath': 'assets/images/steel.png'},
    {
      'title': 'Soil Filling & Levelling',
      'imagePath': 'assets/images/stones.png',
    },
  ];

  final List<RecentListingItem> _recentListings = const [
    RecentListingItem(
      title: 'SAVUDU SOIL',
      category: 'Savudu soil is used for stable and firm base preparation',
      price: '₹10',
      imagePath: 'assets/images/bricks.png',
    ),
    RecentListingItem(
      title: 'ROUGH PIECE SOIL',
      category: 'Civil',
      price: '₹1200',
      imagePath: 'assets/images/cement.png',
    ),
    RecentListingItem(
      title: 'EARTH SOIL',
      category: 'Civil',
      price: '₹150',
      imagePath: 'assets/images/stones.png',
    ),
    RecentListingItem(
      title: 'CRUSHER DUST',
      category: 'Civil',
      price: '₹50',
      imagePath: 'assets/images/steel.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'OUR SERVICES',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16, width: 54),
        CarouselSlider(
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
          ),
          items: _featuredItems.map((item) {
            return _buildFeaturedItem(item['title']!, item['imagePath']!);
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Listings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Animated list appearance
        ..._recentListings.asMap().entries.map((entry) {
          int idx = entry.key;
          RecentListingItem item = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + idx * 100),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 30),
                  child: child,
                ),
              );
            },
            child: _buildListItem(item),
          );
        }),
      ],
    );
  }

  Widget _buildFeaturedItem(String title, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: Stack(
          children: <Widget>[
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 1000.0,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                );
              },
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(200, 0, 0, 0),
                      Color.fromARGB(0, 0, 0, 0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(RecentListingItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Image.asset(
          item.imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
          },
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item.category),
        trailing: Text(
          item.price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1273EB),
          ),
        ),
      ),
    );
  }
}

class RegistrationDialog extends StatefulWidget {
  const RegistrationDialog({super.key});

  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _dialogController;
  late Animation<double> _dialogScale;

  @override
  void initState() {
    super.initState();
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _dialogScale = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.elasticOut,
    );
    _dialogController.forward();
  }

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _dialogScale,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1273EB),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF1273EB),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    if (!RegExp(
                      r'^(?=.*[A-Za-z])(?=.*\d).{6,}$',
                    ).hasMatch(value)) {
                      return 'Password must contain letters and numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1273EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  final List<Map<String, String>> _aboutCards = const [
    {
      'title': 'Complete Site Preparation',
      'desc': 'From land survey to compound wall, we handle it all.',
      'imagePath': 'assets/images/site_prep.png',
    },
    {
      'title': 'Professional & Prompt Execution',
      'desc': 'We value your timelines and investments.',
      'imagePath': 'assets/images/prof_prompt.png',
    },
    {
      'title': 'Approval & Compliance Support',
      'desc': 'We take care of paperwork and approvals for you.',
      'imagePath': 'assets/images/approval_complaince.png',
    },
    {
      'title': 'Expert Team & Quality Workmanship',
      'desc':
          'Our team ensures your land is ready for hassle-free construction.',
      'imagePath': 'assets/images/expert_team.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Why choose us?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1273EB),
          ),
        ),
        const SizedBox(height: 24),
        ..._aboutCards.map(
          (card) => Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      card['imagePath']!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    card['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1273EB),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card['desc']!,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
