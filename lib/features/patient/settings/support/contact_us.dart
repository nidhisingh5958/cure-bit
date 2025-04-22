import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/patient/api_repository/repository.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  String firstname = '';
  String lastname = '';
  String email = '';
  String message = '';
  String topic = '';
  String assistanceType = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        setState(() => _isSubmitting = true);

        final ContactRepository = SettingsRepository();
        await ContactRepository.getContactUs(
          _firstnameController.text,
          _lastnameController.text,
          _emailController.text,
          topic,
          assistanceType,
          _messageController.text,
        );

        // Clear form fields
        _firstnameController.clear();
        _lastnameController.clear();
        _emailController.clear();
        _messageController.clear();

        // Reset assistance type
        setState(() {
          assistanceType = '';
        });
      } catch (e) {
        showSnackBar(
          context: context,
          message: 'Error sending message: ${e.toString()}',
        );
        print(e);
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Contact Us',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: transparent,
          elevation: 2,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              context.goNamed(RouteConstants.home);
            },
          ),
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
                      height: 90,
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
                      '"Have questions about your medical history or CuraDocs services? We\'re here to help with prompt and accurate support."',
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
                          _buildNameField(),
                          const SizedBox(height: 20),
                          _buildEmailField(),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Inquiry Details'),
                          const SizedBox(height: 16),
                          _buildTopicBar(),
                          const SizedBox(height: 24),
                          _buildChoice(),
                          const SizedBox(height: 24),
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

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: black.withValues(alpha: .8),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstnameController,
                decoration: InputDecoration(
                  hintText: 'First Name',
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
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
                onSaved: (value) => firstname = value!,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastnameController,
                decoration: InputDecoration(
                  hintText: 'Last Name',
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
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
                onSaved: (value) => lastname = value!,
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
          onSaved: (value) => email = value!,
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
          maxLines: 5,
          style: TextStyle(
            fontSize: 14,
            color: black,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your message';
            }
            return null;
          },
          onSaved: (value) => message = value!,
        ),
      ],
    );
  }

  Widget _buildTopicBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Topic',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: black.withValues(alpha: .8),
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: 'Select a topic',
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
          icon: Icon(Icons.arrow_drop_down, color: black.withValues(alpha: .8)),
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: 'General Inquiry',
              child: Text('General Inquiry'),
            ),
            DropdownMenuItem(
              value: 'Technical Support',
              child: Text('Technical Support'),
            ),
            DropdownMenuItem(
              value: 'Billing',
              child: Text('Billing'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              topic = value!;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a topic';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildChoice() {
    final List<String> assistanceOptions = [
      'Help with accessing my medical records',
      'Report incorrect medical data',
      'Request technical support',
      'Feedback about CuraDocs',
      'Issues with chatbot responses',
      'Other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'How can we assist you?',
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
            children: assistanceOptions
                .map((option) => _buildCustomRadioTile(option))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomRadioTile(String option) {
    bool isSelected = assistanceType == option;

    return InkWell(
      onTap: () {
        setState(() {
          assistanceType = option;
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
                option,
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        minimumSize: Size(200, 48),
      ),
      child: _isSubmitting
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.5,
              ),
            )
          : Text(
              'Send Message',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }
}
