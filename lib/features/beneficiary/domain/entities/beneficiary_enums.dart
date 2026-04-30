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

  static const all = <String>[idCard];

  static const labels = <String, String>{
    idCard: 'بطاقة الرقم القومي',
    medicalReport: 'تقرير طبي',
    debtProof: 'إثبات مديونية',
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
    'Sharqia',
    'South Sinai',
    'Kafr El Sheikh',
    'Matrouh',
    'Luxor',
    'Qena',
    'North Sinai',
    'Sohag',
  ];

  static const citiesByGovernorate = <String, List<String>>{
    'Cairo': [
      'Nasr City',
      'Heliopolis',
      'Maadi',
      'Shubra',
      'New Cairo',
      'El Marg',
      'Ain Shams',
      'Helwan',
      '15 May City',
      'Badr City',
    ],
    'Giza': [
      'Dokki',
      'Mohandessin',
      '6th of October',
      'Haram',
      'Sheikh Zayed',
      'Faisal',
      'Imbaba',
      'Bulaq Dakrour',
      'Badrasheen',
      'Ossim',
    ],
    'Alexandria': [
      'Smouha',
      'Sidi Gaber',
      'Miami',
      'Agami',
      'Mandara',
      'Stanley',
      'Borg El Arab',
      'Dekheila',
      'Raml Station',
    ],
    'Dakahlia': [
      'Mansoura',
      'Talkha',
      'Mit Ghamr',
      'Belqas',
      'Dekernes',
      'Sherbin',
      'Aga',
      'Minyet El Nasr',
    ],
    'Beheira': [
      'Damanhur',
      'Kafr El Dawwar',
      'Rashid',
      'Edku',
      'Abu Hummus',
      'Delengat',
      'Kom Hamada',
    ],
    'Menofia': [
      'Shibin El Kom',
      'Sadat City',
      'Ashmoun',
      'Menouf',
      'Quesna',
      'Berket El Sab',
    ],
    'Sharqia': [
      'Zagazig',
      '10th of Ramadan',
      'Belbeis',
      'Minya El Qamh',
      'Abu Hammad',
      'Faqous',
    ],
    'Qalyubia': [
      'Banha',
      'Qalyub',
      'Shubra El Kheima',
      'Khanka',
      'Toukh',
      'Obour City',
    ],
    'Kafr El Sheikh': [
      'Kafr El Sheikh',
      'Desouk',
      'Baltim',
      'Metoubes',
      'Sidi Salem',
      'Fouh',
    ],
    'Gharbia': [
      'Tanta',
      'El Mahalla El Kubra',
      'Kafr El Zayat',
      'Zefta',
      'Basyoun',
    ],
    'Port Said': ['Port Said', 'Port Fouad'],
    'Ismailia': ['Ismailia', 'Fayed', 'Qantara East', 'Qantara West'],
    'Suez': ['Suez', 'Ain Sokhna'],
    'Damietta': ['Damietta', 'New Damietta', 'Faraskur', 'Kafr Saad'],
    'Matrouh': ['Marsa Matrouh', 'El Alamein', 'Siwa'],
    'North Sinai': ['Arish', 'Sheikh Zuweid', 'Rafah'],
    'South Sinai': ['Sharm El Sheikh', 'Dahab', 'Nuweiba', 'Taba', 'Tor Sinai'],
    'Beni Suef': ['Beni Suef', 'El Fashn', 'Samasta'],
    'Fayoum': ['Fayoum', 'Ibshway', 'Tamiya', 'Yusuf El Seddik'],
    'Minya': ['Minya', 'Mallawi', 'Beni Mazar', 'Maghagha'],
    'Assiut': ['Assiut', 'Dairut', 'Manfalut', 'Abnoub'],
    'Sohag': ['Sohag', 'Akhmim', 'Girga', 'Tahta'],
    'Qena': ['Qena', 'Nag Hammadi', 'Qus'],
    'Luxor': ['Luxor', 'Esna', 'Armant'],
    'Aswan': ['Aswan', 'Kom Ombo', 'Edfu'],
    'Red Sea': ['Hurghada', 'Safaga', 'Marsa Alam', 'El Quseir'],
    'New Valley': ['Kharga', 'Dakhla', 'Farafra'],
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
