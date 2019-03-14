import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
	@override
	ProfileState createState() => new ProfileState();
}

class ProfileState extends State<Profile> {
	
  Widget _buildProfile(profileData) {
    return Text(profileData);
  }

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Perfil'),
			),
			body: _buildProfile('Test'),
		);
	}

}
