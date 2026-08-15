import 'package:flutter/material.dart';
import '../widgets/edit_form_widget.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: EditProfileFormWidget(),
      ),
    );
  }
}