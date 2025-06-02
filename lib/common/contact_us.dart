// ignore_for_file: use_build_context_synchronously

import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/common/general_api/general_repository.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:CureBit/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _insuranceCompanyNameController = TextEditingController();
  final _otherEntityController = TextEditingController();
  bool _isSubmitting = false;

  String _countryCode = '+91'; // Default to india
  String _country = 'India';
  String _state = '';
  String _entityType = 'clinic'; // Default entity type

  // Map of common country codes (we'll select the appropriate one based on country selection)
  final Map<String, String> _commonCountryCodes = {
    'United States': '+1',
    'United Kingdom': '+44',
    'Canada': '+1',
    'Australia': '+61',
    'India': '+91',
    'China': '+86',
    'Germany': '+49',
    'France': '+33',
    // Add more common codes as needed
  };

  // List of entity types for radio buttons
  final List<Map<String, String>> _entityTypes = [
    {'value': 'clinic', 'label': 'Clinic'},
    {'value': 'hospital', 'label': 'Hospital'},
    {'value': 'solo_practioner', 'label': 'Solo Practitioner'},
    {'value': 'company', 'label': 'Company'},
    {'value': 'insurance_company', 'label': 'Insurance Company'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _companyNameController.dispose();
    _hospitalNameController.dispose();
    _clinicNameController.dispose();
    _insuranceCompanyNameController.dispose();
    _otherEntityController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        setState(() => _isSubmitting = true);

        // Prepare entity type map based on selected entity
        Map<String, dynamic> entityTypeMap = {};

        switch (_entityType) {
          case 'clinic':
            entityTypeMap = {
              'clinic': true,
              'clinic_name': _clinicNameController.text,
            };
            break;
          case 'hospital':
            entityTypeMap = {
              'hospital': true,
              'hospital_name': _hospitalNameController.text,
            };
            break;
          case 'solo_practioner':
            entityTypeMap = {
              'solo_practioner': _fullNameController.text,
            };
            break;
          case 'company':
            entityTypeMap = {
              'company': true,
              'company_name': _companyNameController.text,
            };
            break;
          case 'insurance_company':
            entityTypeMap = {
              'insurance_company': true,
              'insurance_company_name': _insuranceCompanyNameController.text,
            };
            break;
          case 'other':
            entityTypeMap = {
              'other': _otherEntityController.text,
            };
            break;
        }

        final contactRepository = GeneralApiRepository();
        await contactRepository.contactUs(
          _fullNameController.text,
          _emailController.text,
          _phoneNumberController.text,
          _countryCode,
          _country,
          _state,
          _messageController.text,
          entityTypeMap,
        );

        // Show success message
        showSnackBar(
          context: context,
          message: 'Message sent successfully!',
        );

        // Clear form fields
        _formKey.currentState!.reset();
        _fullNameController.clear();
        _phoneNumberController.clear();
        _emailController.clear();
        _messageController.clear();
        _companyNameController.clear();
        _hospitalNameController.clear();
        _clinicNameController.clear();
        _insuranceCompanyNameController.clear();
        _otherEntityController.clear();

        // Reset entity type
        setState(() {
          _entityType = 'clinic';
          _countryCode = '+1';
          _country = 'United States';
          _state = '';
        });
      } catch (e) {
        showSnackBar(
          context: context,
          message: 'Error sending message: ${e.toString()}',
        );
        debugPrint('$e');
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppHeader(
          title: 'Contact Us',
          backgroundColor: transparent,
          elevation: 2,
          onBackPressed: () {
            context.goNamed(RouteConstants.home);
          },
        ),
        body: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Logo with better spacing
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Image.asset(
                      'assets/images/logo_icon.png',
                      height: 60,
                    ),
                  ),
                  // Description text with better styling
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withValues(alpha: .1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Text(
                      '"Have questions about your medical history or CureBit services? We\'re here to help with prompt and accurate support."',
                      style: TextStyle(
                        fontSize: 16,
                        color: black.withValues(alpha: .8),
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Form with card styling
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: .15),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Personal Information'),
                          const SizedBox(height: 16),
                          _buildFullNameField(),
                          const SizedBox(height: 20),
                          _buildPhoneField(),
                          const SizedBox(height: 20),
                          _buildEmailField(),
                          const SizedBox(height: 20),
                          _buildLocationFields(),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Entity Information'),
                          const SizedBox(height: 16),
                          _buildEntityTypeSelection(),
                          const SizedBox(height: 20),
                          _buildEntityNameField(),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Message'),
                          const SizedBox(height: 16),
                          _buildMessageField(),
                          const SizedBox(height: 32),
                          Center(child: _buildSubmitButton()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: black.withValues(alpha: .8),
        ),
      ),
    );
  }

  Widget _buildFullNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Full Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: black.withValues(alpha: .8),
            ),
          ),
        ),
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: transparent, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          style: TextStyle(
            fontSize: 14,
            color: black,
          ),
          keyboardType: TextInputType.name,
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
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: black.withValues(alpha: .8),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country code field that will be updated based on country selection
            Container(
              width: 120,
              child: TextFormField(
                readOnly: true,
                initialValue: _countryCode,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: transparent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Phone number field
            Expanded(
              child: TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: transparent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // Remove any non-digit characters for validation
                  String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                  if (digitsOnly.length < 7) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: black.withValues(alpha: .8),
            ),
          ),
        ),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'your.email@example.com',
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: transparent, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: Icon(Icons.email_outlined,
                color: black.withValues(alpha: .8), size: 20),
          ),
          style: TextStyle(
            fontSize: 14,
            color: black,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Location',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: black.withValues(alpha: .8),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          padding: const EdgeInsets.all(16),
          child: SelectState(
            // using the country_state_city_picker package
            onCountryChanged: (country) {
              setState(() {
                _country = country;
                // Update country code if we have it in our map
                _countryCode = _commonCountryCodes[country] ??
                    '+1'; // Default to +1 if not found
              });
            },
            onStateChanged: (state) {
              setState(() {
                _state = state;
              });
            },
            onCityChanged: (city) {
              // We're not using city in this form
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEntityTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Entity Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: black.withValues(alpha: .8),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: _entityTypes
                .map((entity) => _buildCustomRadioTile(
                      entity['value']!,
                      entity['label']!,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomRadioTile(String value, String label) {
    bool isSelected = _entityType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _entityType = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 20,
              height: 20,
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? transparent : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? black.withValues(alpha: .8)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: black.withValues(alpha: .8),
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityNameField() {
    // Show different fields based on selected entity type
    switch (_entityType) {
      case 'clinic':
        return _buildEntityTextField(
          'Clinic Name',
          'Enter clinic name',
          _clinicNameController,
        );
      case 'hospital':
        return _buildEntityTextField(
          'Hospital Name',
          'Enter hospital name',
          _hospitalNameController,
        );
      case 'company':
        return _buildEntityTextField(
          'Company Name',
          'Enter company name',
          _companyNameController,
        );
      case 'insurance_company':
        return _buildEntityTextField(
          'Insurance Company Name',
          'Enter insurance company name',
          _insuranceCompanyNameController,
        );
      case 'other':
        return _buildEntityTextField(
          'Please Specify',
          'Enter entity details',
          _otherEntityController,
        );
      default:
        return SizedBox.shrink(); // For solo practitioner, use the full name
    }
  }

  Widget _buildEntityTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: black.withValues(alpha: .8),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: transparent, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          style: TextStyle(
            fontSize: 14,
            color: black,
          ),
          validator: (value) {
            if (_entityType == 'clinic' ||
                _entityType == 'hospital' ||
                _entityType == 'company' ||
                _entityType == 'insurance_company') {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Your Message',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: black.withValues(alpha: .8),
            ),
          ),
        ),
        TextFormField(
          controller: _messageController,
          decoration: InputDecoration(
            hintText: 'Please describe your inquiry in detail...',
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: transparent, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          style: TextStyle(
            fontSize: 14,
            color: black,
          ),
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your message';
            }
            if (value.length < 10) {
              return 'Message must be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: grey600,
      ),
      child: _isSubmitting
          ? CircularProgressIndicator(color: Colors.white)
          : Text(
              'Submit',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}
