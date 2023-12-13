import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    super.key,
    required this.onSelectImage,
  });

  final void Function(File) onSelectImage;

  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImage = File(pickedImage.path);
    });

    widget.onSelectImage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          foregroundImage: _pickedImage != null
              ? FileImage(_pickedImage!)
              : const AssetImage('assets/images/profilo_default.jpg')
                  as ImageProvider<Object>,
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: Icon(
            Icons.camera,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: Text(
            "Change Image",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
