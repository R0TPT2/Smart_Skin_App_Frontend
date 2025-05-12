// dummy_data.dart

// Existing recentPatients list (unchanged)
final List<Map<String, dynamic>> recentPatients = [
  {
    'avatar': 'assests/hammad.jpg',
    'name': 'Jefika Sabnnam',
    'prediction': 'Malignant',
    'scanImage': 'assests/sk_1.jpeg',
    'medicalHistory': {
      'currentMedicalConditions': 'None',
      'allergies': 'No known allergies',
      'pastSurgeriesOrHospitalizations': 'Appendectomy in 2015',
      'familyMedicalHistory': 'Diabetes runs in family',
      'currentMedications': 'Vitamin D supplements',
    },
    'dateOfResult': 'January 01, 2024', // Static date
    'phoneNumber': '+1234567890',
  },
  {
    'avatar': 'assests/hammad.jpg',
    'name': 'Tomas Mudar',
    'prediction': 'Benign',
    'scanImage': 'assests/sk_1.jpeg',
    'medicalHistory': {
      'currentMedicalConditions': 'Hypertension',
      'allergies': 'Pollen allergy',
      'pastSurgeriesOrHospitalizations': 'None',
      'familyMedicalHistory': 'Heart disease runs in family',
      'currentMedications': 'Blood pressure medication',
    },
    'dateOfResult': 'January 02, 2024', // Static date
    'phoneNumber': '+0987654321',
  },
  {
    'avatar': 'assests/hammad.jpg',
    'name': 'William Coster',
    'prediction': 'Undetermined',
    'scanImage': 'assests/sk_1.jpeg',
    'medicalHistory': {
      'currentMedicalConditions': 'Asthma',
      'allergies': 'Penicillin allergy',
      'pastSurgeriesOrHospitalizations': 'Tonsillectomy in 2010',
      'familyMedicalHistory': 'Cancer runs in family',
      'currentMedications': 'Inhaler',
    },
    'dateOfResult': 'January 03, 2024', // Static date
    'phoneNumber': '+9876543210',
  },
];

// New appointedPatients list
final List<Map<String, dynamic>> appointedPatients = [
  {
    'avatar': 'assests/hammad.jpg',
    'name': 'Alice Johnson',
    'prediction': 'Malignant',
    'scanImage': 'assests/sk_1.jpeg',
    'medicalHistory': {
      'currentMedicalConditions': 'None',
      'allergies': 'No known allergies',
      'pastSurgeriesOrHospitalizations': 'None',
      'familyMedicalHistory': 'None',
      'currentMedications': 'None',
    },
    'dateOfResult': _getFormattedDate(DateTime.now()), // Today's date
    'phoneNumber': '+1111111111',
  },
  {
    'avatar': 'assests/hammad.jpg',
    'name': 'Bob Smith',
    'prediction': 'Benign',
    'scanImage': 'assests/sk_1.jpeg',
    'medicalHistory': {
      'currentMedicalConditions': 'Hypertension',
      'allergies': 'Pollen allergy',
      'pastSurgeriesOrHospitalizations': 'None',
      'familyMedicalHistory': 'Heart disease runs in family',
      'currentMedications': 'Blood pressure medication',
    },
    'dateOfResult': _getFormattedDate(DateTime.now().add(Duration(days: 1))), // Tomorrow's date
    'phoneNumber': '+2222222222',
  },
  {
    'avatar': 'assests/hammad.jpg',
    'name': 'Charlie Brown',
    'prediction': 'Undetermined',
    'scanImage': 'assests/sk_1.jpeg',
    'medicalHistory': {
      'currentMedicalConditions': 'Asthma',
      'allergies': 'Penicillin allergy',
      'pastSurgeriesOrHospitalizations': 'Tonsillectomy in 2010',
      'familyMedicalHistory': 'Cancer runs in family',
      'currentMedications': 'Inhaler',
    },
    'dateOfResult': _getFormattedDate(DateTime.now().add(Duration(days: 2))), // Day after tomorrow
    'phoneNumber': '+3333333333',
  },
];

// Helper function to format date as "Month DD"
String _getFormattedDate(DateTime date) {
  final monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return '${monthNames[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
}