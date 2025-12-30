import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ReceiptScannerService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<File?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return null;
    return File(image.path);
  }

  Future<Map<String, dynamic>> scanReceipt(File image) async {
    final inputImage = InputImage.fromFile(image);
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);
    return _parseReceiptData(recognizedText.text);
  }

  Map<String, dynamic> _parseReceiptData(String text) {
    Map<String, dynamic> data = {
      'amount': null,
      'date': null,
      'description': null,
    };

    final lines = text.split('\n');

    // 1. Find Amount
    // Improved logic to handle thousands separators (e.g. 1.000.000 or 1,000,000)
    // and currency symbols (Rp).
    double? maxAmount;

    // Regex matches:
    // 1. Numbers with thousands separators (dot or comma) and optional 2-decimal fraction
    //    e.g. 100.000 | 100,000 | 100.000,00 | 100,000.00
    // 2. Simple numbers e.g. 10000
    // We filter out date-like numbers later (e.g. 2021) if they are small, but for maxAmount it's fine.

    // This regex looks for:
    // - One or more digits
    // - Optional groups of ([.,] followed by 3 digits) -> Thousands
    // - Optional group of ([.,] followed by 2 digits) -> Decimals
    final amountRegex = RegExp(r'\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?');

    for (var line in lines) {
      // Filter out likely phone numbers or dates if possible, but simplest is to just parse all numbers
      // and pick the largest one that looks like a valid amount.

      // Clean line of currency symbols to avoid confusion
      String cleanLine = line.replaceAll(RegExp(r'[Rp$]'), '').trim();
      if (cleanLine.isEmpty) continue;

      final matches = amountRegex.allMatches(cleanLine);
      for (var match in matches) {
        String rawNum = match.group(0)!;

        // Heuristic to parse "100.000" vs "100.00"
        // If it has 3 digits at the end after separator, it's likely a thousands separator -> remove it.
        // If it has 2 digits, it's likely a decimal separator -> replace with dot.

        String numStr = rawNum;

        if (rawNum.contains('.') || rawNum.contains(',')) {
          // Find the last separator
          int lastSepIndex = rawNum.lastIndexOf(RegExp(r'[.,]'));
          String suffix = rawNum.substring(lastSepIndex + 1);

          if (suffix.length == 3) {
            // Likely 3 digits (thousands) -> Remove all separators to get integerish value
            // e.g. 567,600 -> 567600
            numStr = rawNum.replaceAll(RegExp(r'[.,]'), '');
          } else if (suffix.length == 2) {
            // Likely 2 digits (cents) -> Normalize separator to dot, remove others
            // e.g. 10,000.50 -> remove comma, keep dot
            // e.g. 10.000,50 -> remove dot, replace comma with dot

            String sep = rawNum[lastSepIndex];
            String prefix = rawNum
                .substring(0, lastSepIndex)
                .replaceAll(RegExp(r'[.,]'), '');
            numStr = '$prefix.$suffix';
          }
        }

        double? amount = double.tryParse(numStr);
        if (amount != null) {
          // Heuristic: Sanity check. Ignore amounts that look like years (e.g. 2023) if we found bigger ones?
          // For now just taking max is usually safe for Receipts (Grand Total is usually the biggest number).
          if (maxAmount == null || amount > maxAmount) {
            maxAmount = amount;
          }
        }
      }
    }
    data['amount'] = maxAmount;

    // 2. Find Date
    // Common formats: dd/MM/yyyy, yyyy-MM-dd, dd-MM-yyyy, dd MMM yyyy
    final dateRegex1 =
        RegExp(r'\d{2}[/-]\d{2}[/-]\d{4}'); // dd/MM/yyyy or dd-MM-yyyy
    final dateRegex2 = RegExp(r'\d{4}[/-]\d{2}[/-]\d{2}'); // yyyy-MM-dd
    final dateRegex3 = RegExp(
        r'\b\d{2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4}',
        caseSensitive: false);

    for (var line in lines) {
      if (data['date'] != null) break;

      var match = dateRegex1.firstMatch(line);
      if (match != null) {
        data['date'] = match.group(0)!.replaceAll('-', '/');
      }

      if (data['date'] == null) {
        match = dateRegex2.firstMatch(line);
        if (match != null) {
          try {
            DateTime dt = DateTime.parse(match.group(0)!);
            data['date'] = DateFormat('dd/MM/yyyy').format(dt);
          } catch (_) {}
        }
      }

      if (data['date'] == null) {
        match = dateRegex3.firstMatch(line);
        if (match != null) {
          // Try to parse "25 Dec 2023"
          try {
            // Need a parser that understands locale or standard English months
            // DateFormat("dd MMM yyyy") generally works for English
            DateTime dt = DateFormat("dd MMM yyyy").parse(match.group(0)!);
            data['date'] = DateFormat('dd/MM/yyyy').format(dt);
          } catch (_) {}
        }
      }
    }

    // 3. Find Description (Merchant Name)
    // Skip lines that are likely headers or noise.
    // Heuristic:
    // - Skip short lines (< 3 chars)
    // - Skip lines with "Nomor", "Date", "Total", "Telp"
    // - Take the first remaining line as Merchant

    for (var line in lines) {
      String t = line.trim();
      if (t.length < 3) continue;
      String lower = t.toLowerCase();
      if (lower.contains('nomor') ||
          lower.contains('date') ||
          lower.contains('total') ||
          lower.contains('time') ||
          lower.contains('jam')) continue;

      // Also skip purely numeric lines
      if (RegExp(r'^\d+$').hasMatch(t)) continue;

      data['description'] = t;
      break;
    }

    return data;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
