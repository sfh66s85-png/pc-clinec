import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<void> generateSalesReport({
    required List<OrderModel> orders,
    required DateTime startDate,
    required DateTime endDate,
    required double totalSales,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('تقرير مبيعات Clincee', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('الفترة: من ${DateFormat('yyyy-MM-dd').format(startDate)} إلى ${DateFormat('yyyy-MM-dd').format(endDate)}'),
          pw.SizedBox(height: 10),
          pw.Text('إجمالي المبيعات: ${totalSales.toStringAsFixed(2)} ج.م', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['رقم الطلب', 'العميل', 'التاريخ', 'طريقة الدفع', 'المبلغ'],
            data: orders.map((order) => [
              order.orderId.substring(0, 8),
              order.customerName,
              DateFormat('yyyy-MM-dd').format(order.createdAt),
              order.paymentMethod,
              '${order.totalAmount.toStringAsFixed(2)} ج.م'
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerRight,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
