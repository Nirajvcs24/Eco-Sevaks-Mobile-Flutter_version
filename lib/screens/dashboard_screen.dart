import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../widgets/event_card.dart';
import '../widgets/badge_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_spinner.dart';
import '../constants/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<AppEvent> _joinedEvents = [];
  List<AppEvent> _createdEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.getJoinedEvents(authProvider.user!.id),
        _apiService.getCreatedEvents(authProvider.user!.id),
      ]);
      setState(() {
        _joinedEvents = results[0];
        _createdEvents = results[1];
      });
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCancelRsvp(String eventId) async {
    try {
      await _apiService.leaveEvent(eventId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RSVP cancelled')));
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleDeleteEvent(String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteEvent(eventId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted')));
        _fetchData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final upcomingEvents = _joinedEvents.where((e) => e.date.isAfter(DateTime.now())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(LucideIcons.leaf, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        BadgeWidget(
                          label: user.role == 'admin' ? 'Admin' : 'Member',
                          variant: BadgeVariant.secondary,
                          size: BadgeSize.sm,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome, ${user.name}! 👋',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Text('Your eco-volunteering overview', style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(LucideIcons.heart, _joinedEvents.length.toString(), 'Joined', AppColors.primary),
                  _buildStatCard(LucideIcons.calendar, upcomingEvents.length.toString(), 'Upcoming', AppColors.accent),
                  _buildStatCard(LucideIcons.clock, (_joinedEvents.length - upcomingEvents.length).toString(), 'Completed', Colors.green),
                  _buildStatCard(LucideIcons.users, _createdEvents.length.toString(), 'Created', AppColors.secondary),
                ],
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Events',
                      onPressed: () => context.go('/events'),
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.sm,
                      leftIcon: const Icon(LucideIcons.calendar, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Create',
                      onPressed: () => context.go('/create-event'),
                      size: ButtonSize.sm,
                      leftIcon: const Icon(LucideIcons.plusCircle, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Joined Events
              const Text('Joined Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: LoadingSpinner())
              else if (_joinedEvents.isEmpty)
                EmptyState(
                  title: 'No joined events',
                  description: 'You haven\'t joined any events yet.',
                  actionText: 'Find Events',
                  onAction: () => context.go('/events'),
                  icon: LucideIcons.calendar,
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _joinedEvents.length,
                  itemBuilder: (context, index) => EventCard(
                    event: _joinedEvents[index],
                    onTap: () => context.push('/event/${_joinedEvents[index].id}'),
                    onCancel: () => _handleCancelRsvp(_joinedEvents[index].id),
                  ),
                ),
              const SizedBox(height: 32),

              // Created Events
              const Text('Created Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: LoadingSpinner())
              else if (_createdEvents.isEmpty)
                EmptyState(
                  title: 'No created events',
                  description: 'You haven\'t created any events yet.',
                  actionText: 'Create Event',
                  onAction: () => context.go('/create-event'),
                  icon: LucideIcons.plusCircle,
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _createdEvents.length,
                  itemBuilder: (context, index) => _buildCreatedEventItem(_createdEvents[index]),
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatedEventItem(AppEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              BadgeWidget.status(event.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(DateFormat('d MMM yyyy').format(event.date), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(width: 16),
              const Icon(LucideIcons.users, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(event.attendees.length.toString(), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'View',
                  onPressed: () => context.push('/event/${event.id}'),
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.sm,
                  leftIcon: const Icon(LucideIcons.eye, size: 14),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _handleDeleteEvent(event.id),
                icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
