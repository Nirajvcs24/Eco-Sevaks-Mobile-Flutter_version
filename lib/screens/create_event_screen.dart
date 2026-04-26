import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../widgets/badge_widget.dart';
import '../constants/app_colors.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final ApiService _apiService = ApiService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _maxVolunteersController = TextEditingController(text: '0');
  final _whatToBringController = TextEditingController();
  final _tagController = TextEditingController();

  DateTime? _selectedDate;
  String _type = 'virtual';
  List<String> _tags = [];
  bool _isSubmitting = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && _tags.length < 5) {
      setState(() {
        _tags.add(tag.toLowerCase());
        _tagController.clear();
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in required fields')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final eventData = {
        'title': _titleController.text,
        'description': _descController.text,
        'date': _selectedDate!.toIso8601String(),
        'type': _type,
        'location': _locationController.text,
        'imageUrl': _imageUrlController.text,
        'maxVolunteers': int.tryParse(_maxVolunteersController.text) ?? 0,
        'whatToBring': _whatToBringController.text,
        'tags': _tags,
      };
      await _apiService.createEvent(eventData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event submitted for approval!')));
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Event', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInput(
                    label: 'Event Title',
                    controller: _titleController,
                    required: true,
                    leftIcon: const Icon(LucideIcons.fileText, size: 20, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  CustomInput(
                    label: 'Description',
                    controller: _descController,
                    required: true,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  CustomInput(
                    label: 'Image URL (Optional)',
                    controller: _imageUrlController,
                    leftIcon: const Icon(LucideIcons.image, size: 20, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 20, color: AppColors.textMuted),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate == null ? 'Select Date & Time' : DateFormat('dd MMM yyyy, hh:mm a').format(_selectedDate!),
                            style: TextStyle(color: _selectedDate == null ? AppColors.textMuted : AppColors.dark, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: InputDecoration(
                      labelText: 'Event Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'virtual', child: Text('🌐 Virtual Event')),
                      DropdownMenuItem(value: 'in-person', child: Text('📍 In-person Event')),
                    ],
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                  const SizedBox(height: 20),
                  if (_type == 'in-person') ...[
                    CustomInput(
                      label: 'Location',
                      controller: _locationController,
                      leftIcon: const Icon(LucideIcons.mapPin, size: 20, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 20),
                  ],
                  CustomInput(
                    label: 'Max Volunteers (0 = unlimited)',
                    controller: _maxVolunteersController,
                    keyboardType: TextInputType.number,
                    leftIcon: const Icon(LucideIcons.users, size: 20, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  CustomInput(
                    label: 'What to Bring (Optional)',
                    controller: _whatToBringController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  const Text('Tags (up to 5)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomInput(
                          label: 'Add tag...',
                          controller: _tagController,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addTag,
                        icon: const Icon(LucideIcons.plus, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _tags
                        .map((tag) => BadgeWidget(
                              label: tag,
                              variant: BadgeVariant.primary,
                              size: BadgeSize.sm,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Submit for Approval',
                    onPressed: _handleSubmit,
                    isLoading: _isSubmitting,
                    fullWidth: true,
                    leftIcon: const Icon(LucideIcons.send, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
