import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fundit/utils/priority_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fundit/db/db_helper.dart';
import 'package:fundit/models/goal_model.dart';
import 'package:intl/intl.dart';

import 'package:fundit/db/db_helper.dart';
import 'package:fundit/models/goal_model.dart';

class AddGoalPage extends StatefulWidget {
  final Goal? goal; // nullable for new goal

  const AddGoalPage({super.key, this.goal});

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
  final String timestamp = DateFormat(
    'MMMM d, y (EEEE, hh:mma)',
  ).format(DateTime.now()).toLowerCase();
  final descriptionController = TextEditingController();
  String selectedPriority = 'Low';
  final List<String> priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();

    // Pre-fill fields if editing
    if (widget.goal != null) {
      nameController.text = widget.goal!.name;
      priceController.text = widget.goal!.price.toString();
      savedController.text = widget.goal!.saved.toString();
      if (widget.goal!.imagePath != null) {
        imageFile = File(widget.goal!.imagePath!);
      }
      descriptionController.text = widget.goal!.description ?? '';
      selectedPriority = widget.goal!.priority ?? 'Low';
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
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
    final isEditing = widget.goal != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Goal' : 'New Goal')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                color: Theme.of(context).colorScheme.surface,
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
                          labelText: 'Price',
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
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority Level',
                          border: OutlineInputBorder(),
                        ),
                        items: priorities.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: getPriorityColor(priority),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(priority),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPriority = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
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

                    final goalToSave = Goal(
                      id: widget.goal?.id, // important for editing
                      name: nameController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      saved: double.tryParse(savedController.text) ?? 0,
                      imagePath: imageFile?.path,
                      createdAt: DateTime.now(),
                      description: descriptionController.text.isNotEmpty
                          ? descriptionController.text
                          : null,
                      priority: selectedPriority,
                    );

                    if (isEditing) {
                      await DBHelper.instance.updateGoal(goalToSave);
                    } else {
                      await DBHelper.instance.insertGoal(goalToSave);
                    }

                    Navigator.pop(context, goalToSave); // return goal
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
