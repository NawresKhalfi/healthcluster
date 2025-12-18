# 🏥 HealthCluster – Application de Segmentation des Patients (K-means)
## Installation et commandes
Prérequis

Flutter installé et configuré
👉 https://docs.flutter.dev/get-started/install

Un émulateur Android ou un appareil physique

**Étapes d’installation

1.Cloner le dépôt GitHub :
git clone https://github.com/votre-username/healthcluster.git
cd healthcluster
2.Installer les dépendances:
flutter pub get
3.Vérifier les appareils disponibles :
flutter devices
4.Lancer l’application :
flutter run
## Utilisation de l’application

1.Lancer l’application avec flutter run

2.Importer le fichier patients.csv

3.L’application entraîne automatiquement l’algorithme K-means

4.Saisir les informations de santé d’un patient

5.Cliquer sur Analyser / Prédire

6.Le cluster de risque du patient est affiché :

+Santé optimale

+Prévention active

+Risque cardiovasculaire

## ⚙️ Dépendances
Le projet utilise les technologies et bibliothèques suivantes :

- **Flutter SDK** (version stable)
- **Dart**
- **csv** : lecture et parsing des fichiers CSV
- **Material UI** (intégré à Flutter)

### Dépendance Flutter utilisée
```yaml
dependencies:
  flutter:
    sdk: flutter
  csv: ^6.0.0

##📌 Description du projet
**HealthCluster** est une application mobile développée avec **Flutter** qui utilise l’algorithme de **Data Mining K-means** pour segmenter des patients selon leurs caractéristiques médicales.

L’objectif est de regrouper automatiquement les patients en différents **clusters de risque** afin de faciliter :
- la prévention médicale,
- la priorisation des patients,
- la personnalisation des recommandations de santé.

Ce projet s’inscrit dans le cadre du **mini-projet Data Mining**.

---

## 🎯 Objectifs
- Appliquer un algorithme de **clustering non supervisé (K-means)** sur des données de santé
- Comprendre l’impact de la **normalisation des données**
- Développer une application mobile intégrant un algorithme de Data Mining
- Visualiser et interpréter les résultats du clustering

---

## 🧠 Algorithme de Data Mining utilisé
### 🔹 K-means
L’algorithme **K-means** permet de regrouper les patients en *k* groupes selon leur similarité.

### Étapes appliquées :
1. Lecture des données depuis un fichier CSV
2. Sélection des variables numériques
3. **Normalisation des données (StandardScaler)**
4. Application de **K-means avec k = 3**
5. Attribution de chaque patient à un cluster
6. Prédiction du cluster pour un nouveau patient

---

## 🏥 Données utilisées
Les données sont stockées dans le fichier `patients.csv`.

### Variables :
- `age`
- `bloodPressure`
- `bloodSugar`
- `cholesterol`
- `bmi`
- `exerciseFreq`
- `stressLevel`

Toutes les variables sont **numériques**, ce qui rend le dataset compatible avec K-means.

---

## 📊 Interprétation des clusters
Les clusters sont interprétés comme suit :

| Cluster | Description |
|-------|------------|
| 0 | Santé optimale (risque faible) |
| 1 | Prévention active (risque moyen) |
| 2 | Risque cardiovasculaire (risque élevé) |

> ⚠️ Les noms des clusters sont attribués après analyse des centroïdes.

---

## 🛠️ Technologies utilisées
- **Flutter** (application mobile)
- **Dart**
- Algorithme **K-means implémenté manuellement**
- Fichier **CSV** pour les données
- GitHub pour le versioning

---

## 📁 Structure du projet
healthcluster/
├── screenshots/
├── assets/
│ └── patients.csv
│
├── lib/
│ ├── main.dart
│ ├── kmeans.dart
│ ├── patient.dart
│ └── cluster_service.dart
│ └── clusters_tab.dart
│ └── results_tab.dart
├── pubspec.yaml
└── README.md

## Démonstration
Des captures d’écran de l’application sont disponibles numérotés dans le dossier :
/screenshots

Elles montrent :

+l’écran d’accueil

+l’import du fichier CSV

+le résultat de la prédiction

