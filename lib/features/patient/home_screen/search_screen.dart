import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This is the search screen for the patient where he/she can search doctors
class DoctorSearchScreen extends StatefulWidget {
  final Map<String, dynamic> map;

  const DoctorSearchScreen({super.key, required this.map});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final FocusNode _focusNode = FocusNode();
  bool isExpanded = false;
  String query = '';

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen for changes to update the isExpanded state
    _textController.addListener(() {
      setState(() {
        isExpanded = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    // Clean up resources
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
    });
  }

  // delete items function to clear the text
  void _deleteItems() {
    setState(() {
      _textController.clear();
      query = '';
      isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            context.goNamed(RouteConstants.home);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Add filter functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            // Uncomment this when you have the data ready
            // _buildDoctorList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        focusNode: _focusNode,
        controller: _textController, // Use the controller
        onChanged: onQueryChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: Icon(
            Icons.search,
            color: black,
            size: 20,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isExpanded)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: black,
                    size: 20,
                  ),
                  onPressed: _deleteItems,
                )
              else
                Icon(
                  Icons.mic,
                  color: black,
                  size: 20,
                ),
            ],
          ),
          hintText: "Search for doctors",
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        style: TextStyle(fontSize: 14),
        minLines: 1,
        maxLines: 1,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            context.pushNamed(
              RouteConstants.chatBotScreen,
              extra: value,
            );
          }
        },
      ),
    );
  }

  // temporary function real will be fetched from api
  String getCategory(String? specialization) {
    return specialization ?? 'General Physician';
  }

  Widget _buildDoctorList() {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.map['doctors']?.length ?? 0,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenHeight(23),
                vertical: getProportionateScreenHeight(9),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 64,
                        minHeight: 64,
                        maxWidth: 64,
                        maxHeight: 64,
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                        radius: 30,
                      ),
                    ),
                    title: Text(
                      widget.map['doctors'][index]['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color2,
                      ),
                    ),
                    subtitle: Column(children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          getCategory(
                              widget.map['doctors'][index]['specialization']),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: color2,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// filter logic
// body: FutureBuilder(
//   future: futureProduct,
//   builder: (context, snapshot) {
//     if (snapshot.hasData) {
//       print(snapshot.hasData);
//       final datas = snapshot.data; // data preprocessing
//       Map<String, dynamic> map = datas.getData();
//       int length = 10; // In this example, I only show 10 data at most
//       if (searchString == '') {
//         if (map['products'].length < 10) {
//           length = map['products'].length;
//         }
//       } else { // do search
//         final filteredMap = <String, dynamic>{};
//         final List<dynamic> filteredList = [];
//         filteredMap['products'] = filteredList;
//         for (int i = 0; i < map['products'].length; i++) {
//           if (map['products'][i]['name']
//               .toLowerCase()
//               .contains(searchString.toLowerCase())) //search name {
//             filteredMap['products'].add(map['products'][i]);
//           } else {
//             for (int j = 0;
//             j < map['products'][i]['category'].length;
//             j++) {
//               if (map['products'][i]['category'][j]
//                   .toLowerCase()
//                   .contains(searchString.toLowerCase())) //search category {
//                 filteredMap['products'].add(map['products'][i]);
//               }
//             }
//           }
//         }
