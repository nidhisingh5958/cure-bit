import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
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
  String selectedAssistanceType = '';
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contact Us'),
          backgroundColor: color5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              context.goNamed(RouteConstants.home);
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Logo with better spacing
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  child: Image.asset(
                    'assets/images/logo_icon.png',
                    height: 80,
                  ),
                ),
                // Description text with better padding
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    '\"Have questions about your medical history or CuraDocs services? We\'re here to help with prompt and accurate support.\"',
                    style: TextStyle(
                      fontSize: 16,
                      color: color2,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                // Form with consistent padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameField(),
                        const SizedBox(height: 16),
                        _buildEmailField(),
                        const SizedBox(height: 24),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: _firstnameController,
            decoration: InputDecoration(
              hintText: 'First Name',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: TextStyle(
              fontSize: 14,
              color: color1,
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
            ),
            style: TextStyle(
              fontSize: 14,
              color: color1,
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
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: TextStyle(
        fontSize: 14,
        color: color1,
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
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      decoration: InputDecoration(
        hintText: 'Message',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      maxLines: 5,
      style: TextStyle(
        fontSize: 14,
        color: color1,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your message';
        }
        return null;
      },
      onSaved: (value) => message = value!,
    );
  }

  Widget _buildTopicBar() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'Select a topic',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        color: color1,
      ),
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
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Can we assist you?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: assistanceOptions
                .map((option) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: option,
                            groupValue: assistanceType,
                            onChanged: (value) {
                              setState(() {
                                assistanceType = value!;
                              });
                            },
                          ),
                          Flexible(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                color: color2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          print('Submitting form:');
          print('Name: $firstname $lastname');
          print('Email: $email');
          print('Topic: $topic');
          print('Assistance type: $assistanceType');
          print('Message: $message');

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message sent!')),
          );

          // Clear form fields
          _firstnameController.clear();
          _lastnameController.clear();
          _emailController.clear();
          _messageController.clear();

          // Reset the assistance type if needed
          setState(() {
            assistanceType = '';
          });
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Send Message'),
    );
  }
}
