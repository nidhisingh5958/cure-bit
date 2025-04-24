import 'package:CuraDocs/components/app_header.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Favourites',
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // Placeholder image
            ),
            title: const Text('Doctor Name'),
            subtitle: const Text('Specialization'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Handle delete action
              },
            ),
          );
        },
      ),
    );
  }
}
