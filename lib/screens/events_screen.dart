import 'package:flutter/material.dart';
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
  String _selectedArea = 'all';
  String _timeRange = 'all'; // all, morning, afternoon, evening

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
        
        final matchesArea = _selectedArea == 'all' || event.location.toLowerCase().contains(_selectedArea.toLowerCase());
        
        bool matchesTime = true;
        if (_timeRange != 'all') {
          final hour = event.date.hour;
          if (_timeRange == 'morning') matchesTime = hour >= 6 && hour < 12;
          if (_timeRange == 'afternoon') matchesTime = hour >= 12 && hour < 18;
          if (_timeRange == 'evening') matchesTime = hour >= 18 && hour <= 23;
        }

        return matchesSearch && matchesType && matchesArea && matchesTime;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchTerm = '';
      _eventType = 'all';
      _selectedArea = 'all';
      _timeRange = 'all';
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
            if (_searchTerm.isNotEmpty || _eventType != 'all' || _selectedArea != 'all' || _timeRange != 'all')
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_eventType != 'all')
                      BadgeWidget(
                        label: _eventType == 'virtual' ? '🌐 Virtual' : '📍 In-person',
                        variant: BadgeVariant.accent,
                        size: BadgeSize.sm,
                      ),
                    if (_selectedArea != 'all')
                      BadgeWidget(
                        label: '📍 $_selectedArea',
                        variant: BadgeVariant.primary,
                        size: BadgeSize.sm,
                      ),
                    if (_timeRange != 'all')
                      BadgeWidget(
                        label: '🕒 ${_timeRange[0].toUpperCase()}${_timeRange.substring(1)}',
                        variant: BadgeVariant.secondary,
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
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                final areas = ['all', ..._allEvents.map((e) => e.location.split(',').last.trim()).toSet().toList()];
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Filter Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  _eventType = 'all';
                                  _selectedArea = 'all';
                                  _timeRange = 'all';
                                });
                                _applyFilters();
                              },
                              child: const Text('Reset All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Event Type
                        const Text('Event Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _FilterButton(
                              label: 'All',
                              isSelected: _eventType == 'all',
                              onTap: () => setModalState(() => _eventType = 'all'),
                            ),
                            const SizedBox(width: 8),
                            _FilterButton(
                              label: '🌐 Virtual',
                              isSelected: _eventType == 'virtual',
                              onTap: () => setModalState(() => _eventType = 'virtual'),
                            ),
                            const SizedBox(width: 8),
                            _FilterButton(
                              label: '📍 In-person',
                              isSelected: _eventType == 'in-person',
                              onTap: () => setModalState(() => _eventType = 'in-person'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Area
                        const Text('Area / City', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: areas.length,
                            itemBuilder: (context, index) {
                              final area = areas[index];
                              final isSelected = _selectedArea == area;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(area == 'all' ? 'All Cities' : area),
                                  selected: isSelected,
                                  onSelected: (selected) => setModalState(() => _selectedArea = area),
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.dark),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Time
                        const Text('Time of Day', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            _FilterChip(
                              label: 'Morning',
                              icon: LucideIcons.sunrise,
                              isSelected: _timeRange == 'morning',
                              onTap: () => setModalState(() => _timeRange = 'morning'),
                            ),
                            _FilterChip(
                              label: 'Afternoon',
                              icon: LucideIcons.sun,
                              isSelected: _timeRange == 'afternoon',
                              onTap: () => setModalState(() => _timeRange = 'afternoon'),
                            ),
                            _FilterChip(
                              label: 'Evening',
                              icon: LucideIcons.moon,
                              isSelected: _timeRange == 'evening',
                              onTap: () => setModalState(() => _timeRange = 'evening'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const SizedBox(height: 32),

                        // Apply Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              _applyFilters();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text('Show Results', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
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

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
