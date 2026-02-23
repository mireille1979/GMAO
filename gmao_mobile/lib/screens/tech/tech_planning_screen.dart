import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/intervention_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/intervention.dart';
import '../../utils/theme.dart';
import 'intervention_details_screen.dart';

class TechPlanningScreen extends StatefulWidget {
  const TechPlanningScreen({super.key});

  @override
  State<TechPlanningScreen> createState() => _TechPlanningScreenState();
}

class _TechPlanningScreenState extends State<TechPlanningScreen> {
  late final ValueNotifier<List<Intervention>> _selectedInterventions;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Intervention>> _events = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedInterventions = ValueNotifier(_getInterventionsForDay(_selectedDay!));
    
    // Fetch initial data after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventsForMonth(_focusedDay);
    });
  }

  @override
  void dispose() {
    _selectedInterventions.dispose();
    super.dispose();
  }

  Future<void> _fetchEventsForMonth(DateTime date) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user?.id == null) return;

    setState(() => _isLoading = true);
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    
    final interventions = await Provider.of<InterventionProvider>(context, listen: false)
        .fetchInterventionsByDateRange(start, end, techId: user!.id);

    final newEvents = <DateTime, List<Intervention>>{};
    for (var intervention in interventions) {
      if (intervention.datePrevue == null) continue;
      final date = DateTime(
        intervention.datePrevue!.year,
        intervention.datePrevue!.month,
        intervention.datePrevue!.day,
      );
      if (newEvents[date] == null) newEvents[date] = [];
      newEvents[date]!.add(intervention);
    }

    if (mounted) {
      setState(() {
        _events = newEvents;
        _isLoading = false;
         // Refresh list if selected day is in this month
        if (_selectedDay != null && 
            _selectedDay!.month == date.month && 
            _selectedDay!.year == date.year) {
           _selectedInterventions.value = _getInterventionsForDay(_selectedDay!);
        }
      });
    }
  }

  List<Intervention> _getInterventionsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedInterventions.value = _getInterventionsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Mon Planning', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: TableCalendar<Intervention>(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getInterventionsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                 formatButtonVisible: false,
                 titleCentered: true,
                 titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  gradient: AppTheme.orangeGradient,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFFFFCC80), // Light Orange
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() => _calendarFormat = format);
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _fetchEventsForMonth(focusedDay);
              },
            ),
          ),
          if (_isLoading) 
             const Padding(
               padding: EdgeInsets.symmetric(horizontal: 20),
               child: LinearProgressIndicator(color: AppTheme.primaryOrange, backgroundColor: Color(0xFFFFCC80)),
             ),
             
          const SizedBox(height: 10),
          
          Expanded(
            child: ValueListenableBuilder<List<Intervention>>(
              valueListenable: _selectedInterventions,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Aucune intervention ce jour', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }
                
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: value.length,
                  separatorBuilder: (_,__) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final intervention = value[index];
                    return _buildInterventionCard(intervention);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionCard(Intervention intervention) {
    Color statusColor = Colors.grey;
    if (intervention.statut == Statut.EN_COURS) statusColor = Colors.orange;
    if (intervention.statut == Statut.TERMINEE) statusColor = Colors.green;
    if (intervention.statut == Statut.PLANIFIEE) statusColor = Colors.blue;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InterventionDetailsScreen(intervention: intervention),
              ),
            ).then((_) {
               _fetchEventsForMonth(_focusedDay); 
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Time / Status Indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intervention.titre,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 4),
                      Row(
                         children: [
                           Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                           const SizedBox(width: 4),
                           Expanded(
                             child: Text(
                               intervention.batiment?.nom ?? 'N/A',
                               style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                               overflow: TextOverflow.ellipsis,
                             ),
                           ),
                         ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
