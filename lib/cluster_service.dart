import 'kmeans.dart';
import 'patient.dart';

class ClusterService {
  late final StandardScaler _scaler;
  late final KMeansResult _model;
  bool _ready = false;

  bool get ready => _ready;
  List<List<double>> get centroids => _model.centroids;

  Future<void> train(List<List<double>> data, {int k = 3}) async {
    _scaler = StandardScaler();
    final scaled = _scaler.fitTransform(data);
    _model = kmeans(scaled, k: k, seed: 42, maxIters: 100);
    _ready = true;
  }

  int predict(Patient p) {
    if (!_ready) throw StateError("Le modèle n'est pas entraîné.");
    final scaledPoint = _scaler.transform([p.toVector()]).first;
    return predictCluster(scaledPoint, _model.centroids);
  }
}
