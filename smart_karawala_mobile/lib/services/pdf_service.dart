import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateReport({
    required String batchId,
    required String fishType,
    required String date,
    required double rawWeight,
    required double waste,
    required String status,
  }) async {
    final pdf = pw.Document();

    final cleanWeight = rawWeight - waste;
    final wastePercentage = (waste / rawWeight) * 100;

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.blue800,
                width: 2,
              ),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [

                  //------------------------------------------------------
                  // Header
                  //------------------------------------------------------

                  pw.Container(
                    width: double.infinity,
                    color: PdfColors.blue800,
                    padding: const pw.EdgeInsets.all(15),
                    child: pw.Column(
                      children: [

                        pw.Text(
                          "SMART KARAWALA",
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.SizedBox(height: 5),

                        pw.Text(
                          "Batch Processing Report",
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 25),

                  //------------------------------------------------------
                  // Batch Information
                  //------------------------------------------------------

                  sectionTitle("Batch Information"),

                  infoRow("Batch ID", batchId),
                  infoRow("Fish Type", fishType),
                  infoRow("Processing Date", date),
                  infoRow("Status", status),

                  pw.SizedBox(height: 20),

                  //------------------------------------------------------
                  // Weight Summary
                  //------------------------------------------------------

                  sectionTitle("Weight Summary"),

                  infoRow(
                    "Raw Weight",
                    "${rawWeight.toStringAsFixed(1)} kg",
                  ),

                  infoRow(
                    "Predicted Waste",
                    "${waste.toStringAsFixed(1)} kg",
                  ),

                  infoRow(
                    "Clean Weight",
                    "${cleanWeight.toStringAsFixed(1)} kg",
                  ),

                  infoRow(
                    "Waste Percentage",
                    "${wastePercentage.toStringAsFixed(1)} %",
                  ),

                  pw.SizedBox(height: 20),

                  //------------------------------------------------------
                  // Prediction
                  //------------------------------------------------------

                  sectionTitle("Prediction Summary"),

                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      border: pw.Border.all(
                        color: PdfColors.grey400,
                      ),
                    ),
                    child: pw.Text(
                      "This report summarizes the predicted waste "
                      "generated during the dry fish processing stage. "
                      "The prediction assists producers in monitoring "
                      "processing efficiency and improving waste utilization.",
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ),

                  pw.Spacer(),

                  //------------------------------------------------------
                  // Footer
                  //------------------------------------------------------

                  pw.Divider(),

                  pw.Center(
                    child: pw.Column(
                      children: [

                        pw.Text(
                          "Generated by Smart Karawala",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),

                        pw.SizedBox(height: 5),

                        pw.Text(
                          "AI-powered Dry Fish Processing Management System",
                          style: const pw.TextStyle(fontSize: 10),
                        ),

                        pw.SizedBox(height: 5),

                        pw.Text(
                          "© 2026 Smart Karawala",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  //------------------------------------------------------
  // Helper Widgets
  //------------------------------------------------------

  static pw.Widget sectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      color: PdfColors.blue100,
      padding: const pw.EdgeInsets.all(8),
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
          fontSize: 14,
        ),
      ),
    );
  }

  static pw.Widget infoRow(
    String title,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [

          pw.Expanded(
            flex: 2,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.Text(":  "),

          pw.Expanded(
            flex: 3,
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }
}