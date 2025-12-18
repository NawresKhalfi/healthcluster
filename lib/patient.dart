class Patient {
  final double age;
  final double bmi;
  final double bloodSugar;     // glucose
  final double bloodPressure;
  final double cholesterol;
  final double exerciseFreq;
  final double stressLevel;

  const Patient({
    required this.age,
    required this.bmi,
    required this.bloodSugar,
    required this.bloodPressure,
    required this.cholesterol,
    required this.exerciseFreq,
    required this.stressLevel,
  });

  List<double> toVector() => [
        age,
        bloodPressure,
        bloodSugar,
        cholesterol,
        bmi,
        exerciseFreq,
        stressLevel,
      ];
}
