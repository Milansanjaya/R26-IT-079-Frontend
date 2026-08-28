import 'package:flutter/services.dart' show rootBundle;
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

    final logoData = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final cleanWeight = rawWeight - waste;
    final wastePercentage = (waste / rawWeight) * 100;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header Banner
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xff0C3F7A),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(
                          width: 40,
                          height: 40,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                          ),
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                        ),
                        pw.SizedBox(width: 14),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "SMART KARAWALA",
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "AI-powered Dry Fish Processing System",
                              style: const pw.TextStyle(
                                color: PdfColors.blue100,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xff03113F),
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Text(
                        "BATCH REPORT",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // 2. Metadata Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "PREPARED FOR:",
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey500,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Smart Karawala Processor Ltd.",
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "Sri Lanka",
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "REPORT METADATA:",
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey500,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Date: $date",
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        "Batch ID: $batchId",
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xff0C3F7A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 28),

              // 3. Earning / Weight Cards Row (like app cards)
              pw.Row(
                children: [
                  _buildStatCard("RAW WEIGHT", "${rawWeight.toStringAsFixed(1)} kg", const PdfColor.fromInt(0xff0C3F7A)),
                  pw.SizedBox(width: 12),
                  _buildStatCard("PREDICTED WASTE", "${waste.toStringAsFixed(1)} kg", PdfColors.orange800),
                  pw.SizedBox(width: 12),
                  _buildStatCard("CLEAN WEIGHT", "${cleanWeight.toStringAsFixed(1)} kg", PdfColors.green800),
                  pw.SizedBox(width: 12),
                  _buildStatCard("WASTE PERCENT", "${wastePercentage.toStringAsFixed(1)}%", PdfColors.red800),
                ],
              ),

              pw.SizedBox(height: 32),

              // 4. Batch Details List
              pw.Text(
                "BATCH SPECIFICATIONS",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xff0C3F7A),
                  letterSpacing: 0.5,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildDetailRow("Reference Identifier", batchId),
              _buildDetailRow("Fish Variety", fishType),
              _buildDetailRow("Processing Date", date),
              _buildDetailRow("Raw Stock Weight", "${rawWeight.toStringAsFixed(1)} kg"),
              _buildDetailRow("Calculated Waste Yield", "${waste.toStringAsFixed(1)} kg"),
              _buildDetailRow("Net Clean Yield", "${cleanWeight.toStringAsFixed(1)} kg"),
              _buildDetailRow("Current Status", status, isStatus: true),

              pw.SizedBox(height: 32),

              // 5. Prediction Callout Box (Left-bordered warning-style card)
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xffF4F8FC),
                  border: pw.Border(
                    left: pw.BorderSide(color: PdfColor.fromInt(0xff0C3F7A), width: 4),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "AI INSIGHTS & FORECAST SUMMARY",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xff0C3F7A),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      "The waste prediction model analyzes salting concentration levels, raw species weights, and drying hours to forecast batch yields. This estimate assists processing floor supervisors in minimizing waste and validating drying process margins.",
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.grey800,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // 6. Professional Footer
              pw.Divider(color: PdfColors.grey200, thickness: 1),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "© 2026 Smart Karawala System",
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                  ),
                  pw.Text(
                    "Generated via Smart Karawala Mobile Admin App",
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'batch_report_$batchId.pdf',
    );
  }

  // Helper: Card Generator
  static pw.Widget _buildStatCard(String title, String value, PdfColor valueColor) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xffF9FAFC),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: PdfColors.grey200, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: valueColor),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Detail Row Generator
  static pw.Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey100, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          isStatus
              ? pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: value.toLowerCase().contains("completed")
                        ? const PdfColor.fromInt(0xffE8F5E9)
                        : const PdfColor.fromInt(0xffFFF3E0),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    value,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: value.toLowerCase().contains("completed")
                          ? const PdfColor.fromInt(0xff2E7D32)
                          : const PdfColor.fromInt(0xffEF6C00),
                    ),
                  ),
                )
              : pw.Text(
                  value,
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xff0C3F7A)),
                ),
        ],
      ),
    );
  }
}