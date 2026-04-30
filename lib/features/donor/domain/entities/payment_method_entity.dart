enum PaymentType { visa, vodafoneCash }

class PaymentMethodEntity {
  final PaymentType type;
  final String? vodafoneNumber;
  final String? cardToken;

  const PaymentMethodEntity({
    required this.type,
    this.vodafoneNumber,
    this.cardToken,
  });

  bool get isVodafoneCash => type == PaymentType.vodafoneCash;
  bool get isVisa => type == PaymentType.visa;

  String get displayName {
    switch (type) {
      case PaymentType.visa:
        return 'بطاقة بنكية';
      case PaymentType.vodafoneCash:
        return 'فودافون كاش';
    }
  }
}
