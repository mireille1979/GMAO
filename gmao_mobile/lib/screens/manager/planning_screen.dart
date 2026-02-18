import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/intervention_provider.dart';
import '../../models/intervention.dart';
import '../tech/intervention_details_screen.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_card.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
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
    setState(() => _isLoading = true);
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    
    // Slight delay to simulate fetch if needed or just async
    final interventions = await Provider.of<InterventionProvider>(context, listen: false)
        .fetchInterventionsByDateRange(start, end);

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

    setState(() {
      _events = newEvents;
      _isLoading = false;
      _selectedInterventions.value = _getInterventionsForDay(_selectedDay!);
    });
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
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Planification Globale'),
        backgroundColor: AppTheme.backgroundWhite,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(color: AppTheme.primaryTeal),
          TableCalendar<Intervention>(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getInterventionsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppTheme.lightTeal,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryTeal,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppTheme.darkTeal,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
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
          const SizedBox(height: 16.0),
          Expanded(
            child: ValueListenableBuilder<List<Intervention>>(
              valueListenable: _selectedInterventions,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(child: Text('Aucune intervention ce jour.', style: TextStyle(color: AppTheme.textGrey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final intervention = value[index];
                    return CustomCard(
                      padding: EdgeInsets.zero,
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
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getStatusColor(intervention.statut).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                intervention.statut == Statut.TERMINEE ? Icons.check : Icons.build, 
                                color: _getStatusColor(intervention.statut),
                                size: 20
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    intervention.titre, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${intervention.batiment?.nom ?? 'N/A'} - ${intervention.technicien?.firstName ?? 'Non assigné'}",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textGrey),
                          ],
                        ),
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
