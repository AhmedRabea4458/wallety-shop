import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/shift_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_stats.dart';

class ShiftPdfService {
  static const String _fontAsset = 'assets/fonts/NotoSansArabic-Regular.ttf';

  static Future<void> printShift({
    required ShiftEntity shift,
    required ShiftStats stats,
    required List<OperationEntity> operations,
  }) async {
    final font = await _loadArabicFont();
    if (font == null) {
      throw Exception(
        'Arabic font not found. Place NotoSansArabic-Regular.ttf '
        'at $_fontAsset, then restart the app.',
      );
    }
    final pdf = pw.Document();
    final theme = pw.ThemeData.withFont(base: font);

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'تقرير الوردية',
              style: pw.TextStyle(font: font, fontSize: 22, fontWeight: pw.FontWeight.bold),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              _dt(shift.startTime),
              style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.SizedBox(height: 24),
          _sectionTitle('معلومات الوردية', font),
          pw.SizedBox(height: 8),
          _infoTable(shift, stats, font),
          pw.SizedBox(height: 24),
          _sectionTitle('ملخص العمليات', font),
          pw.SizedBox(height: 8),
          _statsTable(stats, font),
          pw.SizedBox(height: 24),
          _sectionTitle('تفاصيل العمليات', font),
          pw.SizedBox(height: 8),
          if (operations.isEmpty)
            pw.Text(
              'لا توجد عمليات في هذه الوردية',
              style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600),
              textDirection: pw.TextDirection.rtl,
            )
          else
            _operationsTable(operations, font),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  static Future<pw.Font?> _loadArabicFont() async {
    try {
      final bytes = await rootBundle.load(_fontAsset);
      return pw.Font.ttf(bytes);
    } catch (e) {
      debugPrint('ShiftPdfService: failed to load font from $_fontAsset: $e');
      return null;
    }
  }

  static pw.Widget _sectionTitle(String title, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blueGrey800, width: 1)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(font: font, fontSize: 14, fontWeight: pw.FontWeight.bold),
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  static pw.Widget _infoTable(ShiftEntity shift, ShiftStats stats, pw.Font font) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        _tableRow('بداية الوردية', _dt(shift.startTime), font),
        if (shift.endTime != null) _tableRow('نهاية الوردية', _dt(shift.endTime!), font),
        _tableRow('رصيد البداية', '${_f(shift.openingCashDrawer)} ج.م', font),
        if (shift.closingCashDrawer != null)
          _tableRow('رصيد النهاية', '${_f(shift.closingCashDrawer!)} ج.م', font),
        _tableRow('إجمالي العمليات', stats.totalOperations.toString(), font),
      ],
    );
  }

  static pw.Widget _statsTable(ShiftStats stats, pw.Font font) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        _tableRow('إجمالي الإيداع', '${_f(stats.totalDeposits)} ج.م', font),
        _tableRow('إجمالي السحب', '${_f(stats.totalWithdrawals)} ج.م', font),
        _tableRow('إجمالي العمولات', '${_f(stats.totalCommissions)} ج.م', font),
        _tableRow('رسوم الشبكة', '${_f(stats.totalNetworkFees)} ج.م', font),
        _tableRow('صافي الربح', '${_f(stats.netProfit)} ج.م', font),
        _tableRow('عمليات InstaPay', stats.instaPayCount.toString(), font),
      ],
    );
  }

  static pw.Widget _operationsTable(List<OperationEntity> operations, pw.Font font) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
          children: [
            _cell('الوقت', font, isHeader: true),
            _cell('المزود', font, isHeader: true),
            _cell('النوع', font, isHeader: true),
            _cell('المبلغ', font, isHeader: true),
          ],
        ),
        ...operations.reversed.map((op) => pw.TableRow(
          children: [
            _cell(_time(op.createdAt), font),
            _cell(op.providerType.label, font),
            _cell(op.operationType == OperationType.deposit ? 'إيداع' : 'سحب', font),
            _cell('${_f(op.amount)} ج.م', font),
          ],
        )),
      ],
    );
  }

  static pw.TableRow _tableRow(String label, String value, pw.Font font) {
    return pw.TableRow(
      children: [
        pw.Expanded(
          flex: 2,
          child: _cell(label, font, isHeader: true),
        ),
        pw.Expanded(
          flex: 3,
          child: _cell(value, font),
        ),
      ],
    );
  }

  static pw.Widget _cell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.right,
      ),
    );
  }

  static String _f(double v) => NumberFormat('#,##0.##', 'ar').format(v);
  static String _dt(DateTime d) => DateFormat('yyyy/MM/dd  hh:mm a', 'ar').format(d);
  static String _time(DateTime d) => DateFormat('hh:mm a', 'ar').format(d);
}
