import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/compression_level.dart';

class CompressionService {
  Future<File> compressPdf({
    required File inputFile,
    required CompressionLevel level,
    required Function(double) onProgress,
  }) async {
    try {
      onProgress(0.1);

      // Read the original PDF
      final bytes = await inputFile.readAsBytes();
      final document = await PdfDocument.openData(bytes);

      onProgress(0.3);

      // Create new PDF with compression
      final pdf = pw.Document();
      final pageCount = document.pagesCount;

      for (int i = 0; i < pageCount; i++) {
        onProgress(0.3 + (0.5 * (i / pageCount)));

        // Rasterize page
        final page = await document.getPage(i + 1);
        final pageImage = await page.render(
          width: (page.width * level.imageScale).toInt(),
          height: (page.height * level.imageScale).toInt(),
          format: PdfPageImageFormat.jpeg,
          backgroundColor: '#FFFFFF',
          quality: level.quality,
        );

        if (pageImage != null) {
          final image = pw.MemoryImage(pageImage.bytes);

          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat(
                page.width,
                page.height,
              ),
              build: (context) => pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
            ),
          );
        }

        await page.close();
      }

      await document.close();

      onProgress(0.9);

      // Save compressed PDF
      final output = await _getOutputFile(inputFile, level);
      final compressedBytes = await pdf.save();
      await output.writeAsBytes(compressedBytes);

      onProgress(1.0);

      return output;
    } catch (e) {
      if (kDebugMode) {
        print('Compression error: $e');
      }
      rethrow;
    }
  }

  Future<File> _getOutputFile(File inputFile, CompressionLevel level) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final originalName = inputFile.path.split('/').last.replaceAll('.pdf', '');
    final newFileName = '${originalName}_compressed_${level.name}_$timestamp.pdf';
    
    return File('${directory.path}/$newFileName');
  }

  Future<int> getFileSize(File file) async {
    return await file.length();
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
