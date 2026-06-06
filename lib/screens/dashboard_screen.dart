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
import '../widgets/loading_spinner.dart';
import '../widgets/empty_state.dart';
import '../constants/app_colors.dart';
import '../widgets/count_up_text.dart';
import '../widgets/liquid_glass_container.dart';
import '../widgets/fade_in_up.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<AppEvent> _joinedEvents = [];
  List<AppEvent> _createdEvents = [];
  List<AppEvent> _recommendedEvents = [];
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
        _apiService.getAllEvents(),
      ]);
      setState(() {
        _joinedEvents = results[0];
        _createdEvents = results[1];
        final allEvents = results[2];
        
        // Recommendations based on area
        final userArea = authProvider.user!.area.toLowerCase();
        _recommendedEvents = allEvents.where((e) {
          final matchesArea = e.location.toLowerCase().contains(userArea);
          final notJoined = !_joinedEvents.any((je) => je.id == e.id);
          final notCreated = !_createdEvents.any((ce) => ce.id == e.id);
          return matchesArea && notJoined && notCreated;
        }).toList();
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
      await context.read<AuthProvider>().refreshUser();
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleDeleteEvent(String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteEvent(eventId);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Event deleted')));
        _fetchData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final upcomingEvents = _joinedEvents
        .where((e) => e.date.isAfter(DateTime.now()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                child: LiquidGlassContainer(
                  blur: 20,
                  opacity: 0.7,
                  gradientColors: [AppColors.paleGreen, AppColors.paleGreen],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                LucideIcons.leaf,
                                color: AppColors.primary,
                                size: 16,
                              ),
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
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your eco-volunteering overview',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
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
                  _buildStatCard(
                    context,
                    LucideIcons.heart,
                    _joinedEvents.length.toString(),
                    'Joined',
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    context,
                    LucideIcons.calendar,
                    upcomingEvents.length.toString(),
                    'Upcoming',
                    AppColors.accent,
                  ),
                  _buildStatCard(
                    context,
                    LucideIcons.clock,
                    (_joinedEvents.length - upcomingEvents.length).toString(),
                    'Completed',
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    LucideIcons.users,
                    _createdEvents.length.toString(),
                    'Created',
                    AppColors.secondary,
                  ),
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

              // Recommendations
              if (user.area.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recommended in ${user.area}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const BadgeWidget(
                      label: 'New',
                      variant: BadgeVariant.accent,
                      size: BadgeSize.sm,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(child: LoadingSpinner())
                else if (_recommendedEvents.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.mapPin, color: AppColors.primary, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No events found in your area yet. Check back soon!',
                            style: TextStyle(color: AppColors.primary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendedEvents.length,
                      itemBuilder: (context, index) {
                        final event = _recommendedEvents[index];
                        return Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 16, bottom: 8),
                          child: EventCard(
                            event: event,
                            onTap: () => context.push('/event/${event.id}'),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 32),
              ],

              // Joined Events
              Text(
                'Joined Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
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
                    onTap: () =>
                        context.push('/event/${_joinedEvents[index].id}'),
                    onCancel: () => _handleCancelRsvp(_joinedEvents[index].id),
                  ),
                ),
              const SizedBox(height: 32),

              // Created Events
              Text(
                'Created Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
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
                  itemBuilder: (context, index) =>
                      _buildCreatedEventItem(context, _createdEvents[index]),
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CountUpText(
                  value: value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatedEventItem(BuildContext context, AppEvent event) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey[100]!),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
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
              Icon(
                LucideIcons.calendar,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('d MMM yyyy').format(event.date),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                LucideIcons.users,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 4),
              Text(
                event.attendees.length.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
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
                icon: const Icon(
                  LucideIcons.trash2,
                  color: Colors.red,
                  size: 18,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

