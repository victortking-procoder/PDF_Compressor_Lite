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
      
      onProgress(0.3);

      // Create new PDF with compression
      final pdf = pw.Document(compress: true);
      
      int pageIndex = 0;
      
      // Rasterize each page
      await for (final page in Printing.raster(
        bytes,
        dpi: level.quality.toDouble(), // Use quality as DPI
      )) {
        onProgress(0.3 + (0.5 * (pageIndex / 10))); // Estimate progress

        // Convert page to PNG with compression
        final pageImage = await page.toPng();

        final image = pw.MemoryImage(pageImage);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              page.width.toDouble(),
              page.height.toDouble(),
            ),
            build: (context) => pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        );
        
        pageIndex++;
      }

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
