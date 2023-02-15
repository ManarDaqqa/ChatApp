import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {

  final void Function(File pickedImage) imagePickFn;

  const UserImagePicker(this.imagePickFn);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  void _pickImage(ImageSource src)async{
    final XFile? pickedImageFile = await _picker.pickImage(source: src, imageQuality: 50);

    if(pickedImageFile != null){
      setState((){
        _pickedImage = File(pickedImageFile.path);
      });
      widget.imagePickFn(_pickedImage!);
    }else{
      print('No Image Selected');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade400,
          backgroundImage: _pickedImage == null  ? const AssetImage('assets/images/add-128.png') : FileImage(_pickedImage!) as ImageProvider,
        )  ,
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
                onPressed: ()=> _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Add Image\nfrom Camera',textAlign: TextAlign.center,)),
            TextButton.icon(
                onPressed: ()=> _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image_outlined),
                label: const Text('Add Image\nfrom Gallery',textAlign: TextAlign.center,))
          ],
        )
      ],
    );
  }
}
