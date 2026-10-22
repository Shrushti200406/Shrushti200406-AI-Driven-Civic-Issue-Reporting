import 'package:flutter/material.dart';
import 'home_page.dart';

class RegistrationPage
    extends StatefulWidget {
  const RegistrationPage({
    super.key,
  });

  @override
  State<RegistrationPage> createState() =>
      _RegistrationPageState();
}

class _RegistrationPageState
    extends State<RegistrationPage> {
  final _formKey =
  GlobalKey<FormState>();

  final TextEditingController
  _nameController =
  TextEditingController();

  final TextEditingController
  _emailController =
  TextEditingController();

  final TextEditingController
  _phoneController =
  TextEditingController();

  final TextEditingController
  _passwordController =
  TextEditingController();

  final TextEditingController
  _confirmPasswordController =
  TextEditingController();

  bool _obscurePassword = true;

  bool _obscureConfirmPassword =
  true;

  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();

    _emailController.dispose();

    _phoneController.dispose();

    _passwordController.dispose();

    _confirmPasswordController
        .dispose();

    super.dispose();
  }

  // ======================================================
  // CREATE ACCOUNT
  // ======================================================

  void _createAccount() {
    FocusScope.of(context)
        .unfocus();

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept the Terms & Conditions',
          ),

          backgroundColor:
          Colors.orange,
        ),
      );

      return;
    }

    Navigator.pushReplacement(
      context,

      MaterialPageRoute(
        builder: (context) =>
        const HomePage(),
      ),
    );
  }

  // ======================================================
  // VALIDATORS
  // ======================================================

  String? _validateName(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter your full name';
    }

    if (value.trim().length < 3) {
      return 'Name must contain at least 3 characters';
    }

    return null;
  }

  String? _validateEmail(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    );

    if (!emailRegex.hasMatch(
      value.trim(),
    )) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? _validatePhone(
      String? value,
      ) {
    final phone =
        value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Please enter your mobile number';
    }

    if (!RegExp(
      r'^[0-9]{10}$',
    ).hasMatch(phone)) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  String? _validatePassword(
      String? value,
      ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(
      String? value,
      ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value !=
        _passwordController
            .text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ======================================================
  // INPUT DECORATION
  // ======================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(
        icon,

        color:
        const Color(0xFF2563EB),
      ),

      suffixIcon:
      suffixIcon,

      filled: true,

      fillColor:
      const Color(0xFFEFF6FF),

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),

      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),

        borderSide:
        BorderSide.none,
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),

        borderSide:
        BorderSide(
          color:
          Colors.blue.shade100,
        ),
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),

        borderSide:
        const BorderSide(
          color:
          Color(0xFF2563EB),

          width: 1.5,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),

        borderSide:
        const BorderSide(
          color:
          Colors.redAccent,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),

        borderSide:
        const BorderSide(
          color:
          Colors.redAccent,

          width: 1.5,
        ),
      ),
    );
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      Colors.white,

      body: SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            30,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                // ==================================================
                // BACK
                // ==================================================

                IconButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },

                  icon:
                  const Icon(
                    Icons
                        .arrow_back_ios_new,
                  ),

                  color:
                  const Color(
                    0xFF172B4D,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                // ==================================================
                // LOGO
                // ==================================================

                Center(
                  child: Container(
                    width: 85,
                    height: 85,

                    padding:
                    const EdgeInsets.all(
                      10,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFEFF6FF,
                      ),

                      borderRadius:
                      BorderRadius
                          .circular(
                        26,
                      ),
                    ),

                    child:
                    Image.asset(
                      'assets/images/civic_logo.png',

                      fit:
                      BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                const Center(
                  child: Text(
                    'Create Account',

                    style:
                    TextStyle(
                      fontSize: 28,

                      fontWeight:
                      FontWeight
                          .w800,

                      color:
                      Color(
                        0xFF172B4D,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Center(
                  child: Text(
                    'Join Smart Civic and help build a\nbetter community.',

                    textAlign:
                    TextAlign
                        .center,

                    style:
                    TextStyle(
                      fontSize: 14,

                      height: 1.5,

                      color:
                      Color(
                        0xFF718096,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // ==================================================
                // NAME
                // ==================================================

                const Text(
                  'Full Name',

                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight
                        .w600,

                    color:
                    Color(
                      0xFF172B4D,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                TextFormField(
                  controller:
                  _nameController,

                  textCapitalization:
                  TextCapitalization
                      .words,

                  autovalidateMode:
                  AutovalidateMode
                      .onUserInteraction,

                  decoration:
                  _inputDecoration(
                    hint:
                    'Enter your full name',

                    icon:
                    Icons
                        .person_outline_rounded,
                  ),

                  validator:
                  _validateName,
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==================================================
                // EMAIL
                // ==================================================

                const Text(
                  'Email Address',

                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight
                        .w600,

                    color:
                    Color(
                      0xFF172B4D,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                TextFormField(
                  controller:
                  _emailController,

                  keyboardType:
                  TextInputType
                      .emailAddress,

                  autovalidateMode:
                  AutovalidateMode
                      .onUserInteraction,

                  decoration:
                  _inputDecoration(
                    hint:
                    'Enter your email',

                    icon:
                    Icons
                        .email_outlined,
                  ),

                  validator:
                  _validateEmail,
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==================================================
                // MOBILE
                // ==================================================

                const Text(
                  'Mobile Number',

                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight
                        .w600,

                    color:
                    Color(
                      0xFF172B4D,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                TextFormField(
                  controller:
                  _phoneController,

                  keyboardType:
                  TextInputType
                      .phone,

                  maxLength: 10,

                  autovalidateMode:
                  AutovalidateMode
                      .onUserInteraction,

                  decoration:
                  _inputDecoration(
                    hint:
                    'Enter 10-digit mobile number',

                    icon:
                    Icons
                        .phone_outlined,
                  ).copyWith(
                    counterText: '',
                  ),

                  validator:
                  _validatePhone,
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==================================================
                // PASSWORD
                // ==================================================

                const Text(
                  'Password',

                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight
                        .w600,

                    color:
                    Color(
                      0xFF172B4D,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                TextFormField(
                  controller:
                  _passwordController,

                  obscureText:
                  _obscurePassword,

                  autovalidateMode:
                  AutovalidateMode
                      .onUserInteraction,

                  decoration:
                  _inputDecoration(
                    hint:
                    'Create a password',

                    icon:
                    Icons
                        .lock_outline_rounded,

                    suffixIcon:
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },

                      icon: Icon(
                        _obscurePassword
                            ? Icons
                            .visibility_off_outlined
                            : Icons
                            .visibility_outlined,

                        color:
                        Colors.grey,
                      ),
                    ),
                  ),

                  validator:
                  _validatePassword,
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================

                const Text(
                  'Confirm Password',

                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight
                        .w600,

                    color:
                    Color(
                      0xFF172B4D,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                TextFormField(
                  controller:
                  _confirmPasswordController,

                  obscureText:
                  _obscureConfirmPassword,

                  autovalidateMode:
                  AutovalidateMode
                      .onUserInteraction,

                  decoration:
                  _inputDecoration(
                    hint:
                    'Re-enter your password',

                    icon:
                    Icons
                        .lock_reset_outlined,

                    suffixIcon:
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                          !_obscureConfirmPassword;
                        });
                      },

                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons
                            .visibility_off_outlined
                            : Icons
                            .visibility_outlined,

                        color:
                        Colors.grey,
                      ),
                    ),
                  ),

                  validator:
                  _validateConfirmPassword,
                ),

                const SizedBox(
                  height: 15,
                ),

                // ==================================================
                // TERMS
                // ==================================================

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Checkbox(
                      value:
                      _acceptedTerms,

                      activeColor:
                      const Color(
                        0xFF2563EB,
                      ),

                      onChanged:
                          (value) {
                        setState(() {
                          _acceptedTerms =
                              value ??
                                  false;
                        });
                      },
                    ),

                    const Expanded(
                      child:
                      Padding(
                        padding:
                        EdgeInsets.only(
                          top: 12,
                        ),

                        child:
                        Text.rich(
                          TextSpan(
                            text:
                            'I agree to the ',

                            style:
                            TextStyle(
                              color:
                              Color(
                                0xFF718096,
                              ),

                              fontSize:
                              13,
                            ),

                            children: [
                              TextSpan(
                                text:
                                'Terms & Conditions',

                                style:
                                TextStyle(
                                  color:
                                  Color(
                                    0xFF2563EB,
                                  ),

                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),

                              TextSpan(
                                text:
                                ' and ',
                              ),

                              TextSpan(
                                text:
                                'Privacy Policy',

                                style:
                                TextStyle(
                                  color:
                                  Color(
                                    0xFF2563EB,
                                  ),

                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                // ==================================================
                // CREATE ACCOUNT
                // ==================================================

                SizedBox(
                  width:
                  double.infinity,

                  height: 56,

                  child:
                  ElevatedButton(
                    onPressed:
                    _createAccount,

                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      const Color(
                        0xFF2563EB,
                      ),

                      foregroundColor:
                      Colors.white,

                      elevation: 0,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          16,
                        ),
                      ),
                    ),

                    child:
                    const Text(
                      'Create Account',

                      style:
                      TextStyle(
                        fontSize: 16,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                Center(
                  child:
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    child:
                    const Text.rich(
                      TextSpan(
                        text:
                        'Already have an account? ',

                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF718096,
                          ),
                        ),

                        children: [
                          TextSpan(
                            text:
                            'Sign In',

                            style:
                            TextStyle(
                              color:
                              Color(
                                0xFF2563EB,
                              ),

                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ],
                      ),
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
