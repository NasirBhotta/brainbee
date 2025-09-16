import 'dart:io';

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class BbManageProfile extends StatefulWidget {
  const BbManageProfile({super.key});

  @override
  State<BbManageProfile> createState() => _BbManageProfileState();
}

class _BbManageProfileState extends State<BbManageProfile> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();

  String _selectedState = 'Punjab';
  String _selectedCity = 'Lahore';
  String _selectedSchool = 'Your school';
  List<String> _cities = [];
  File? _image;
  String? _existingImageUrl; // For storing existing profile image URL
  bool _hasDataLoaded = false; // Track if we've loaded data once

  final Map<String, List<String>> pakistanStatesAndCities = {
    "Punjab": [
      "Lahore",
      "Rawalpindi",
      "Faisalabad",
      "Multan",
      "Gujranwala",
      "Sargodha",
      "Sialkot",
      "Bahawalpur",
      "Sheikhupura",
      "Rahim Yar Khan",
    ],
    "Sindh": [
      "Karachi",
      "Hyderabad",
      "Sukkur",
      "Larkana",
      "Mirpur Khas",
      "Nawabshah",
      "Jacobabad",
      "Shikarpur",
      "Khairpur",
      "Dadu",
    ],
    "Khyber Pakhtunkhwa": [
      "Peshawar",
      "Mardan",
      "Abbottabad",
      "Swat",
      "Kohat",
      "Dera Ismail Khan",
      "Bannu",
      "Charsadda",
      "Nowshera",
      "Mansehra",
    ],
    "Balochistan": [
      "Quetta",
      "Turbat",
      "Gwadar",
      "Khuzdar",
      "Sibi",
      "Zhob",
      "Dera Murad Jamali",
      "Chaman",
      "Loralai",
      "Pishin",
    ],
    "Azad Jammu and Kashmir": [
      "Muzaffarabad",
      "Mirpur",
      "Rawalakot",
      "Bagh",
      "Kotli",
      "Pallandri",
      "Hattian Bala",
      "Sudhnoti",
      "Barnala",
      "Dadyal",
    ],
    "Gilgit-Baltistan": [
      "Gilgit",
      "Skardu",
      "Hunza",
      "Ghizer",
      "Ghanche",
      "Shigar",
      "Diamer",
      "Astore",
      "Kharmang",
      "Nagar",
    ],
    "Islamabad Capital Territory": [
      "Islamabad",
      "Bari Imam",
      "Sihala",
      "Rawat",
      "Golra",
      "Tarnol",
      "Chak Shahzad",
      "Bhara Kahu",
      "F-10",
      "G-13",
    ],
  };

  final List<String> _states = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Gilgit-Baltistan',
    'Islamabad Capital Territory',
    'Azad Jammu and Kashmir',
  ];

  final List<String> _schools = [
    'Your school',
    'SMK Ampang',
    'SMK Kuala Lumpur',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _cities = pakistanStatesAndCities[_selectedState]!;

    // Fetch student data when screen loads
    context.read<StudentBloc>().add(const StudentFetchData());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  void _populateFields(StudentModel student) {
    if (!_hasDataLoaded) {
      _emailController.text = student.email ?? '';
      _firstNameController.text = student.firstName ?? '';
      _lastNameController.text = student.lastName ?? '';

      // Populate other fields if available in the model
      // Note: You may need to add these fields to your StudentModel
      // _mobileController.text = student.phoneNumber ?? '';
      // _dobController.text = student.dateOfBirth ?? '';
      // _addressController.text = student.address ?? '';
      // _postcodeController.text = student.postcode ?? '';

      // Set existing profile image URL if available
      // _existingImageUrl = student.profileImageUrl;

      _hasDataLoaded = true;
    }
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              if (_image != null || _existingImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _image = null;
                      _existingImageUrl = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    if (_image != null) {
      // Show newly selected image
      return CircleAvatar(radius: 60, backgroundImage: FileImage(_image!));
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      // Show existing profile image from server
      return CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(_existingImageUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle image loading error
          print('Error loading profile image: $exception');
        },
        child:
            _existingImageUrl!.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
      );
    } else {
      // Show default placeholder
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.green[600],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.person, color: Colors.white, size: 60),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentUpdateProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is StudentUpdateProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        // Show loading screen during data fetch or update
        if (state is StudentDataLoading) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Manage Account',
                style: context.textStyle.titleMedium,
              ),
              centerTitle: true,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            ),
          );
        }

        // Populate fields when data is loaded
        if (state is StudentDataLoaded) {
          _populateFields(state.student);
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Manage Account', style: context.textStyle.titleMedium),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: Center(
                      child: Stack(
                        children: [
                          _buildProfileImage(),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: BBColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Name Section
                  _buildSectionHeader('Name'),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    isRequired: true,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    isRequired: true,
                  ),

                  const SizedBox(height: 30),

                  // Contact Section
                  _buildSectionHeader('Contact'),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    isRequired: false,
                    enabled: false,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _mobileController,
                    label: 'Mobile',
                    isRequired: false,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 30),

                  // Info Section
                  _buildSectionHeader('Additional Info'),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    isRequired: false,
                    readOnly: true,
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                    ),
                    onTap: () => _selectDate(context),
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _addressController,
                    label: 'Home Address',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _postcodeController,
                    label: 'Postcode',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  _buildDropdownField(
                    value: _selectedState,
                    label: 'State',
                    items: _states,
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value!;
                        _cities = pakistanStatesAndCities[_selectedState]!;
                        _selectedCity = _cities[0];
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildDropdownField(
                    value: _selectedCity,
                    label: 'City',
                    items: _cities,
                    onChanged:
                        (value) => setState(() => _selectedCity = value!),
                  ),

                  const SizedBox(height: 16),

                  _buildDropdownField(
                    value: _selectedSchool,
                    label: 'School',
                    items: _schools,
                    onChanged:
                        (value) => setState(() => _selectedSchool = value!),
                  ),

                  const SizedBox(height: 40),

                  // Update Profile Button
                  Container(
                    width: context.screenWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [
                          BBColors.primaryColor,
                          BBColors.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed:
                          state is StudentDataLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          state is StudentDataLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Update Profile',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: BBColors.white,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Delete Account Section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Don't want to use BrainBee anymore?",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _showDeleteAccountDialog,
                          child: const Text(
                            'Delete My Account',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.blue[600],
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    Widget? suffixIcon,
    bool? enabled,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          enabled: enabled,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 14, color: Colors.black),
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: "Enter $label",
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: BBColors.bodyText,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 12 : 16,
            ),
            filled: true,
            fillColor: enabled == false ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: BBColors.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: suffixIcon,
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              onChanged: onChanged,
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2011, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: BBColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      // Only require image if no existing image and no new image selected
      if (_image == null &&
          (_existingImageUrl == null || _existingImageUrl!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a profile image'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Only update image if a new one is selected
      if (_image != null) {
        context.read<StudentBloc>().add(
          StudentUpdateProfile(
            image: _image!,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            address: _addressController.text.trim(),
            phoneNumber: _mobileController.text.trim(),
          ),
        );
      } else {
        // Handle other profile updates without image
        // You might want to create a separate event for this
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle account deletion logic here
                _showAccountDeletionConfirmation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAccountDeletionConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account deletion feature will be implemented soon'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
