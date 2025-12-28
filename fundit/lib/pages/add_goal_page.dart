import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fundit/pages/db_helper.dart';
import 'package:fundit/pages/goal_model.dart';
import 'package:intl/intl.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final savedController = TextEditingController();
  File? imageFile;
  final NumberFormat pesoFormatter = NumberFormat('#,##0.00', 'en_PH');

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Goal')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Goal Name',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Product Price',
                          prefixText: '₱ ',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: savedController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Initial Savings',
                          prefixText: '₱ ',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        savedController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                        ),
                      );
                      return;
                    }

                    final goal = Goal(
                      name: nameController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      saved: double.tryParse(savedController.text) ?? 0,
                      imagePath: imageFile?.path,
                    );

                    await DBHelper.instance.insertGoal(goal);
                    Navigator.pop(context);
                  },
                  child: const Text('Save Goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
