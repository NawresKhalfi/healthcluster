import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'clusters_tab.dart';
import 'results_tab.dart';

void main() {
  runApp(const HealthClusterApp());
}

class HealthClusterApp extends StatelessWidget {
  const HealthClusterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthCluster',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4BFF),
        ),
        useMaterial3: true,
      ),
      home: const HealthClusterHomePage(),
    );
  }
}

class Patient {
  final String id;
  final String name;
  final int? age;
  final double? bloodPressure;
  final double? bloodSugar;
  final double? cholesterol;
  final double? bmi;
  final double? exerciseFreq;
  final double? stressLevel;

  Patient({
    required this.id,
    required this.name,
    this.age,
    this.bloodPressure,
    this.bloodSugar,
    this.cholesterol,
    this.bmi,
    this.exerciseFreq,
    this.stressLevel,
  });

  factory Patient.fromCsvRow(
    Map<String, int> headerIndex,
    List<dynamic> row,
  ) {
    String readString(String key) {
      final index = headerIndex[key];
      if (index == null || index >= row.length) return '';
      final value = row[index];
      return value == null ? '' : value.toString().trim();
    }

    int? readInt(String key) {
      final value = readString(key);
      if (value.isEmpty) return null;
      return int.tryParse(value);
    }

    double? readDouble(String key) {
      final value = readString(key).replaceAll(',', '.');
      if (value.isEmpty) return null;
      return double.tryParse(value);
    }

    return Patient(
      id: readString('id'),
      name: readString('name'),
      age: readInt('age'),
      bloodPressure: readDouble('bloodPressure'),
      bloodSugar: readDouble('bloodSugar'),
      cholesterol: readDouble('cholesterol'),
      bmi: readDouble('bmi'),
      exerciseFreq: readDouble('exerciseFreq'),
      stressLevel: readDouble('stressLevel'),
    );
  }
}

class PatientAnalysis {
  final String clusterName;
  final String clusterDescription;
  final String medicalPriority;
  final String riskLevel;
  final int similarPatients;

  PatientAnalysis({
    required this.clusterName,
    required this.clusterDescription,
    required this.medicalPriority,
    required this.riskLevel,
    required this.similarPatients,
  });
}

class HealthClusterHomePage extends StatefulWidget {
  const HealthClusterHomePage({super.key});

  @override
  State<HealthClusterHomePage> createState() => _HealthClusterHomePageState();
}

class _HealthClusterHomePageState extends State<HealthClusterHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<Patient> _patients = [];
  Patient? _selectedPatient;
  Patient? _analysedPatient;
  PatientAnalysis? _analysis;
  bool _isImporting = false;
  String? _importError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickCsvFile() async {
    setState(() {
      _isImporting = true;
      _importError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null) {
        setState(() {
          _isImporting = false;
        });
        return;
      }

      final file = result.files.single;
      String content;

      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        throw Exception('Impossible de lire le fichier sélectionné.');
      }

      final patients = _parsePatientsFromCsv(content);

      if (patients.isEmpty) {
        throw Exception('Aucun patient valide trouvé dans le fichier CSV.');
      }

      setState(() {
        _patients = patients;
        _selectedPatient = patients.first;
        _isImporting = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fichier importé : ${patients.length} patients chargés.'),
        ),
      );
    } catch (e) {
      setState(() {
        _isImporting = false;
        _importError = e.toString();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'import : $e'),
        ),
      );
    }
  }

  List<Patient> _parsePatientsFromCsv(String content) {
    final rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(content.trim());

    if (rows.isEmpty) return [];

    final headerRow = rows.first;
    final headerIndex = <String, int>{};

    for (var i = 0; i < headerRow.length; i++) {
      headerIndex[headerRow[i].toString().trim()] = i;
    }

    final patients = <Patient>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      try {
        patients.add(Patient.fromCsvRow(headerIndex, row));
      } catch (_) {
        // Ignore invalid rows
      }
    }

    return patients;
  }

  void _onSelectPatient(Patient patient) {
    setState(() {
      _selectedPatient = patient;
    });
  }

  void _onAnalyseSelectedPatient() {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d\'abord sélectionner un patient.'),
        ),
      );
      return;
    }

    final patient = _selectedPatient!;
    final analysis = _buildAnalysisForPatient(patient);

    setState(() {
      _analysedPatient = patient;
      _analysis = analysis;
    });

    _tabController.animateTo(2);
  }

  PatientAnalysis _buildAnalysisForPatient(Patient patient) {
    // Logique simplifiée de démonstration.
    final bp = patient.bloodPressure ?? 0;
    final bmi = patient.bmi ?? 0;
    final stress = patient.stressLevel ?? 0;

    if (bp > 140 || bmi > 30 || stress >= 7) {
      return PatientAnalysis(
        clusterName: 'Risque Cardiovasculaire',
        clusterDescription: 'Patients nécessitant surveillance cardiaque',
        medicalPriority: 'Élevée',
        riskLevel: 'Élevé',
        similarPatients: 156,
      );
    }

    return PatientAnalysis(
      clusterName: 'Prévention Active',
      clusterDescription: 'Patients engagés dans la prévention',
      medicalPriority: 'Basse',
      riskLevel: 'Faible',
      similarPatients: 278,
    );
  }

  void _onNewAnalysisRequested() {
    setState(() {
      _analysis = null;
      _analysedPatient = null;
      _selectedPatient = null;
    });
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            const SizedBox(height: 16),
            _Tabs(tabController: _tabController),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ProfileTab(
                    onPickFile: _pickCsvFile,
                    isImporting: _isImporting,
                    importError: _importError,
                    patients: _patients,
                    selectedPatient: _selectedPatient,
                    onPatientSelected: _onSelectPatient,
                    onAnalysePatient: _onAnalyseSelectedPatient,
                  ),
                  const ClustersTab(),
                  ResultsTab(
                    patient: _analysedPatient,
                    analysis: _analysis,
                    onNewAnalysis: _onNewAnalysisRequested,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5B4BFF), Color(0xFF8C4BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'HealthCluster',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Segmentation intelligente des patients pour des conseils de santé personnalisés\net une meilleure priorisation médicale',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final TabController tabController;

  const _Tabs({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TabBar(
          controller: tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF5B4BFF), Color(0xFF8C4BFF)],
            ),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF4A4A6A),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Mon Profil'),
            Tab(text: 'Les Clusters'),
            Tab(text: 'Mes Résultats'),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final VoidCallback onPickFile;
  final bool isImporting;
  final String? importError;
  final List<Patient> patients;
  final Patient? selectedPatient;
  final ValueChanged<Patient> onPatientSelected;
  final VoidCallback onAnalysePatient;

  const _ProfileTab({
    required this.onPickFile,
    required this.isImporting,
    required this.importError,
    required this.patients,
    required this.selectedPatient,
    required this.onPatientSelected,
    required this.onAnalysePatient,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ImportCsvCard(
            onPickFile: onPickFile,
            isImporting: isImporting,
          ),
          if (importError != null) ...[
            const SizedBox(height: 8),
            Text(
              importError!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _SelectPatientButton(
            hasPatients: patients.isNotEmpty,
            onPressed: () {
              if (patients.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Importez d\'abord un fichier CSV.'),
                  ),
                );
                return;
              }
            },
          ),
          const SizedBox(height: 24),
          if (patients.isNotEmpty) ...[
            _PatientsList(
              patients: patients,
              selectedPatient: selectedPatient,
              onPatientSelected: onPatientSelected,
            ),
            const SizedBox(height: 24),
            _SelectedPatientData(
              patient: selectedPatient,
              onAnalysePatient: onAnalysePatient,
            ),
          ],
        ],
      ),
    );
  }
}

class _ImportCsvCard extends StatelessWidget {
  final VoidCallback onPickFile;
  final bool isImporting;

  const _ImportCsvCard({
    required this.onPickFile,
    required this.isImporting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFCED4FF),
          style: BorderStyle.solid,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monitor_heart_rounded,
              color: Color(0xFF5B4BFF),
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Importer un fichier CSV',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF262649),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Format attendu : id, name, age, bloodPressure, bloodSugar, cholesterol, bmi, exerciseFreq, stressLevel',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6F6F92),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            height: 44,
            child: ElevatedButton(
              onPressed: isImporting ? null : onPickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF356DFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Choisir un fichier',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Fonction "Télécharger un fichier exemple" à implémenter.',
                  ),
                ),
              );
            },
            child: const Text(
              'Télécharger un fichier exemple',
              style: TextStyle(
                color: Color(0xFF356DFF),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectPatientButton extends StatelessWidget {
  final bool hasPatients;
  final VoidCallback onPressed;

  const _SelectPatientButton({
    required this.hasPatients,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: hasPatients ? 1.0 : 0.6,
      child: GestureDetector(
        onTap: hasPatients ? onPressed : null,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B4BFF), Color(0xFF8C4BFF)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Sélectionnez un patient',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PatientsList extends StatelessWidget {
  final List<Patient> patients;
  final Patient? selectedPatient;
  final ValueChanged<Patient> onPatientSelected;

  const _PatientsList({
    required this.patients,
    required this.selectedPatient,
    required this.onPatientSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patients importés (${patients.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF262649),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: patients.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final patient = patients[index];
            final isSelected = patient == selectedPatient;

            return GestureDetector(
              onTap: () => onPatientSelected(patient),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE4EDFF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF356DFF)
                        : const Color(0xFFE0E0F0),
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name.isEmpty
                                ? 'Patient ${index + 1}'
                                : patient.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF262649),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Âge: ${patient.age?.toString() ?? '-'} ans • Tension: ${patient.bloodPressure?.toString() ?? '-'} • IMC: ${patient.bmi?.toStringAsFixed(1) ?? '-'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6F6F92),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF356DFF),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SelectedPatientData extends StatelessWidget {
  final Patient? patient;
  final VoidCallback onAnalysePatient;

  const _SelectedPatientData({
    required this.patient,
    required this.onAnalysePatient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (patient != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE4EDFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient!.name.isEmpty ? 'Patient sélectionné' : patient!.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF262649),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Âge: ${patient!.age?.toString() ?? '-'} ans • Tension: ${patient!.bloodPressure?.toString() ?? '-'} • IMC: ${patient!.bmi?.toStringAsFixed(1) ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6F6F92),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFF5F6FF), Color(0xFFEDE8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Données du patient sélectionné',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF262649),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _DataChip(
                      label: 'Âge',
                      value: patient!.age != null
                          ? '${patient!.age} ans'
                          : '-',
                    ),
                    _DataChip(
                      label: 'Tension',
                      value: patient!.bloodPressure?.toString() ?? '-',
                    ),
                    _DataChip(
                      label: 'Glycémie',
                      value: patient!.bloodSugar?.toString() ?? '-',
                    ),
                    _DataChip(
                      label: 'Cholestérol',
                      value: patient!.cholesterol?.toString() ?? '-',
                    ),
                    _DataChip(
                      label: 'IMC',
                      value: patient!.bmi?.toStringAsFixed(1) ?? '-',
                    ),
                    _DataChip(
                      label: 'Exercice/sem',
                      value: patient!.exerciseFreq?.toString() ?? '-',
                    ),
                    _DataChip(
                      label: 'Stress /10',
                      value: patient!.stressLevel?.toString() ?? '-',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onAnalysePatient,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF356DFF), Color(0xFF8C4BFF)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Analyser ce patient',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DataChip extends StatelessWidget {
  final String label;
  final String value;

  const _DataChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8A8AA8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF262649),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;

  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title (à venir)',
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF6F6F92),
        ),
      ),
    );
  }
}
