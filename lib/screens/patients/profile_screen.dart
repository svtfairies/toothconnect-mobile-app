import 'package:flutter/material.dart';
import '../../glob/users.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  static const Color gold = Color(0xFFB77A00);
  static const Color lightGold = Color(0xFFD4A017);
  static const Color background = Color(0xFFF5F6FA);
  static const Color inputBorder = Color(0xFFCFCFCF);
  static const Color errorColor = Color(0xFFD9534F);

  final List<String> nationalities = const ['Filipino', 'American', 'Australian', 'British', 'Canadian', 'Chinese', 'French', 'German', 'Indian', 'Indonesian', 'Italian', 'Japanese', 'Korean', 'Malaysian', 'Singaporean', 'Spanish', 'Thai', 'Vietnamese', 'Other'];

  final List<String> civilStatuses = const ['Single', 'Married', 'Widowed', 'Divorced', 'Separated'];

  final List<Map<String, dynamic>> phoneCountries = const [
    {'country': 'PH', 'callingCode': '63', 'min': 10, 'max': 10, 'placeholder': '9123456789'},
    {'country': 'US', 'callingCode': '1', 'min': 10, 'max': 10, 'placeholder': '2015550123'},
    {'country': 'CA', 'callingCode': '1', 'min': 10, 'max': 10, 'placeholder': '4165550123'},
    {'country': 'GB', 'callingCode': '44', 'min': 10, 'max': 10, 'placeholder': '7123456789'},
    {'country': 'AU', 'callingCode': '61', 'min': 9, 'max': 9, 'placeholder': '412345678'},
    {'country': 'SG', 'callingCode': '65', 'min': 8, 'max': 8, 'placeholder': '81234567'},
    {'country': 'MY', 'callingCode': '60', 'min': 9, 'max': 10, 'placeholder': '123456789'},
    {'country': 'JP', 'callingCode': '81', 'min': 10, 'max': 10, 'placeholder': '9012345678'},
    {'country': 'KR', 'callingCode': '82', 'min': 9, 'max': 10, 'placeholder': '1012345678'},
  ];

  final Map<String, TextEditingController> controllers = {};

  bool isEditing = false;
  bool loadingProfile = false;
  bool savingProfile = false;
  bool sidebarOpen = false;

  String nationality = '';
  String civilStatus = '';
  String sex = '';
  String contactCountry = 'PH';
  String emergencyContactCountry = 'PH';

  final Map<String, String> errors = {};
  final Map<String, bool> touched = {};

  Map<String, dynamic> get currentUser {
    return AllUsers.currentUser ?? {'name': 'My Account', 'branchAddress': 'My Branch'};
  }

  String get userEmail => AllUsers.currentUser?['email']?.toString() ?? '';

  String get patientSince {
    final value = AllUsers.currentUser?['created_at'];
    if (value == null) return '';
    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else {
      date = DateTime.tryParse(value.toString());
    }
    if (date == null) return '';
    return 'Patient since ${monthName(date.month)} ${date.year}';
  }

  String get initials {
    final name = controllers['fullName']?.text.trim() ?? '';
    if (name.isEmpty) return 'U';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    createControllers();
    loadUser();
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void createControllers() {
    controllers['fullName'] = TextEditingController();
    controllers['birthday'] = TextEditingController();
    controllers['age'] = TextEditingController();
    controllers['homeAddress'] = TextEditingController();
    controllers['occupation'] = TextEditingController();
    controllers['contact'] = TextEditingController();
    controllers['email'] = TextEditingController();
    controllers['emergencyContactName'] = TextEditingController();
    controllers['emergencyContactNumber'] = TextEditingController();
    controllers['medicalConditions'] = TextEditingController();
    controllers['allergies'] = TextEditingController();
    controllers['medications'] = TextEditingController();
    controllers['dentalHistory'] = TextEditingController();
  }

  void loadUser() {
    final user = AllUsers.currentUser ?? {};

    controllers['fullName']!.text = user['full_name']?.toString() ?? user['name']?.toString() ?? '';
    controllers['birthday']!.text = displayDate(user['birthday']);
    controllers['age']!.text = user['age']?.toString() ?? calculateAge(controllers['birthday']!.text);
    controllers['homeAddress']!.text = user['address']?.toString() ?? user['home_address']?.toString() ?? '';
    controllers['occupation']!.text = user['occupation']?.toString() ?? '';
    controllers['contact']!.text = parsePhone(user['contact_number'] ?? user['phone'])['number'] ?? '';
    controllers['email']!.text = user['email']?.toString() ?? '';
    controllers['emergencyContactName']!.text = user['emergency_contact_name']?.toString() ?? '';
    controllers['emergencyContactNumber']!.text = parsePhone(user['emergency_contact_number'])['number'] ?? '';
    controllers['medicalConditions']!.text = user['medical_conditions']?.toString() ?? '';
    controllers['allergies']!.text = user['allergies']?.toString() ?? '';
    controllers['medications']!.text = user['medications']?.toString() ?? '';
    controllers['dentalHistory']!.text = user['dental_history']?.toString() ?? '';

    nationality = user['nationality']?.toString() ?? '';
    civilStatus = user['civil_status']?.toString() ?? '';
    sex = user['sex']?.toString() ?? '';

    final contact = parsePhone(user['contact_number'] ?? user['phone']);
    final emergency = parsePhone(user['emergency_contact_number']);

    contactCountry = contact['country'] ?? 'PH';
    emergencyContactCountry = emergency['country'] ?? 'PH';

    if (mounted) {
      setState(() {
        loadingProfile = false;
      });
    }
  }

  String monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String displayDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return '';
    final text = value.toString();
    final raw = text.length >= 10 ? text.substring(0, 10) : text;
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw);
    if (match == null) return '';
    return '${match.group(2)}/${match.group(3)}/${match.group(1)}';
  }

  String? apiDate(String value) {
    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value);
    if (match == null) return null;
    return '${match.group(3)}-${match.group(1)}-${match.group(2)}';
  }

  Map<String, String> parsePhone(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return {'country': 'PH', 'number': ''};
    }

    if (raw.startsWith('+')) {
      for (final item in phoneCountries) {
        final code = item['callingCode'].toString();
        if (digits.startsWith(code)) {
          return {'country': item['country'].toString(), 'number': digits.substring(code.length)};
        }
      }
    }

    if (digits.startsWith('0')) {
      return {'country': 'PH', 'number': digits.substring(1)};
    }

    return {'country': 'PH', 'number': digits};
  }

  Map<String, dynamic> phoneCountry(String country) {
    return phoneCountries.firstWhere((item) => item['country'] == country, orElse: () => phoneCountries.first);
  }

  String formatPhone(String value, String country) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    final selected = phoneCountry(country);
    final number = country == 'PH' && digits.startsWith('0') ? digits.substring(1) : digits;
    return '+${selected['callingCode']}$number';
  }

  String calculateAge(String birthday) {
    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(birthday.trim());
    if (match == null) return '';

    final month = int.tryParse(match.group(1)!) ?? 0;
    final day = int.tryParse(match.group(2)!) ?? 0;
    final year = int.tryParse(match.group(3)!) ?? 0;

    if (month < 1 || month > 12 || day < 1 || year < 1) return '';

    final birthDate = DateTime(year, month, day);

    if (birthDate.year != year || birthDate.month != month || birthDate.day != day || birthDate.isAfter(DateTime.now())) {
      return '';
    }

    final today = DateTime.now();
    var age = today.year - birthDate.year;

    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age.toString();
  }

  String formatBirthday(String value) {
    final numbers = value.replaceAll(RegExp(r'\D'), '');
    final limited = numbers.length > 8 ? numbers.substring(0, 8) : numbers;

    if (limited.length <= 2) return limited;
    if (limited.length <= 4) return '${limited.substring(0, 2)}/${limited.substring(2)}';

    return '${limited.substring(0, 2)}/${limited.substring(2, 4)}/${limited.substring(4)}';
  }

  String stripNumbers(String value) {
    return value.replaceAll(RegExp(r'[0-9]'), '');
  }

  String fieldRequired(String value) {
    return value.trim().isEmpty ? 'This field is required.' : '';
  }

  String phoneError(String value, String country, bool required) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return required ? 'This field is required.' : '';
    }

    final selected = phoneCountry(country);
    final min = selected['min'] as int;
    final max = selected['max'] as int;

    if (digits.length < min || digits.length > max) {
      return 'Contact Number does not match the selected country code';
    }

    return '';
  }

  String fieldError(String field) {
    if (field == 'fullName') {
      final value = controllers['fullName']!.text.trim();

      if (value.isEmpty) return 'This field is required.';

      if (value.split(RegExp(r'\s+')).length < 2) {
        return 'Please enter both first and last name';
      }

      if (RegExp(r'\d').hasMatch(value)) {
        return 'Numbers are not allowed.';
      }
    }

    if (field == 'birthday') {
      final value = controllers['birthday']!.text.trim();

      if (value.isEmpty) return 'This field is required.';

      if (calculateAge(value).isEmpty) {
        return 'Please use a valid birthday format: MM/DD/YYYY.';
      }
    }

    if (field == 'homeAddress' && controllers['homeAddress']!.text.trim().isEmpty) {
      return 'This field is required.';
    }

    if (field == 'occupation') {
      final value = controllers['occupation']!.text.trim();

      if (value.isEmpty) return 'This field is required.';

      if (RegExp(r'\d').hasMatch(value)) {
        return 'Numbers are not allowed.';
      }
    }

    if (field == 'nationality' && nationality.trim().isEmpty) {
      return 'This field is required.';
    }

    if (field == 'sex' && sex.trim().isEmpty) {
      return 'This field is required.';
    }

    if (field == 'civilStatus' && civilStatus.trim().isEmpty) {
      return 'This field is required.';
    }

    if (field == 'contact') {
      return phoneError(controllers['contact']!.text, contactCountry, true);
    }

    if (field == 'email') {
      final value = controllers['email']!.text.trim();

      if (value.isEmpty) return 'This field is required.';

      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
        return 'Please enter a valid email address.';
      }
    }

    if (['emergencyContactName', 'medicalConditions', 'allergies', 'medications', 'dentalHistory'].contains(field)) {
      final value = controllers[field]!.text;

      if (RegExp(r'\d').hasMatch(value)) {
        return 'Numbers are not allowed.';
      }
    }

    return '';
  }

  void updateError(String field) {
    setState(() {
      errors[field] = fieldError(field);
      touched[field] = true;
    });
  }

  void updateText(String field, String value) {
    setState(() {
      controllers[field]!.text = value;
      controllers[field]!.selection = TextSelection.collapsed(offset: value.length);

      if (touched[field] == true) {
        errors[field] = fieldError(field);
      }
    });
  }

  void updateNoNumber(String field, String value) {
    updateText(field, stripNumbers(value));
  }

  void updateBirthday(String value) {
    final formatted = formatBirthday(value);

    setState(() {
      controllers['birthday']!.text = formatted;
      controllers['birthday']!.selection = TextSelection.collapsed(offset: formatted.length);
      controllers['age']!.text = calculateAge(formatted);

      if (touched['birthday'] == true) {
        errors['birthday'] = fieldError('birthday');
      }
    });
  }

  void updatePhone(String field, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    setState(() {
      controllers[field]!.text = digits;
      controllers[field]!.selection = TextSelection.collapsed(offset: digits.length);

      if (field == 'contact' && touched[field] == true) {
        errors[field] = phoneError(digits, contactCountry, true);
      }
    });
  }

  void updatePhoneCountry(String field, String country) {
    setState(() {
      if (field == 'contactCountry') {
        contactCountry = country;

        if (touched['contact'] == true) {
          errors['contact'] = phoneError(controllers['contact']!.text, country, true);
        }
      } else {
        emergencyContactCountry = country;
      }
    });
  }

  bool validateForm() {
    final newErrors = <String, String>{};

    final fields = ['fullName', 'birthday', 'homeAddress', 'occupation', 'nationality', 'sex', 'contact', 'email', 'civilStatus', 'emergencyContactName', 'medicalConditions', 'allergies', 'medications', 'dentalHistory'];

    for (final field in fields) {
      final error = fieldError(field);

      if (error.isNotEmpty) {
        newErrors[field] = error;
      }
    }

    setState(() {
      errors
        ..clear()
        ..addAll(newErrors);

      for (final field in fields) {
        touched[field] = true;
      }
    });

    return newErrors.isEmpty;
  }

  void toggleEdit() {
    if (isEditing) {
      loadUser();

      setState(() {
        isEditing = false;
        errors.clear();
        touched.clear();
      });

      return;
    }

    setState(() {
      isEditing = true;
      errors.clear();
      touched.clear();
    });
  }

  void saveProfile() {
    if (!validateForm()) return;

    setState(() {
      savingProfile = true;
    });

    final user = AllUsers.currentUser ?? {};

    user['name'] = controllers['fullName']!.text.trim();
    user['full_name'] = controllers['fullName']!.text.trim();
    user['birthday'] = apiDate(controllers['birthday']!.text);
    user['age'] = int.tryParse(controllers['age']!.text);
    user['nationality'] = nationality.trim();
    user['address'] = controllers['homeAddress']!.text.trim();
    user['occupation'] = controllers['occupation']!.text.trim();
    user['sex'] = sex;
    user['contact_number'] = formatPhone(controllers['contact']!.text, contactCountry);
    user['phone'] = formatPhone(controllers['contact']!.text, contactCountry);
    user['email'] = controllers['email']!.text.trim().toLowerCase();
    user['civil_status'] = civilStatus;
    user['emergency_contact_name'] = controllers['emergencyContactName']!.text.trim();
    user['emergency_contact_number'] = controllers['emergencyContactNumber']!.text.trim().isEmpty ? null : formatPhone(controllers['emergencyContactNumber']!.text, emergencyContactCountry);
    user['medical_conditions'] = controllers['medicalConditions']!.text.trim();
    user['allergies'] = controllers['allergies']!.text.trim();
    user['medications'] = controllers['medications']!.text.trim();
    user['dental_history'] = controllers['dentalHistory']!.text.trim();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        savingProfile = false;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your profile information has been saved.')),
      );
    });
  }

  void openSidebar() {
    setState(() {
      sidebarOpen = true;
    });
  }

  void closeSidebar() {
    setState(() {
      sidebarOpen = false;
    });
  }

  void navigate(String route) {
    closeSidebar();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      Navigator.pushNamed(context, route);
    });
  }

  void logout() {
    closeSidebar();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                AllUsers.currentUser = null;
                Navigator.pop(dialogContext);
                Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
              },
              child: const Text('Logout', style: TextStyle(color: errorColor)),
            ),
          ],
        );
      },
    );
  }

  void showNationalityDialog() {
    if (!isEditing) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Nationality', textAlign: TextAlign.center, style: TextStyle(color: gold, fontWeight: FontWeight.w900)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: nationalities.length,
              itemBuilder: (context, index) {
                final item = nationalities[index];

                return InkWell(
                  onTap: () {
                    setState(() {
                      nationality = item;
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Text(item, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ],
        );
      },
    );
  }

  void showCivilStatusDialog() {
    if (!isEditing) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Civil Status', textAlign: TextAlign.center, style: TextStyle(color: gold, fontWeight: FontWeight.w900)),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: civilStatuses.length,
              itemBuilder: (context, index) {
                final item = civilStatuses[index];

                return InkWell(
                  onTap: () {
                    setState(() {
                      civilStatus = item;
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Text(item, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ],
        );
      },
    );
  }

  void showPhoneCountryDialog(String field) {
    if (!isEditing) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Country Code', textAlign: TextAlign.center, style: TextStyle(color: gold, fontWeight: FontWeight.w900)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: phoneCountries.length,
              itemBuilder: (context, index) {
                final item = phoneCountries[index];

                return InkWell(
                  onTap: () {
                    updatePhoneCountry(field, item['country'].toString());
                    Navigator.pop(dialogContext);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Text('${item['country']} +${item['callingCode']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ],
        );
      },
    );
  }

  Widget fieldLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 13, color: gold, fontWeight: FontWeight.w900),
          children: required ? const [TextSpan(text: ' *', style: TextStyle(color: errorColor))] : [],
        ),
      ),
    );
  }

  Widget inputField(String field, {String? hint, bool required = false, bool multiline = false, bool numbersOnly = false, TextInputType? keyboardType}) {
    final controller = controllers[field]!;
    final hasError = errors[field]?.isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldLabel(labelText(field), required: required),
        TextField(
          controller: controller,
          enabled: isEditing && field != 'age',
          keyboardType: keyboardType,
          maxLines: multiline ? 4 : 1,
          minLines: multiline ? 3 : 1,
          maxLength: field == 'birthday' ? 10 : null,
          onChanged: (value) {
            if (field == 'birthday') {
              updateBirthday(value);
            } else if (field == 'contact' || field == 'emergencyContactNumber') {
              updatePhone(field, value);
            } else if (numbersOnly) {
              updateNoNumber(field, value);
            } else {
              updateText(field, value);
            }
          },
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
            updateError(field);
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFA8A8A8), fontSize: 14),
            filled: true,
            fillColor: isEditing && field != 'age' ? Colors.white : const Color(0xFFFAFAFA),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: inputBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: hasError ? errorColor : inputBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: hasError ? errorColor : gold)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: inputBorder)),
          ),
        ),
        if (hasError) Padding(padding: const EdgeInsets.only(top: 5), child: Text(errors[field]!, style: const TextStyle(color: errorColor, fontSize: 11, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget phoneField(String label, String field, String countryField, {bool required = false}) {
    final country = countryField == 'contactCountry' ? contactCountry : emergencyContactCountry;
    final selected = phoneCountry(country);
    final hasError = errors[field]?.isNotEmpty == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fieldLabel(label, required: required),
          Row(
            children: [
              SizedBox(
                width: 105,
                height: 48,
                child: OutlinedButton(
                  onPressed: isEditing ? () => showPhoneCountryDialog(countryField) : null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isEditing ? Colors.white : const Color(0xFFFAFAFA),
                    side: BorderSide(color: hasError ? errorColor : inputBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${selected['country']} +${selected['callingCode']}', style: const TextStyle(fontSize: 12, color: Color(0xFF222222), fontWeight: FontWeight.w700)),
                      const Icon(Icons.keyboard_arrow_down, color: gold, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controllers[field],
                  enabled: isEditing,
                  keyboardType: TextInputType.phone,
                  maxLength: selected['max'] as int,
                  onChanged: (value) => updatePhone(field, value),
                  decoration: InputDecoration(
                    hintText: required ? selected['placeholder'].toString() : 'Optional',
                    hintStyle: const TextStyle(color: Color(0xFFA8A8A8), fontSize: 14),
                    counterText: '',
                    filled: true,
                    fillColor: isEditing ? Colors.white : const Color(0xFFFAFAFA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: inputBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: hasError ? errorColor : inputBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: hasError ? errorColor : gold)),
                    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: inputBorder)),
                  ),
                ),
              ),
            ],
          ),
          if (hasError) Padding(padding: const EdgeInsets.only(top: 5), child: Text(errors[field]!, style: const TextStyle(color: errorColor, fontSize: 11, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget dropdownField(String label, String value, VoidCallback onTap, {bool required = false, String placeholder = 'Select'}) {
    final hasError = label == 'Nationality' ? errors['nationality']?.isNotEmpty == true : errors['civilStatus']?.isNotEmpty == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fieldLabel(label, required: required),
          InkWell(
            onTap: isEditing ? onTap : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isEditing ? Colors.white : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: hasError ? errorColor : inputBorder),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(value.isEmpty ? placeholder : value, style: TextStyle(fontSize: 14, color: value.isEmpty ? const Color(0xFFA8A8A8) : const Color(0xFF222222)))),
                  const Icon(Icons.keyboard_arrow_down, color: gold),
                ],
              ),
            ),
          ),
          if (hasError) Padding(padding: const EdgeInsets.only(top: 5), child: Text(label == 'Nationality' ? errors['nationality']! : errors['civilStatus']!, style: const TextStyle(color: errorColor, fontSize: 11, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  String labelText(String field) {
    const labels = {
      'fullName': 'Full Name',
      'birthday': 'Birthday',
      'homeAddress': 'Home Address',
      'occupation': 'Occupation',
      'email': 'Email',
      'emergencyContactName': 'Emergency Contact Name',
      'medicalConditions': 'Medical Conditions',
      'allergies': 'Allergies',
      'medications': 'Medications',
      'dentalHistory': 'Dental History',
    };

    return labels[field] ?? field;
  }

  Widget sidebarItem(IconData icon, String title, VoidCallback onTap, {bool active = false, int badge = 0}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: active ? const Color(0xFFFFF8E7) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 20, color: const Color(0xFFB47A00)),
                if (badge > 0) Positioned(right: -7, top: -7, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), constraints: const BoxConstraints(minWidth: 16), decoration: const BoxDecoration(color: Color(0xFFE53E3E), shape: BoxShape.circle), child: Text(badge > 9 ? '9+' : '$badge', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)))),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFFB47A00), fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    );
  }

  Widget sidebar() {
    return Stack(
      children: [
        Positioned.fill(child: GestureDetector(onTap: closeSidebar, child: Container(color: Colors.black.withValues(alpha: 0.42)))),
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            elevation: 20,
            child: SafeArea(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(11)), alignment: Alignment.center, child: Text(initials, style: const TextStyle(fontSize: 20, color: Color(0xFFB47A00), fontWeight: FontWeight.w900))),
                        const SizedBox(width: 13),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(AllUsers.currentUser?['name']?.toString() ?? 'My Account', style: const TextStyle(fontSize: 18, color: Color(0xFFB47A00), fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(AllUsers.currentUser?['branchAddress']?.toString() ?? 'Dental Clinic', style: const TextStyle(fontSize: 13, color: Color(0xFF8A650E)))])),
                      ],
                    ),
                    const Divider(height: 29),
                    Expanded(
                      child: ListView(
                        children: [
                          sidebarItem(Icons.home_outlined, 'Home', () => navigate('/home')),
                          sidebarItem(Icons.person_outline, 'Profile', closeSidebar, active: true),
                          sidebarItem(Icons.message_outlined, 'Message', () => navigate('messages-list')),
                          sidebarItem(Icons.calendar_month_outlined, 'Appointments', () => navigate('/appointments')),
                          sidebarItem(Icons.history, 'History', () => navigate('/records')),
                          sidebarItem(Icons.assignment_outlined, 'Treatment Plan', () => navigate('/dental-treatment-plan')),
                          sidebarItem(Icons.notifications_none, 'Notifications', () => navigate('/notifications')),
                        ],
                      ),
                    ),
                    const Divider(height: 29),
                    sidebarItem(Icons.logout, 'Sign Out', logout),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget sexButton(String value) {
    final selected = sex == value;

    return Expanded(
      child: InkWell(
        onTap: isEditing ? () { setState(() { sex = value; }); updateError('sex'); } : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 43,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: selected ? gold : isEditing ? Colors.white : const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(8), border: Border.all(color: errors['sex']?.isNotEmpty == true ? errorColor : selected ? gold : inputBorder)),
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: selected ? Colors.white : gold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 34),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)), boxShadow: [BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 3))]),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(onPressed: openSidebar, icon: const Icon(Icons.menu, size: 30, color: gold)),
                            const Expanded(child: Text('Profile', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF1F1F1F)))),
                            OutlinedButton(
                              onPressed: loadingProfile || savingProfile ? null : toggleEdit,
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7), shape: const StadiumBorder(), side: const BorderSide(color: Color(0xFFC9A64C))),
                              child: Text(isEditing ? 'Cancel' : 'Edit Profile', style: const TextStyle(fontSize: 12, color: Color(0xFF111111), fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(width: 74, height: 74, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD4B15D))), alignment: Alignment.center, child: Text(initials, style: const TextStyle(fontSize: 28, color: gold, fontWeight: FontWeight.w900))),
                        const SizedBox(height: 10),
                        Text(controllers['fullName']!.text.trim().isEmpty ? 'Patient Name' : controllers['fullName']!.text.trim(), style: const TextStyle(fontSize: 18, color: gold, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                        if (patientSince.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(patientSince, style: const TextStyle(fontSize: 11, color: Color(0xFF111111), fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    padding: const EdgeInsets.fromLTRB(18, 21, 18, 26),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 9, offset: Offset(0, 3))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: Text('Personal Information Record', style: TextStyle(fontSize: 21, color: gold, fontWeight: FontWeight.w900))),
                        const SizedBox(height: 13),
                        Center(child: Container(width: MediaQuery.of(context).size.width * 0.7, height: 1.5, color: lightGold)),
                        const SizedBox(height: 25),
                        if (loadingProfile) const Padding(padding: EdgeInsets.only(bottom: 18), child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: gold)), SizedBox(width: 8), Text('Loading profile...', style: TextStyle(color: Color(0xFF8A650E), fontSize: 13, fontWeight: FontWeight.w700))]))),
                        inputField('fullName', hint: 'Enter first name and last name', required: true, numbersOnly: true),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: inputField('birthday', hint: 'MM/DD/YYYY', required: true, keyboardType: TextInputType.number)),
                            const SizedBox(width: 14),
                            Expanded(child: inputField('age', hint: 'Auto', keyboardType: TextInputType.number)),
                          ],
                        ),
                        dropdownField('Nationality', nationality, showNationalityDialog, required: true, placeholder: 'Select nationality'),
                        inputField('homeAddress', hint: 'Enter complete home address', required: true, multiline: true),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: inputField('occupation', hint: 'Occupation', required: true, numbersOnly: true)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [fieldLabel('Sex', required: true), Row(children: [sexButton('Male'), const SizedBox(width: 8), sexButton('Female')]), if (errors['sex']?.isNotEmpty == true) Padding(padding: const EdgeInsets.only(top: 5), child: Text(errors['sex']!, style: const TextStyle(color: errorColor, fontSize: 11, fontWeight: FontWeight.w600)))])),
                          ],
                        ),
                        phoneField('Contact', 'contact', 'contactCountry', required: true),
                        inputField('email', hint: 'Enter email address', required: true, keyboardType: TextInputType.emailAddress),
                        dropdownField('Civil Status', civilStatus, showCivilStatusDialog, required: true, placeholder: 'Select civil status'),
                        inputField('emergencyContactName', hint: 'Optional', numbersOnly: true),
                        phoneField('Emergency Contact Number', 'emergencyContactNumber', 'emergencyContactCountry'),
                        inputField('medicalConditions', hint: 'Optional', multiline: true, numbersOnly: true),
                        inputField('allergies', hint: 'Optional', multiline: true, numbersOnly: true),
                        inputField('medications', hint: 'Optional', multiline: true, numbersOnly: true),
                        inputField('dentalHistory', hint: 'Optional', multiline: true, numbersOnly: true),
                        if (isEditing) Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: savingProfile ? null : saveProfile,
                              style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: Text(savingProfile ? 'Saving...' : 'Save Profile', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (sidebarOpen) Positioned.fill(child: sidebar()),
          ],
        ),
      ),
    );
  }
}