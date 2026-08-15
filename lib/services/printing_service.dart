import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';

class PrintingService {
  Future<void> printReceipt(OrderModel order) async {
    final doc = pw.Document();

    // Load Arabic font from Google Fonts
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Thermal printer 80mm
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('صيدلية Clincee', style: pw.TextStyle(font: fontBold, fontSize: 16)),
                ),
                pw.Divider(),
                pw.Text('رقم الطلب: ${order.orderId.substring(0, 8)}', style: pw.TextStyle(font: font)),
                pw.Text('التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)}', style: pw.TextStyle(font: font)),
                pw.Divider(),
                ...order.items.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text('${item['quantity']}x ${item['name']}', style: pw.TextStyle(font: font, fontSize: 10))),
                        pw.Text('${((item['price'] ?? 0) * (item['quantity'] ?? 0)).toStringAsFixed(2)} ج.م', style: pw.TextStyle(font: font, fontSize: 10)),
                      ],
                    ),
                  );
                }),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('الإجمالي:', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    pw.Text('${order.totalAmount.toStringAsFixed(2)} ج.م', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text('شكراً لزيارتكم!', style: pw.TextStyle(font: font, fontSize: 10)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }
}
