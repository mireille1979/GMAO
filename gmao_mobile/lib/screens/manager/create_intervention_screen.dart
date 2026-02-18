import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/intervention_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/intervention.dart';
import '../../models/batiment.dart';
import '../../models/equipement.dart';
import '../../models/user.dart';
import '../../models/checklist.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class CreateInterventionScreen extends StatefulWidget {
  const CreateInterventionScreen({super.key});

  @override
  State<CreateInterventionScreen> createState() => _CreateInterventionScreenState();
}

class _CreateInterventionScreenState extends State<CreateInterventionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _checklistController = TextEditingController();
  final _dateController = TextEditingController();

  Priorite _selectedPriority = Priorite.MOYENNE;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  Batiment? _selectedBatiment;
  Equipement? _selectedEquipement;
  User? _selectedTechnicien;
  
  List<String> _checklistItems = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<InterventionProvider>(context, listen: false).fetchAuxData();
      _autoSelectCurrentUser();
    });
  }

  void _autoSelectCurrentUser() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<InterventionProvider>(context, listen: false);
    
    if (auth.user != null && auth.user!.role.toString().contains('TECH')) {
       try {
         final me = provider.technicians.firstWhere((t) => t.id == auth.user!.id);
         setState(() {
           _selectedTechnicien = me;
         });
       } catch (e) {
         // User not found in tech list
       }
    }
  }

  void _addChecklistItem() {
    if (_checklistController.text.isNotEmpty) {
      setState(() {
        _checklistItems.add(_checklistController.text);
        _checklistController.clear();
      });
    }
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItems.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _checklistController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
             colorScheme: const ColorScheme.light(primary: AppTheme.primaryTeal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBatiment == null || _selectedEquipement == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un bâtiment et un équipement')),
        );
        return;
      }

      final intervention = Intervention(
        id: 0,
        titre: _titreController.text,
        description: _descriptionController.text,
        priorite: _selectedPriority,
        statut: Statut.PLANIFIEE,
        datePrevue: _selectedDate,
        batiment: _selectedBatiment,
        equipement: _selectedEquipement,
        technicien: _selectedTechnicien,
        checklist: _checklistItems.map((desc) => Checklist(
          id: 0, 
          description: desc, 
          isChecked: false, 
          interventionId: 0
        )).toList(),
      );

      final success = await Provider.of<InterventionProvider>(context, listen: false)
          .createIntervention(intervention);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Intervention créée avec succès', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.primaryTeal),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Nouvelle Intervention'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<InterventionProvider>(
        builder: (context, provider, child) {
          // Filter equipments
          List<Equipement> filteredEquipments = [];
          if (_selectedBatiment != null) {
            filteredEquipments = provider.equipements
                .where((e) => e.batiment?.id == _selectedBatiment!.id)
                .toList();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (provider.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                      child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  
                  CustomTextField(
                    controller: _titreController,
                    hintText: 'Titre de l\'intervention',
                    prefixIcon: const Icon(Icons.title, color: AppTheme.textGrey),
                    validator: (value) => value!.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _descriptionController,
                    hintText: 'Description détaillée',
                    prefixIcon: const Icon(Icons.description, color: AppTheme.textGrey),
                    validator: (value) => value!.isEmpty ? 'Requis' : null,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown<Priorite>(
                          value: _selectedPriority,
                          label: 'Priorité',
                          items: Priorite.values,
                          itemLabel: (e) => e.toString().split('.').last,
                          onChanged: (v) => setState(() => _selectedPriority = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _dateController,
                          hintText: 'Date',
                          readOnly: true,
                          prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.textGrey),
                          onTap: () => _selectDate(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Localisation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                  const SizedBox(height: 12),
                  
                  _buildDropdown<Batiment>(
                    value: _selectedBatiment,
                    label: 'Bâtiment',
                    items: provider.batiments,
                    itemLabel: (b) => b.nom,
                    onChanged: (v) => setState(() {
                      _selectedBatiment = v;
                      _selectedEquipement = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDropdown<Equipement>(
                    value: _selectedEquipement,
                    label: 'Équipement',
                    items: filteredEquipments,
                    itemLabel: (e) => e.nom,
                    onChanged: (v) => setState(() => _selectedEquipement = v),
                    hint: _selectedBatiment == null ? 'Sélectionnez un bâtiment' : null,
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Assignation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                  const SizedBox(height: 12),
                  
                  _buildDropdown<User>(
                    value: _selectedTechnicien,
                    label: 'Technicien',
                    items: provider.technicians,
                    itemLabel: (t) => '${t.firstName} ${t.lastName}',
                    onChanged: (v) => setState(() => _selectedTechnicien = v),
                  ),

                  const SizedBox(height: 24),
                  const Text('Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _checklistController,
                          hintText: 'Ajouter une tâche...',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: _addChecklistItem,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_checklistItems.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: _checklistItems.asMap().entries.map((entry) {
                          return ListTile(
                            title: Text(entry.value, style: const TextStyle(fontFamily: 'Poppins')),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                              onPressed: () => _removeChecklistItem(entry.key),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 40),
                  
                  CustomButton(
                    text: 'Planifier l\'intervention',
                    onPressed: _submit,
                    isLoading: provider.isLoading,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          style: const TextStyle(color: AppTheme.textDark, fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppTheme.primaryTeal)),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
          hint: hint != null ? Text(hint) : null,
          validator: (v) => v == null && hint == null ? 'Requis' : null,
        ),
      ],
    );
  }
}
