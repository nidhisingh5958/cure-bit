import 'package:flutter/material.dart';

class SignupProfilePage extends StatefulWidget {
  const SignupProfilePage({super.key});

  @override
  State<SignupProfilePage> createState() => _SignupProfilePageState();
}

class _SignupProfilePageState extends State<SignupProfilePage> {
  String name = '';
  String phoneNumber = '';
  String? _selectedGender;

  final border = const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
      width: 1.0,
      style: BorderStyle.solid,
      strokeAlign: BorderSide.strokeAlignCenter,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(244, 246, 245, 1),
        title: const Text('Set Up Profile'),
      ),
      backgroundColor: const Color.fromRGBO(244, 246, 245, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2.0, // Border color
                ),
                borderRadius: BorderRadius.circular(500),
              ),
              child: const Icon(
                Icons.person,
                size: 150,
              ),
            ),
            const SizedBox(height: 100),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 350,
                  height: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    // margin: EdgeInsets.symmetric(vertical: 20), // Margin around the line
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Jhon Doe',
                      fillColor: const Color.fromRGBO(244, 246, 245, 1),
                      filled: true,
                      enabledBorder: border,
                      focusedBorder: border,
                      prefixIcon: const Icon(
                        Icons.person,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value!;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: '+91 100xxxxxx9',
                      fillColor: const Color.fromRGBO(244, 246, 245, 1),
                      filled: true,
                      enabledBorder: border,
                      focusedBorder: border,
                      prefixIcon: const Icon(
                        Icons.phone,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      phoneNumber = value!;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Date of Birth',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: 100,
                    child: DropdownButtonFormField(
                      dropdownColor: const Color.fromRGBO(244, 246, 245, 1),
                      decoration: InputDecoration(
                        labelText: "Date",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: List.generate(31, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text("${index + 1}"),
                        );
                      }),
                      onChanged: (value) {},
                      menuMaxHeight: 300,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: 100,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Month",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec'
                      ].map((month) {
                        return DropdownMenuItem(
                          child: Text(month),
                          value: month,
                        );
                      }).toList(),
                      onChanged: (value) {},
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: 100,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Year",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: List.generate(100, (index) {
                        return DropdownMenuItem(
                          child: Text("${2024 - index}"),
                          value: 2024 - index,
                        );
                      }),
                      onChanged: (value) {},
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Radio<String>(
                  value: 'Male', // The value for male
                  groupValue:
                      _selectedGender, // The value that the radio button belongs to
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                Text('Male'),
                Radio<String>(
                  value: 'Female', // The value for female
                  groupValue:
                      _selectedGender, // The value that the radio button belongs to
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                Text('Female'),
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                debugPrint("ok");
              },
              style:
                  // ButtonStyle(
                  //   minimumSize: const Size(200, 60),  // Width and Height
                  //   padding: const EdgeInsets.symmetric(horizontal: 30), // Horizontal padding
                  //   textStyle: const TextStyle(fontSize: 20), // Font size
                  // ),
                  ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60), // Width and Height
                padding: const EdgeInsets.symmetric(
                    horizontal: 30), // Horizontal padding
                textStyle: const TextStyle(fontSize: 20), // Font size
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[8], // Background color of the screen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Skip",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Set Up Profile",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  labelText: "Contact Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Date of Birth",
                style: TextStyle(fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Date",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: List.generate(31, (index) {
                        return DropdownMenuItem(
                          child: Text("${index + 1}"),
                          value: index + 1,
                        );
                      }),
                      onChanged: (value) {},
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Month",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec'
                      ].map((month) {
                        return DropdownMenuItem(
                          child: Text(month),
                          value: month,
                        );
                      }).toList(),
                      onChanged: (value) {},
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Year",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: List.generate(100, (index) {
                        return DropdownMenuItem(
                          child: Text("${2024 - index}"),
                          value: 2024 - index,
                        );
                      }),
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Gender",
                style: TextStyle(fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text("Male"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                      child: Text(
                        "Female",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
