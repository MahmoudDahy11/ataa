class BeneficiaryStatus {
  BeneficiaryStatus._();

  static const pendingReview = 'pending_review';
  static const approved = 'approved';
  static const rejected = 'rejected';
}

class CaseLifecycle {
  CaseLifecycle._();

  static const draft = 'draft';
  static const pendingReview = 'pending_review';
  static const collecting = 'collecting';
  static const completed = 'completed';
  static const paid = 'paid';
}

class DonationStatus {
  DonationStatus._();

  static const pending = 'pending';
  static const success = 'success';
  static const failed = 'failed';
}

class AllowedUploadTypes {
  AllowedUploadTypes._();

  static const imageJpeg = 'image/jpeg';
  static const imagePng = 'image/png';
  static const pdf = 'application/pdf';

  static const all = <String>[imageJpeg, imagePng, pdf];
}

class IncomeStatusOption {
  IncomeStatusOption._();

  static const none = 'none';
  static const low = 'low';
  static const middle = 'middle';

  static const all = <String>[none, low, middle];
}

class HealthConditionOption {
  HealthConditionOption._();

  static const healthy = 'healthy';
  static const chronic = 'chronic';
  static const disability = 'disability';

  static const all = <String>[healthy, chronic, disability];
}

class PayoutMethodOption {
  PayoutMethodOption._();

  static const vodafoneCash = 'vodafone_cash';
  static const bank = 'bank';

  static const all = <String>[vodafoneCash, bank];
}

class RequiredDocumentType {
  RequiredDocumentType._();

  static const idCard = 'id_card';
  static const medicalReport = 'medical_report';
  static const debtProof = 'debt_proof';

  static const all = <String>[idCard, medicalReport, debtProof];

  static const labels = <String, String>{
    idCard: 'ID Card',
    medicalReport: 'Medical Report',
    debtProof: 'Debt Proof',
  };
}

class BeneficiaryOptions {
  BeneficiaryOptions._();

  static const governorates = <String>[
    'Cairo',
    'Giza',
    'Alexandria',
    'Dakahlia',
    'Red Sea',
    'Beheira',
    'Fayoum',
    'Gharbia',
    'Ismailia',
    'Menofia',
    'Minya',
    'Qalyubia',
    'New Valley',
    'Suez',
    'Aswan',
    'Assiut',
    'Beni Suef',
    'Port Said',
    'Damietta',
    'Sharkia',
    'South Sinai',
    'Kafr El Sheikh',
    'Matrouh',
    'Luxor',
    'Qena',
    'North Sinai',
    'Sohag',
  ];

  static const citiesByGovernorate = <String, List<String>>{
    'Cairo': ['Nasr City', 'Heliopolis', 'Maadi', 'Shubra', 'New Cairo'],
    'Giza': ['Dokki', 'Mohandessin', '6th of October', 'Haram', 'Sheikh Zayed'],
    'Alexandria': ['Smouha', 'Sidi Gaber', 'Miami', 'Agami', 'Mandara'],
    'Dakahlia': ['Mansoura', 'Talkha', 'Mit Ghamr'],
    'Beheira': ['Damanhur', 'Kafr El Dawwar', 'Rashid'],
    'Menofia': ['Shibin El Kom', 'Sadat City', 'Ashmoun'],
  };

  static const bankNames = <String>[
    'Banque Misr',
    'National Bank of Egypt',
    'CIB',
    'AlexBank',
    'QNB Al Ahli',
    'Faisal Islamic Bank',
  ];
}
