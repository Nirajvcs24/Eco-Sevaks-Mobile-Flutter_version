import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../widgets/event_card.dart';
import '../widgets/badge_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_spinner.dart';
import '../constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ApiService _apiService = ApiService();
  List<AppEvent> _allEvents = [];
  List<AppEvent> _filteredEvents = [];
  bool _isLoading = true;
  String _searchTerm = '';
  String _eventType = 'all';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _apiService.getAllEvents();
      setState(() {
        _allEvents = events;
        _applyFilters();
      });
    } catch (e) {
      debugPrint('Error fetching events: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        final matchesSearch = event.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
            event.description.toLowerCase().contains(_searchTerm.toLowerCase()) ||
            event.location.toLowerCase().contains(_searchTerm.toLowerCase()) ||
            event.tags.any((tag) => tag.toLowerCase().contains(_searchTerm.toLowerCase()));
        final matchesType = _eventType == 'all' || event.type == _eventType;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchTerm = '';
      _eventType = 'all';
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Events', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: _fetchEvents,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search and Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      _searchTerm = value;
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(LucideIcons.search, size: 18),
                      suffixIcon: _searchTerm.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 18),
                              onPressed: () {
                                setState(() => _searchTerm = '');
                                _applyFilters();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _eventType != 'all' ? AppColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.filter,
                      color: _eventType != 'all' ? Colors.white : AppColors.dark,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Active Filters
            if (_searchTerm.isNotEmpty || _eventType != 'all')
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_eventType != 'all')
                      BadgeWidget(
                        label: _eventType == 'virtual' ? '🌐 Virtual' : '📍 In-person',
                        variant: BadgeVariant.accent,
                        size: BadgeSize.sm,
                      ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear all', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                    ),
                  ],
                ),
              ),

            // Count
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${_filteredEvents.length} events found',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingSpinner())
                  : _filteredEvents.isEmpty
                      ? EmptyState(
                          title: 'No events found',
                          description: _searchTerm.isNotEmpty || _eventType != 'all' ? 'Try adjusting your filters.' : 'No events available right now.',
                          actionText: _searchTerm.isNotEmpty || _eventType != 'all' ? 'Clear Filters' : null,
                          onAction: _searchTerm.isNotEmpty || _eventType != 'all' ? _clearFilters : null,
                        )
                      : ListView.builder(
                          itemCount: _filteredEvents.length,
                          padding: const EdgeInsets.only(bottom: 100),
                          itemBuilder: (context, index) {
                            return EventCard(
                              event: _filteredEvents[index],
                              onTap: () => context.push('/event/${_filteredEvents[index].id}'),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  const Text('Event Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _FilterButton(
                        label: 'All',
                        isSelected: _eventType == 'all',
                        onTap: () {
                          setState(() => _eventType = 'all');
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        label: '🌐 Virtual',
                        isSelected: _eventType == 'virtual',
                        onTap: () {
                          setState(() => _eventType = 'virtual');
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        label: '📍 In-person',
                        isSelected: _eventType == 'in-person',
                        onTap: () {
                          setState(() => _eventType = 'in-person');
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
