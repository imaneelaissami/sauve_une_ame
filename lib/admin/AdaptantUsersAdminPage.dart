import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'SendNotificationPage.dart';

class AdaptantUsersAdminPage extends StatefulWidget {
  @override
  _AdaptantUsersAdminPageState createState() => _AdaptantUsersAdminPageState();
}

class _AdaptantUsersAdminPageState extends State<AdaptantUsersAdminPage> {
  List<dynamic> adoptantUser = [];

  // الألوان
  final Color lightPink = const Color(0xFFE4CFC8);
  final Color mediumBrown = const Color(0xFFB57D7F);
  final Color darkBrown = const Color(0xFF5A1F35);

  @override
  void initState() {
    super.initState();
    fetchAdoptantUser();
  }

  Future<void> fetchAdoptantUser() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/users'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> filteredUsers =
      data.where((user) => user['userType'] == 'adoptantUser').toList();

      setState(() {
        adoptantUser = filteredUsers;
      });
    } else {
      print('Erreur lors de la récupération des utilisateurs');
    }
  }

  Future<void> deleteUser(String email) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/api/users?email=$email'),
    );

    if (response.statusCode == 200) {
      setState(() {
        adoptantUser.removeWhere((user) => user['email'] == email);
      });
    } else {
      print('Erreur lors de la suppression');
    }
  }

  Future<void> confirmDelete(String email) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteUser(email);
    }
  }

  void _launchCaller(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir le téléphone')),
      );
    }
  }

  Widget buildUserCard(user) {
    String imageUrl = user['profileImage'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'http://10.0.2.2:3000' + imageUrl;
    }

    return Card(
      color: lightPink,
      margin: EdgeInsets.all(10),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 30,
              ),
              title: Text(
                user['fullName'],
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text("Email: ${user['email']}", style: TextStyle(color: Colors.black)),
                  Text("Sexe: ${user['sex']}", style: TextStyle(color: Colors.black)),
                  Text("Âge: ${user['age']}", style: TextStyle(color: Colors.black)),
                  Text("Ville: ${user['city']}", style: TextStyle(color: Colors.black)),
                  Text("Pays: ${user['country']}", style: TextStyle(color: Colors.black)),
                  Row(
                    children: [
                      Text(
                        'Télé: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _launchCaller(user['phone']),
                        child: Text(
                          user['phone'],
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Wrap(
                spacing: 8,
                children: [

                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => confirmDelete(user['email']),
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SendNotificationPage(email: user['email']),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // هنا نضيف SearchDelegate
  void _startSearch() {
    showSearch(
      context: context,
      delegate: UserSearchDelegate(adoptantUser, _launchCaller, confirmDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mediumBrown,
      appBar: AppBar(
        title: Text('Utilisateurs Adaptantes', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: darkBrown,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: _startSearch,
          ),
        ],
      ),
      body: adoptantUser.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: adoptantUser.length,
        itemBuilder: (context, index) {
          return buildUserCard(adoptantUser[index]);
        },
      ),
    );
  }
}

// تعريف SearchDelegate
class UserSearchDelegate extends SearchDelegate {
  final List<dynamic> users;
  final Function(String) launchCaller;
  final Future<void> Function(String) confirmDelete;

  UserSearchDelegate(this.users, this.launchCaller, this.confirmDelete);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  List<dynamic> _filterUsers(String query) {
    return users.where((user) {
      final fullName = user['fullName']?.toString().toLowerCase() ?? '';
      return fullName.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filterUsers(query);
    if (results.isEmpty) {
      return Center(child: Text('Aucun utilisateur trouvé.'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        String imageUrl = user['profileImage'] ?? '';
        if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
          imageUrl = 'http://10.0.2.2:3000' + imageUrl;
        }

        return Card(
          color: const Color(0xFFE4CFC8),
          margin: EdgeInsets.all(10),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: 30,
                  ),
                  title: Text(
                    user['fullName'],
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text("Email: ${user['email']}", style: TextStyle(color: Colors.black)),
                      Text("Sexe: ${user['sex']}", style: TextStyle(color: Colors.black)),
                      Text("Âge: ${user['age']}", style: TextStyle(color: Colors.black)),
                      Text("Ville: ${user['city']}", style: TextStyle(color: Colors.black)),
                      Text("Pays: ${user['country']}", style: TextStyle(color: Colors.black)),
                      Row(
                        children: [
                          Text(
                            'Télé: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => launchCaller(user['phone']),
                            child: Text(
                              user['phone'],
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Confirmation'),
                              content: Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
                              actions: [
                                TextButton(
                                  child: Text('Annuler'),
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await confirmDelete(user['email']);
                            // Close search and refresh the list if needed
                            close(context, null);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications, color: Colors.blueGrey),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(

                              builder: (context) => SendNotificationPage(email: user['email']),                       ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = _filterUsers(query);

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final user = suggestions[index];
        return ListTile(
          title: Text(user['fullName']),
          onTap: () {
            query = user['fullName'];
            showResults(context);
          },
        );
      },
    );
  }
}
