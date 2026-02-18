import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/intervention_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/intervention.dart';
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
    _fetchEventsForMonth(_focusedDay);
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
        _selectedInterventions.value = _getInterventionsForDay(_selectedDay!);
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

  Color _getStatusColor(Statut statut) {
    switch (statut) {
      case Statut.PLANIFIEE: return Colors.blue;
      case Statut.EN_COURS: return Colors.orange;
      case Statut.TERMINEE: return Colors.green;
      case Statut.ANNULEE: return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Planning'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(), 
          TableCalendar<Intervention>(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getInterventionsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Color(0xFF1565C0),
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
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Intervention>>(
              valueListenable: _selectedInterventions,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(child: Text('Aucune intervention ce jour.'));
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final intervention = value[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(intervention.statut),
                          child: Icon(
                            intervention.statut == Statut.TERMINEE ? Icons.check : Icons.build, 
                            color: Colors.white,
                            size: 20
                          ),
                        ),
                        title: Text(
                          intervention.titre, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Text(
                          "${intervention.batiment?.nom ?? 'N/A'} - ${intervention.equipement?.nom ?? 'N/A'}"
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
