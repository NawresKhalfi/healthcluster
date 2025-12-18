// lib/kmeans.dart
import 'dart:math';

/// ---------------------------
/// StandardScaler (z-score)
/// x' = (x - mean) / std
/// ---------------------------
class StandardScaler {
  late final List<double> mean;
  late final List<double> std;

  bool get isFitted => _fitted;
  bool _fitted = false;

  /// Fit + transform sur un dataset
  List<List<double>> fitTransform(List<List<double>> x) {
    if (x.isEmpty) {
      throw ArgumentError('Dataset vide.');
    }
    final n = x.length;
    final d = x[0].length;
    if (d == 0) throw ArgumentError('Dataset sans colonnes.');

    // vérifier longueurs
    for (final row in x) {
      if (row.length != d) {
        throw ArgumentError('Toutes les lignes doivent avoir la même taille.');
      }
    }

    final m = List<double>.filled(d, 0.0);
    for (var j = 0; j < d; j++) {
      double s = 0.0;
      for (var i = 0; i < n; i++) s += x[i][j];
      m[j] = s / n;
    }

    final sdev = List<double>.filled(d, 0.0);
    for (var j = 0; j < d; j++) {
      double varSum = 0.0;
      for (var i = 0; i < n; i++) {
        final diff = x[i][j] - m[j];
        varSum += diff * diff;
      }
      final variance = varSum / n;
      sdev[j] = sqrt(variance);

      // Evite division par 0 (colonne constante)
      if (sdev[j] == 0.0) sdev[j] = 1.0;
    }

    mean = m;
    std = sdev;
    _fitted = true;

    return transform(x);
  }

  /// Transform (nécessite fitTransform avant)
  List<List<double>> transform(List<List<double>> x) {
    if (!_fitted) {
      throw StateError('StandardScaler non entraîné: appeler fitTransform() avant.');
    }
    if (x.isEmpty) return [];

    final n = x.length;
    final d = mean.length;
    for (final row in x) {
      if (row.length != d) {
        throw ArgumentError('Dimension invalide: attendu $d colonnes.');
      }
    }

    final out = List.generate(n, (_) => List<double>.filled(d, 0.0));
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < d; j++) {
        out[i][j] = (x[i][j] - mean[j]) / std[j];
      }
    }
    return out;
  }
}

/// ---------------------------
/// K-means
/// ---------------------------
class KMeansResult {
  final List<int> labels; // cluster de chaque point
  final List<List<double>> centroids; // centres (dans l'espace normalisé)
  final double inertia; // SSE (somme des distances^2 aux centroïdes)

  KMeansResult({
    required this.labels,
    required this.centroids,
    required this.inertia,
  });
}

double _dist2(List<double> a, List<double> b) {
  double s = 0.0;
  for (var i = 0; i < a.length; i++) {
    final d = a[i] - b[i];
    s += d * d;
  }
  return s;
}

List<double> _meanVec(List<List<double>> pts, int d) {
  final m = List<double>.filled(d, 0.0);
  if (pts.isEmpty) return m;
  for (final p in pts) {
    for (var j = 0; j < d; j++) {
      m[j] += p[j];
    }
  }
  for (var j = 0; j < d; j++) {
    m[j] /= pts.length;
  }
  return m;
}

int _argMinCentroid(List<double> x, List<List<double>> centroids) {
  var best = 0;
  var bestDist = double.infinity;
  for (var c = 0; c < centroids.length; c++) {
    final dist = _dist2(x, centroids[c]);
    if (dist < bestDist) {
      bestDist = dist;
      best = c;
    }
  }
  return best;
}

/// Entraîne K-means sur x (déjà normalisé ou non, à toi de décider).
/// - k: nombre de clusters
/// - seed: reproductibilité
/// - maxIters: max itérations
KMeansResult kmeans(
  List<List<double>> x, {
  required int k,
  int seed = 42,
  int maxIters = 100,
}) {
  if (x.isEmpty) throw ArgumentError('Dataset vide.');
  if (k < 2) throw ArgumentError('k doit être >= 2.');
  if (k > x.length) throw ArgumentError('k ne peut pas dépasser le nombre de points.');

  final n = x.length;
  final d = x[0].length;
  for (final row in x) {
    if (row.length != d) {
      throw ArgumentError('Toutes les lignes doivent avoir la même taille.');
    }
  }

  final rnd = Random(seed);

  // Init: choisir k points distincts comme centroïdes
  final used = <int>{};
  final centroids = <List<double>>[];
  while (centroids.length < k) {
    final idx = rnd.nextInt(n);
    if (used.add(idx)) centroids.add(List<double>.from(x[idx]));
  }

  final labels = List<int>.filled(n, 0);

  for (var iter = 0; iter < maxIters; iter++) {
    bool changed = false;

    // Assignment step
    for (var i = 0; i < n; i++) {
      final best = _argMinCentroid(x[i], centroids);
      if (labels[i] != best) {
        labels[i] = best;
        changed = true;
      }
    }

    // Update step
    final buckets = List.generate(k, (_) => <List<List<double>>>[]);
    for (var i = 0; i < n; i++) {
      buckets[labels[i]].add(x[i].cast<List<double>>());
    }

    for (var c = 0; c < k; c++) {
      if (buckets[c].isEmpty) {
        // cluster vide => réinitialiser sur un point aléatoire
        centroids[c] = List<double>.from(x[rnd.nextInt(n)]);
      } else {
        centroids[c] = _meanVec(buckets[c].cast<List<double>>(), d);
      }
    }

    if (!changed) break; // convergence
  }

  final inertia = computeInertia(x, labels, centroids);

  return KMeansResult(labels: labels, centroids: centroids, inertia: inertia);
}

/// Prédit le cluster d'un nouveau point (point DOIT être dans le même espace que les centroïdes).
int predictCluster(List<double> point, List<List<double>> centroids) {
  if (centroids.isEmpty) throw ArgumentError('Aucun centroïde.');
  if (point.length != centroids[0].length) {
    throw ArgumentError('Dimension invalide: point=${point.length}, centroid=${centroids[0].length}');
  }
  return _argMinCentroid(point, centroids);
}

/// SSE / Inertia : somme des distances^2 aux centroïdes.
double computeInertia(List<List<double>> x, List<int> labels, List<List<double>> centroids) {
  double sse = 0.0;
  for (var i = 0; i < x.length; i++) {
    final c = labels[i];
    sse += _dist2(x[i], centroids[c]);
  }
  return sse;
}

/// Bonus: méthode du coude (inertia pour k=2..kMax)
/// Retourne une Map: k -> inertia
Map<int, double> elbowInertia(
  List<List<double>> x, {
  int kMin = 2,
  int kMax = 8,
  int seed = 42,
  int maxIters = 100,
}) {
  if (kMax < kMin) throw ArgumentError('kMax doit être >= kMin');
  final out = <int, double>{};
  for (var k = kMin; k <= kMax; k++) {
    final res = kmeans(x, k: k, seed: seed, maxIters: maxIters);
    out[k] = res.inertia;
  }
  return out;
}
