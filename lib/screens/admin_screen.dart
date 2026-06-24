import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_spinner.dart';
import '../constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService _apiService = ApiService();
  List<AppEvent> _pendingEvents = [];
  List<AppEvent> _approvedEvents = [];
  List<AppEvent> _restrictedEvents = [];
  String _activeTab = 'pending';
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.getPendingEvents(),
        _apiService.getAllEvents(),
        _apiService.getRestrictedEvents(),
      ]);
      setState(() {
        _pendingEvents = results[0];
        _approvedEvents = results[1];
        _restrictedEvents = results[2];
      });
    } catch (e) {
      debugPrint('Error fetching admin data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleApproval(String eventId, bool isApproved) async {
    setState(() => _isProcessing = true);
    try {
      await _apiService.handleApproval(eventId, isApproved);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event ${isApproved ? 'approved' : 'rejected'}!')));
      _fetchEvents();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRestrict(AppEvent event) async {
    final reasonController = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Restrict Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(hintText: 'Enter reason for restriction'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: CustomButton(text: 'Cancel', onPressed: () => Navigator.pop(context, false), variant: ButtonVariant.secondary)),
                const SizedBox(width: 12),
                Expanded(child: CustomButton(text: 'Restrict', onPressed: () => Navigator.pop(context, true), variant: ButtonVariant.warning)),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      setState(() => _isProcessing = true);
      try {
        await _apiService.restrictEvent(event.id, true, reasonController.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event restricted!')));
        _fetchEvents();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEvents = _activeTab == 'pending' ? _pendingEvents : (_activeTab == 'approved' ? _approvedEvents : _restrictedEvents);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: const Icon(LucideIcons.shield, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Admin Panel'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats
            Row(
              children: [
                _buildStatItem(context, LucideIcons.clock, _pendingEvents.length.toString(), 'Pending', Colors.orange),
                const SizedBox(width: 12),
                _buildStatItem(context, LucideIcons.checkCircle, _approvedEvents.length.toString(), 'Approved', Colors.green),
              ],
            ),
            const SizedBox(height: 20),

            // Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab(context, 'pending', 'Pending (${_pendingEvents.length})'),
                  _buildTab(context, 'approved', 'Approved (${_approvedEvents.length})'),
                  _buildTab(context, 'restricted', 'Restricted (${_restrictedEvents.length})'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingSpinner())
                  : currentEvents.isEmpty
                      ? EmptyState(
                          title: 'All clear!',
                          description: 'No $_activeTab events right now.',
                          icon: LucideIcons.inbox,
                        )
                      : ListView.builder(
                          itemCount: currentEvents.length,
                          itemBuilder: (context, index) => _buildEventRow(context, currentEvents[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey[100]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String key, String label) {
    final isActive = _activeTab == key;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? (isDark ? const Color(0xFF334155) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventRow(BuildContext context, AppEvent event) {
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
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: AppColors.primary, child: Center(child: Text(event.title[0], style: const TextStyle(color: Colors.white)))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'by Organizer ID: ${event.organizerId}',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_activeTab == 'pending') ...[
                Expanded(
                  child: CustomButton(
                    text: 'Approve',
                    onPressed: () => _handleApproval(event.id, true),
                    variant: ButtonVariant.success,
                    size: ButtonSize.sm,
                    isDisabled: _isProcessing,
                    leftIcon: const Icon(LucideIcons.checkCircle, size: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'Reject',
                    onPressed: () => _handleApproval(event.id, false),
                    variant: ButtonVariant.danger,
                    size: ButtonSize.sm,
                    isDisabled: _isProcessing,
                    leftIcon: const Icon(LucideIcons.xCircle, size: 14),
                  ),
                ),
              ] else if (_activeTab == 'approved') ...[
                Expanded(
                  child: CustomButton(
                    text: 'Restrict',
                    onPressed: () => _handleRestrict(event),
                    variant: ButtonVariant.warning,
                    size: ButtonSize.sm,
                    isDisabled: _isProcessing,
                    leftIcon: const Icon(LucideIcons.alertTriangle, size: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'View',
                    onPressed: () => context.push('/event/${event.id}'),
                    variant: ButtonVariant.outline,
                    size: ButtonSize.sm,
                    leftIcon: const Icon(LucideIcons.eye, size: 14),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: CustomButton(
                    text: 'Unrestrict',
                    onPressed: () => _handleApproval(event.id, true), // Approving un-restricts
                    variant: ButtonVariant.success,
                    size: ButtonSize.sm,
                    isDisabled: _isProcessing,
                    leftIcon: const Icon(LucideIcons.checkCircle, size: 14),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

