import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/sms_import/data/sms_parser.dart';
import 'package:smart_expense/features/sms_import/domain/models/parsed_sms_result.dart';

void main() {
  const parser = SmsParser();

  group('SmsParser Tests', () {
    test('1. Vodafone Cash Incoming 35000', () {
      const sms = '''
تم استلام مبلغ 35000.00 جنيه من 01100404969؛
المسجل بإسم خالد ابراهيم مبارك عبد المتعال حجاج
على رقم محفظتك 01069163385 بتاريخ 17:03 26-09-13.
رصيدك الحالي: 35104.21 جنيه
رقم العملية: 023669021826
''';

      final result = parser.parse(sms);

      expect(result.status, SmsParsingStatus.parsed);
      expect(result.providerType, ProviderType.vodafoneCash);
      expect(result.operationType, OperationType.deposit);
      expect(result.amount, 35000.00);
      expect(result.phoneNumber, '01100404969');
      expect(result.partyName, 'خالد ابراهيم مبارك عبد المتعال حجاج');
      expect(result.myWalletPhone, '01069163385');
      expect(result.referenceNumber, '023669021826');
      expect(result.balance, 35104.21);
      expect(result.transactionDateTime, DateTime(2026, 9, 13, 17, 3));
    });

    test('2. Vodafone Cash Outgoing 5000', () {
      const sms = '''
تم تحويل 5000 جنيه لرقم 01037192909 مصاريف الخدمة 1 جنيه
رصيد حسابك فى فودافون كاش الحالي 24.71.
تاريخ العملية 22:56 26-09-13 :
رقم العملية 023682228634
''';

      final result = parser.parse(sms);

      expect(result.status, SmsParsingStatus.parsed);
      expect(result.providerType, ProviderType.vodafoneCash);
      expect(result.operationType, OperationType.withdrawal);
      expect(result.amount, 5000.0);
      expect(result.phoneNumber, '01037192909');
      expect(result.networkFee, 1.0);
      expect(result.balance, 24.71);
      expect(result.referenceNumber, '023682228634');
      expect(result.transactionDateTime, DateTime(2026, 9, 13, 22, 56));
    });

    test('3. InstaPay Incoming 100', () {
      const sms = '''
تم إضافة تحويل لحظي لبطاقتكم مسبقة الدفع بمبلغ 100.00 جم
من احمد محمد عبدالحميد محمد
رقم مرجعي 480397057893
يوم 07-28 الساعة 20:24
للمزيد اتصل بـ 19623
''';

      final fallbackReceived = DateTime(2026, 7, 28, 20, 25);
      final result = parser.parse(sms, receivedAt: fallbackReceived);

      expect(result.status, SmsParsingStatus.parsed);
      expect(result.providerType, ProviderType.instaPay);
      expect(result.operationType, OperationType.deposit);
      expect(result.amount, 100.00);
      expect(result.partyName, 'احمد محمد عبدالحميد محمد');
      expect(result.referenceNumber, '480397057893');
      expect(result.transactionDateTime?.month, 7);
      expect(result.transactionDateTime?.day, 28);
      expect(result.transactionDateTime?.hour, 20);
      expect(result.transactionDateTime?.minute, 24);
    });

    test('4. InstaPay Outgoing 200', () {
      const sms = '''
تم تنفيذ تحويل لحظي من بطاقتكم مسبقة الدفع بمبلغ 200.00 جم
إلى MOHAMED E**** H****
رقم مرجعي 886170697508
يوم 07-25 الساعة 00:17
للمزيد اتصل بـ 19623
''';

      final fallbackReceived = DateTime(2026, 7, 25, 0, 20);
      final result = parser.parse(sms, receivedAt: fallbackReceived);

      expect(result.status, SmsParsingStatus.parsed);
      expect(result.providerType, ProviderType.instaPay);
      expect(result.operationType, OperationType.withdrawal);
      expect(result.amount, 200.00);
      expect(result.partyName, 'MOHAMED E**** H****');
      expect(result.referenceNumber, '886170697508');
      expect(result.transactionDateTime?.month, 7);
      expect(result.transactionDateTime?.day, 25);
      expect(result.transactionDateTime?.hour, 0);
      expect(result.transactionDateTime?.minute, 17);
    });

    test('Unknown SMS is ignored', () {
      const sms = 'عزيزي العميل، تم تجديد باقة سوبر بلس الشهرية بنجاح.';
      final result = parser.parse(sms);

      expect(result.status, SmsParsingStatus.ignored);
      expect(result.isSuccessful, false);
    });

    test('Malformed SMS fails gracefully without crashing', () {
      const sms = 'تم استلام مبلغ من شخص مجهول بدون رقم';
      final result = parser.parse(sms);

      expect(result.status, SmsParsingStatus.failed);
      expect(result.isSuccessful, false);
    });

    test('Duplicate reference numbers are identical across identical messages', () {
      const sms1 = '''
تم استلام مبلغ 35000.00 جنيه من 01100404969؛
المسجل بإسم خالد ابراهيم مبارك عبد المتعال حجاج
على رقم محفظتك 01069163385 بتاريخ 17:03 26-09-13.
رصيدك الحالي: 35104.21 جنيه
رقم العملية: 023669021826
''';

      const sms2 = '''
تم استلام مبلغ 35000.00 جنيه من 01100404969؛
المسجل بإسم خالد ابراهيم مبارك عبد المتعال حجاج
على رقم محفظتك 01069163385 بتاريخ 17:03 26-09-13.
رصيدك الحالي: 35104.21 جنيه
رقم العملية: 023669021826
''';

      final res1 = parser.parse(sms1);
      final res2 = parser.parse(sms2);

      expect(res1.referenceNumber, isNotNull);
      expect(res1.referenceNumber, equals(res2.referenceNumber));
      expect(res1.referenceNumber, '023669021826');
    });
  });
}
