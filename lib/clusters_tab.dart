import 'package:flutter/material.dart';

class ClustersTab extends StatelessWidget {
  const ClustersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ClustersHeader(),
          const SizedBox(height: 16),
          const _ClusterCard(
            color: Color(0xFF14C46B),
            icon: Icons.check_circle_outline_rounded,
            title: 'Santé Optimale',
            description:
                'Patients en excellente santé avec faible risque',
            riskLabel: 'Faible',
            patientsCount: 234,
          ),
          const SizedBox(height: 12),
          const _ClusterCard(
            color: Color(0xFFFF4B5C),
            icon: Icons.favorite_border_rounded,
            title: 'Risque Cardiovasculaire',
            description: 'Patients nécessitant surveillance cardiaque',
            riskLabel: 'Élevé',
            patientsCount: 156,
          ),
          const SizedBox(height: 12),
          const _ClusterCard(
            color: Color(0xFFF5B400),
            icon: Icons.opacity_rounded,
            title: 'Métabolique',
            description:
                'Patients avec troubles métaboliques (diabète, cholestérol)',
            riskLabel: 'Moyen',
            patientsCount: 189,
          ),
          const SizedBox(height: 12),
          const _ClusterCard(
            color: Color(0xFF8C4BFF),
            icon: Icons.psychology_rounded,
            title: 'Bien-être Mental',
            description:
                'Focus sur la santé mentale et le stress',
            riskLabel: 'Moyen',
            patientsCount: 142,
          ),
          const SizedBox(height: 12),
          const _ClusterCard(
            color: Color(0xFF356DFF),
            icon: Icons.monitor_heart_rounded,
            title: 'Prévention Active',
            description: 'Patients engagés dans la prévention',
            riskLabel: 'Faible',
            patientsCount: 278,
          ),
        ],
      ),
    );
  }
}

class _ClustersHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF356DFF), Color(0xFF8C4BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Nos clusters de santé',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Chaque patient est assigné à un cluster basé sur son profil de santé pour recevoir des conseils adaptés',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClusterCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final String riskLabel;
  final int patientsCount;

  const _ClusterCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    required this.riskLabel,
    required this.patientsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF262649),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6F6F92),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Risque',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A8AA8),
                ),
              ),
              Text(
                riskLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF262649),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$patientsCount patients',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8A8AA8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

