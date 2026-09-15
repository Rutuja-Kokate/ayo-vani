import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/english_activities_data.dart';

/// Service that generates a printable PDF worksheet for a given chapter.
class WorksheetPdfService {
  /// Generates a PDF and saves it, then shares via system sheet.
  static Future<File> generateAndDownload({
    required String chapterName,
    required String className,
    required List<EnglishMundariWord> words,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => _buildHeader(chapterName, className, context),
        build: (context) => [
          pw.SizedBox(height: 12),
          _nameDate(),
          pw.SizedBox(height: 20),
          _sectionTitle('Exercise 1: Trace & Write the Words'),
          pw.SizedBox(height: 8),
          _tracingSection(words),
          pw.SizedBox(height: 24),
          _sectionTitle('Exercise 2: Vocabulary Table'),
          pw.SizedBox(height: 8),
          _vocabularyTable(words),
          pw.SizedBox(height: 24),
          _sectionTitle('Exercise 3: Match the Word to its Meaning'),
          pw.SizedBox(height: 8),
          _matchingSection(words),
          pw.SizedBox(height: 24),
          _sectionTitle('Exercise 4: Fill in the Blanks'),
          pw.SizedBox(height: 8),
          _fillInTheBlanks(words),
          pw.SizedBox(height: 24),
          _footer(),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final safeChapterName = chapterName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final file = File('${dir.path}/${safeChapterName}_Worksheet.pdf');
    await file.writeAsBytes(await pdf.save());
    debugPrint('[PDF] Saved worksheet to ${file.path}');
    return file;
  }

  /// Opens the system print/share dialog.
  static Future<void> printOrShare({
    required String chapterName,
    required String className,
    required List<EnglishMundariWord> words,
  }) async {
    final file = await generateAndDownload(
        chapterName: chapterName, className: className, words: words);
    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: '${chapterName.replaceAll(' ', '_')}_Worksheet.pdf',
    );
  }

  // PDF Widgets

  static pw.Widget _buildHeader(
      String chapterName, String className, pw.Context context) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.brown700, width: 2)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('AYOVAANI',
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.brown800)),
              pw.Text('Class $className  |  English Worksheet',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(chapterName,
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.brown700)),
              pw.Text('Page ${context.pageNumber} / ${context.pagesCount}',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _nameDate() {
    return pw.Row(children: [
      _labeledLine('Name', 190),
      pw.SizedBox(width: 20),
      _labeledLine('Date', 110),
      pw.SizedBox(width: 20),
      _labeledLine('Roll No.', 70),
    ]);
  }

  static pw.Widget _labeledLine(String label, double width) {
    return pw.Row(children: [
      pw.Text('$label: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
      pw.Container(
        width: width,
        height: 16,
        decoration: const pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey600))),
      ),
    ]);
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.brown100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.brown800)),
    );
  }

  static pw.Widget _tracingSection(List<EnglishMundariWord> words) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: words.take(6).map((w) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          child: pw.Row(children: [
            pw.SizedBox(
              width: 110,
              child: pw.Text(w.english,
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey400)),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                  _dottedLine(),
                  pw.SizedBox(height: 8),
                  _dottedLine(),
                ])),
          ]),
        );
      }).toList(),
    );
  }

  static pw.Widget _dottedLine() {
    return pw.Container(
      height: 1,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(
                color: PdfColors.grey400,
                style: pw.BorderStyle.dashed)),
      ),
    );
  }

  static pw.Widget _vocabularyTable(List<EnglishMundariWord> words) {
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'English', 'Mundari (Roman)', 'Mundari (Devnagri)', 'Meaning'],
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
          color: PdfColors.white),
      headerDecoration:
          const pw.BoxDecoration(color: PdfColors.brown700),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding:
          const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.brown50),
      data: words.asMap().entries.map((entry) {
        final i = entry.key;
        final w = entry.value;
        return [
          '${i + 1}',
          w.english,
          w.mundariRoman,
          w.mundariDevanagari,
          w.meaning,
        ];
      }).toList(),
    );
  }

  static pw.Widget _matchingSection(List<EnglishMundariWord> words) {
    final half = (words.length / 2).ceil();
    final left = words.take(half).toList();
    final right = List<EnglishMundariWord>.from(words.take(half))
      ..shuffle();

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: left.asMap().entries.map((e) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Text('${e.key + 1}.  ${e.value.english}',
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold)),
              );
            }).toList(),
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: right.asMap().entries.map((e) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Text(
                    '${String.fromCharCode(65 + e.key)}.  ${e.value.meaning}',
                    style: const pw.TextStyle(fontSize: 11)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  static pw.Widget _fillInTheBlanks(List<EnglishMundariWord> words) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: words.take(5).toList().asMap().entries.map((entry) {
        final i = entry.key + 1;
        final w = entry.value;
        final blanks = '_' * w.english.length;
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5),
          child: pw.Text(
              '$i.  The English word for "${w.meaning}" is: $blanks',
              style: const pw.TextStyle(fontSize: 11)),
        );
      }).toList(),
    );
  }

  static pw.Widget _footer() {
    return pw.Container(
      decoration: const pw.BoxDecoration(
          border: pw.Border(
              top: pw.BorderSide(color: PdfColors.brown200))),
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        'AYOVAANI – Empowering Tribal Education | Generated by AyoVaani App',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
