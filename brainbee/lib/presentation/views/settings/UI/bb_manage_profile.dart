import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';

class BbManageProfile extends StatefulWidget {
  const BbManageProfile({super.key});

  @override
  State<BbManageProfile> createState() => _BbManageProfileState();
}

class _BbManageProfileState extends State<BbManageProfile> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();

  String _selectedState = 'Punjab';
  String _selectedCity = 'Lahore';
  String _selectedSchool = 'Your school';
  List<String> _cities = [];
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
      "Islamabad", // Single city, capital
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
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'N',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Name Section
              _buildSectionHeader('Name'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                isRequired: true,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                isRequired: true,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _nicknameController,
                label: 'Nickname',
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
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _mobileController,
                label: 'Mobile',
                isRequired: true,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 30),

              // Info Section
              _buildSectionHeader('Info'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _dobController,
                label: 'Date of Birth',
                isRequired: true,
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
                onChanged:
                    (value) => {
                      setState(() {
                        _selectedState = value!;

                        _cities = pakistanStatesAndCities[_selectedState]!;
                        _selectedCity =
                            pakistanStatesAndCities[_selectedState]![0];
                      }),
                    },
              ),

              const SizedBox(height: 16),

              _buildDropdownField(
                value: _selectedCity,
                label: 'City',
                items: _cities,
                onChanged: (value) => setState(() => _selectedCity = value!),
              ),

              const SizedBox(height: 16),

              _buildDropdownField(
                value: _selectedSchool,
                label: 'School',
                items: _schools,
                onChanged: (value) => setState(() => _selectedSchool = value!),
              ),

              const SizedBox(height: 40),

              // Update Profile Button
              Container(
                width: context.screenWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [BBColors.primaryColor, BBColors.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Update Profile',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 12, color: Colors.black),
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: "Enter $label",

            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: BBColors.bodyText,
            ),

            contentPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: label.startsWith('Home') ? 5 : 2,
            ),
            filled: true,
            fillColor: Colors.white,

            suffixIcon: suffixIcon,
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
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
            borderRadius: BorderRadius.circular(12),
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
                          fontSize: 12,
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
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString()}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      // Handle profile update logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle account deletion logic here
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
