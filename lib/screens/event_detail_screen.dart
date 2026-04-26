import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/badge_widget.dart';
import '../widgets/custom_button.dart';
import '../constants/app_colors.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ApiService _apiService = ApiService();
  AppEvent? _event;
  bool _isLoading = true;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _fetchEvent();
  }

  Future<void> _fetchEvent() async {
    setState(() => _isLoading = true);
    try {
      final event = await _apiService.getEventById(widget.eventId);
      setState(() => _event = event);
    } catch (e) {
      debugPrint('Error fetching event: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleJoinEvent() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      context.go('/login');
      return;
    }

    setState(() => _isJoining = true);
    try {
      await _apiService.joinEvent(_event!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined "${_event!.title}"!')),
      );
      _fetchEvent(); // Refresh to show joined state
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Event not found')),
      );
    }

    final authProvider = context.watch<AuthProvider>();
    final isJoined = authProvider.user?.joinedEvents.contains(_event!.id) ?? false;
    final isPast = _event!.date.isBefore(DateTime.now());
    final String formattedDate = DateFormat('EEE, d MMMM yyyy').format(_event!.date);
    final String formattedTime = DateFormat('hh:mm a').format(_event!.date);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: _event!.imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BadgeWidget(
                        label: _event!.isVirtual ? '🌐 Virtual' : '📍 In-person',
                        variant: _event!.isVirtual ? BadgeVariant.accent : BadgeVariant.primary,
                        glow: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _event!.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      _buildInfoItem(LucideIcons.calendar, 'Date', formattedDate, AppColors.primary),
                      _buildInfoItem(LucideIcons.clock, 'Time', formattedTime, AppColors.accent),
                      _buildInfoItem(_event!.isVirtual ? LucideIcons.globe : LucideIcons.mapPin, 'Location',
                          _event!.isVirtual ? 'Online' : _event!.location, AppColors.secondary),
                      _buildInfoItem(LucideIcons.users, 'Volunteers', '${_event!.attendees.length} joined', AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About
                  const Text('About This Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
                  const SizedBox(height: 8),
                  Text(
                    _event!.description,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  if (_event!.whatToBring != null) ...[
                    const Text('What to Bring', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
                    const SizedBox(height: 12),
                    ..._event!.whatToBring!.split('. ').where((s) => s.isNotEmpty).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(LucideIcons.checkCircle, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _event!.tags
                        .map((tag) => BadgeWidget(
                              label: tag,
                              variant: BadgeVariant.primary,
                              size: BadgeSize.sm,
                              icon: const Icon(LucideIcons.tag, size: 10, color: Color(0xFF065F46)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isPast ? 'Event ended' : 'Join this event', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(_event!.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 140,
              child: CustomButton(
                text: isJoined ? 'Joined' : (isPast ? 'Completed' : 'Join'),
                onPressed: isJoined || isPast ? null : _handleJoinEvent,
                isLoading: _isJoining,
                variant: isJoined ? ButtonVariant.success : (isPast ? ButtonVariant.secondary : ButtonVariant.primary),
                leftIcon: isJoined ? const Icon(LucideIcons.checkCircle, size: 18) : (isPast ? null : const Icon(LucideIcons.heart, size: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.dark), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
