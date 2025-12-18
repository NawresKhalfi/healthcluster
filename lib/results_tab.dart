import 'package:flutter/material.dart';

import 'main.dart' show Patient, PatientAnalysis;

class ResultsTab extends StatelessWidget {
  final Patient? patient;
  final PatientAnalysis? analysis;
  final VoidCallback onNewAnalysis;

  const ResultsTab({
    super.key,
    required this.patient,
    required this.analysis,
    required this.onNewAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (patient == null || analysis == null)
            _EmptyResults(onNewAnalysis: onNewAnalysis)
          else ...[
            _PatientHeader(patient: patient!),
            const SizedBox(height: 16),
            _ClusterSummary(analysis: analysis!),
            const SizedBox(height: 24),
            const _RecommendationsCard(),
            const SizedBox(height: 24),
            _IndicatorsCard(patient: patient!),
            const SizedBox(height: 24),
            _NewAnalysisButton(onPressed: onNewAnalysis),
          ],
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final VoidCallback onNewAnalysis;

  const _EmptyResults({required this.onNewAnalysis});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.insights_rounded,
          size: 64,
          color: Color(0xFF356DFF),
        ),
        const SizedBox(height: 16),
        const Text(
          'Aucune analyse pour le moment',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF262649),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sélectionnez un patient dans l’onglet "Mon Profil" puis lancez une analyse pour voir les résultats ici.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6F6F92),
          ),
        ),
        const SizedBox(height: 32),
        _NewAnalysisButton(onPressed: onNewAnalysis),
      ],
    );
  }
}

class _PatientHeader extends StatelessWidget {
  final Patient patient;

  const _PatientHeader({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF356DFF),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF356DFF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name.isEmpty ? 'Patient' : patient.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF262649),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID Patient: ${patient.id.isEmpty ? 'N/A' : patient.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6F6F92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClusterSummary extends StatelessWidget {
  final PatientAnalysis analysis;

  const _ClusterSummary({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F1FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF262649),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF356DFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.monitor_heart_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.clusterName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF262649),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      analysis.clusterDescription,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F6F92),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7E7FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priorité médicale',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6F6F92),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis.medicalPriority,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF356DFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patients similaires',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6F6F92),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.group_rounded,
                            size: 18,
                            color: Color(0xFF262649),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${analysis.similarPatients}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF262649),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF356DFF),
              ),
              SizedBox(width: 8),
              Text(
                'Recommandations personnalisées',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF262649),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RecommendationRow(
            color: const Color(0xFF2ECC71),
            background: const Color(0xFFE9F9EF),
            icon: Icons.check_circle_outline_rounded,
            text: 'Excellente démarche préventive',
          ),
          const SizedBox(height: 8),
          _RecommendationRow(
            color: const Color(0xFF2ECC71),
            background: const Color(0xFFE9F9EF),
            icon: Icons.monitor_heart_rounded,
            text: 'Continuez vos activités régulières',
          ),
          const SizedBox(height: 8),
          _RecommendationRow(
            color: const Color(0xFF356DFF),
            background: const Color(0xFFE9F1FF),
            icon: Icons.access_time_rounded,
            text: 'Bilan de santé annuel',
          ),
        ],
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  final Color color;
  final Color background;
  final IconData icon;
  final String text;

  const _RecommendationRow({
    required this.color,
    required this.background,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 26,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF262649),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicatorsCard extends StatelessWidget {
  final Patient patient;

  const _IndicatorsCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos indicateurs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF262649),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.9,
            children: [
              _IndicatorTile(
                label: 'Tension',
                value: patient.bloodPressure?.toStringAsFixed(0) ?? '--',
                color: const Color(0xFF356DFF),
              ),
              _IndicatorTile(
                label: 'Glycémie',
                value: patient.bloodSugar?.toStringAsFixed(0) ?? '--',
                color: const Color(0xFF8C4BFF),
              ),
              _IndicatorTile(
                label: 'IMC',
                value: patient.bmi?.toStringAsFixed(1) ?? '--',
                color: const Color(0xFF2ECC71),
              ),
              _IndicatorTile(
                label: 'Exercice/sem',
                value: patient.exerciseFreq?.toStringAsFixed(0) ?? '--',
                color: const Color(0xFFF39C12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndicatorTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _IndicatorTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FF),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6F6F92),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewAnalysisButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewAnalysisButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE3E6F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Nouvelle analyse',
          style: TextStyle(
            color: Color(0xFF262649),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

