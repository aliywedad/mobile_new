import 'package:flutter/material.dart';
import 'package:mobile/pages/enregistrements.dart';
import 'package:shared_preferences/shared_preferences.dart';

 
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, String>> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = _loadProfileData();
  }

  Future<Map<String, String>> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? 'default@example.com';
    final nom = prefs.getString('nom') ?? 'DefaultNom';
    final prenom = prefs.getString('prenom') ?? 'DefaultPrenom';
    final tel = prefs.getString('tel') ?? '0000000000';
    final id = prefs.getInt('id') ?? 0;
    // print("id is ${id} ============================================================================================ ");
    return {
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'tel': tel,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Color(0xFF364057),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Map<String, String>>(
              future: _profileData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading profile data'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No profile data found'));
                } else {
                  final data = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('images/male_profile.png'), // Corrected the path
                        ),
                      ),
                      SizedBox(height: 60),
                      ProfileField(
                        label: 'Email',
                        value: data['email']!,
                      ),
                      ProfileField(
                        label: 'Nom',
                        value: '${data['nom']} ${data['prenom']}',
                      ),
                      ProfileField(
                        
                        label: 'Téléphone' ,
                        value: data['tel']!,
                      ),
                      GestureDetector(


                        
                        onTap: () {
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Enregistrements()),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20), // Space at the bottom of the card
                          padding: const EdgeInsets.all(20), // Inner space
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50],
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Soft shadow
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3), // Shadow offset
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // To keep elements separated
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_city, color: Color.fromARGB(255, 189, 189, 189)), // Icon on the left
                                  SizedBox(width: 10), // Space between icon and text
                                  Text(
                                    "les enregistrements",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.grey), // Arrow on the right
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
