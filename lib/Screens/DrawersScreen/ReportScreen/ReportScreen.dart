import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../../../Constants/app_color.dart';
import '../../../Custom_Components/CustomLoadingAvatar.dart';
import '../../../Models/ExpensesItemModel.dart';
import '../../../Models/ItemCartModel.dart';
import '../../../services/LocalizationService.dart';
import '../../../api_services/CartService.dart';
import '../../../services/CheckConnectivity.dart';
import '../../../api_services/expenses_service.dart';
import '../../../Utils/date_helper.dart';
import '../../LoginScreen/Custom_Widgets/CustomFailedPopup.dart';
import '../CartHistoryScreen/widgets/CustomReportButton.dart';
import '../CartHistoryScreen/widgets/CustomTotalsSummaryArea.dart';
import 'widgets/CustomFilterArea.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportScreen extends StatefulWidget {
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  int totalExpenses = 0;
  int totalSales = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  void fetchReportData() async {
    try {
      print('Fetching report data...');
      final data = await CartService.fetchProfitValues(context);
      setState(() {
        totalExpenses = data['TotalExpenses'] ?? 0;
        totalSales = data['TotalProfit'] ?? 0;
        isLoading = false; // Data fetched, stop loading
      });
    } catch (e) {
      print('Error fetching report data: $e');
      setState(() {
        isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  Future<void> prepareSalesPDF(
      List<ItemCart> salesList, String dateFrom, String dateTo) async {
    print("Preparing sales PDF with ${salesList.length} items.");
    try {
      final font =
          pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));
      final pageWidth = PdfPageFormat.a4.availableWidth;

      // Create a PDF document
      final pdf = pw.Document();
      double totalSum = 0;
      double differenceSum = 0;
      double differenceColumn = 0;

      // Add a page to the document
      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) => [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl, // Force RTL for Arabic
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      "المبيعات",
                      style: pw.TextStyle(
                        fontSize: 36, // Bigger size
                        fontWeight: pw.FontWeight.bold, // Bold text
                        font: font,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),

                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Container(
                        width: pageWidth / 3,
                        alignment: pw.Alignment.topLeft,
                        child: pw.Text(
                            "تاريخ الكشف: ${DateTime.now().toString().split(' ')[0]}",
                            style: pw.TextStyle(fontSize: 12, font: font)),
                      ),
                      pw.Spacer(),
                      pw.Container(
                        width: pageWidth / 3,
                        alignment: pw.Alignment.topRight,
                        child: pw.Text("من تاريخ: $dateFrom",
                            style: pw.TextStyle(fontSize: 12, font: font)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        child: pw.Text("إلى تاريخ: $dateTo",
                            style: pw.TextStyle(fontSize: 12, font: font)),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  // Table Header with Borders
                  pw.Row(
                    children: [
                      _buildCell("المجموع", font, 2),
                      _buildCell("الربح الصافي", font, 2),
                      _buildCell("الكمية", font, 2),
                      _buildCell("سعر البيع", font, 2),
                      _buildCell("سعر الشراء", font, 2),
                      // _buildCell("الحجم", font, 2),
                      _buildCell("الاسم", font, 2),
                      _buildCell("#", font, 1),
                    ],
                  ),

                  for (int i = 0; i < salesList.length; i++) ...[
                    () {
                      final rowTotal =
                          salesList[i].sellingPrice * salesList[i].quantity;
                      totalSum += rowTotal;
                      differenceColumn = 0;
                      differenceColumn += (salesList[i].sellingPrice -
                              salesList[i].purchasePrice) *
                          salesList[i].quantity;
                      differenceSum += differenceColumn;
                      return pw.Row(
                        children: [
                          _buildCell(rowTotal.toStringAsFixed(2), font, 2),
                          _buildCell(
                              differenceColumn.toStringAsFixed(2), font, 2),
                          _buildCell(salesList[i].quantity.toString(), font, 2),
                          _buildCell(
                              salesList[i].sellingPrice.toStringAsFixed(2),
                              font,
                              2),
                          _buildCell(
                              salesList[i].purchasePrice.toStringAsFixed(2),
                              font,
                              2),
                          // _buildCell(salesList[i].itemSizeName.toString(), font, 2),
                          _buildCell(salesList[i].itemName.toString(), font, 2),
                          _buildCell((i + 1).toString(), font, 1),
                        ],
                      );
                    }(),
                  ],
                  pw.Row(
                    children: [
                      _buildCell(totalSum.toStringAsFixed(2), font, 2),
                      _buildCell(differenceSum.toStringAsFixed(2), font, 2),
                      _buildCell('المجموع ', font, 9), // Merged big cell
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      // Get the temporary directory to save the PDF
      final tempDir = await getTemporaryDirectory();
      // final pdfPath = '${tempDir.path}/${salesList.orderId!}_${DateTime.now().toString().split(' ')[0]}.pdf';
      final pdfPath =
          '${tempDir.path}/${DateTime.now().toString().split(' ')[0]}.pdf';
      // Delete any existing PDF files in the temporary directory
      final pdfDir = Directory(tempDir.path);
      if (await pdfDir.exists()) {
        final files = pdfDir.listSync();
        for (var file in files) {
          print("pdf file deleted successfully");
          if (file is File && file.path.endsWith('.pdf')) {
            await file.delete();
          }
        }
      }

      // Save the PDF to a file
      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      // Share the PDF via WhatsApp (or any other sharing method)
      await Share.shareFiles([pdfPath],
          text: 'Here is your account statement!',
          sharePositionOrigin: Rect.fromLTWH(0, 0, 10, 10));
    } catch (e) {
      print('Error generating or sharing PDF: $e');
      return null; // Return null in case of an error
    }
  }

  Future<void> prepareExpensesPDF(List<ExpensesItemModel> expensesList,
      String dateFrom, String dateTo) async {
    print("Preparing sales PDF with ${expensesList.length} items.");
    try {
      final font =
          pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));
      // Create a PDF document
      final pdf = pw.Document();
      double totalSum = 0;
      final pageWidth = PdfPageFormat.a4.availableWidth;
      // Add a page to the document
      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) => [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl, // Force RTL for Arabic
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      "النفقات",
                      style: pw.TextStyle(
                        fontSize: 36, // Bigger size
                        fontWeight: pw.FontWeight.bold, // Bold text
                        font: font,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Container(
                        width: pageWidth / 3,
                        alignment: pw.Alignment.topLeft,
                        child: pw.Text(
                            "تاريخ الكشف: ${DateTime.now().toString().split(' ')[0]}",
                            style: pw.TextStyle(fontSize: 12, font: font)),
                      ),
                      pw.Spacer(),
                      pw.Container(
                        width: pageWidth / 3,
                        alignment: pw.Alignment.topRight,
                        child: pw.Text("من تاريخ: $dateFrom",
                            style: pw.TextStyle(fontSize: 12, font: font)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        child: pw.Text("إلى تاريخ: $dateTo",
                            style: pw.TextStyle(fontSize: 12, font: font)),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  // Table Header with Borders
                  pw.Row(
                    children: [
                      _buildCell("السعر", font, 2),
                      _buildCell("الاسم", font, 3),
                      _buildCell("الوقت", font, 2),
                      _buildCell("التاريخ", font, 2),
                      _buildCell("#", font, 1),
                    ],
                  ),

                  for (int i = 0; i < expensesList.length; i++) ...[
                    () {
                      totalSum += expensesList[i].price;
                      return pw.Row(
                        children: [
                          _buildCell(expensesList[i].price.toStringAsFixed(2),
                              font, 2),
                          _buildCell(
                            (expensesList[i].name?.trim().isNotEmpty ?? false)
                                ? expensesList[i].name
                                : 'N/A',
                            font,
                            3,
                          ),
                          _buildCell(
                            expensesList[i].createdAt != null
                                ? DateHelper.formatTimeOnly(
                                    expensesList[i].createdAt!)
                                : "-",
                            font,
                            2,
                          ),
                          _buildCell(
                            expensesList[i].createdAt != null
                                ? DateHelper.formatDateOnly(
                                    expensesList[i].createdAt!)
                                : "-",
                            font,
                            2,
                          ),
                          _buildCell((i + 1).toString(), font, 1),
                        ],
                      );
                    }(),
                  ],
                  pw.Row(
                    children: [
                      _buildCell(totalSum.toStringAsFixed(2), font, 2),
                      _buildCell('السعر الكلي: ', font, 8), // Merged big cell
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      // Get the temporary directory to save the PDF
      final tempDir = await getTemporaryDirectory();
      // final pdfPath = '${tempDir.path}/${salesList.orderId!}_${DateTime.now().toString().split(' ')[0]}.pdf';
      final pdfPath =
          '${tempDir.path}/${DateTime.now().toString().split(' ')[0]}.pdf';
      // Delete any existing PDF files in the temporary directory
      final pdfDir = Directory(tempDir.path);
      if (await pdfDir.exists()) {
        final files = pdfDir.listSync();
        for (var file in files) {
          print("pdf file deleted successfully");
          if (file is File && file.path.endsWith('.pdf')) {
            await file.delete();
          }
        }
      }

      // Save the PDF to a file
      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      // Share the PDF via WhatsApp (or any other sharing method)
      await Share.shareFiles([pdfPath],
          text: 'Here is your expenses report!',
          sharePositionOrigin: Rect.fromLTWH(0, 0, 10, 10));
    } catch (e) {
      print('Error generating or sharing PDF: $e');
      return null; // Return null in case of an error
    }
  }

  // Button actions
  Future<void> createExpensesReportPressed(
      LocalizationService appLocalization) async {
    bool isConnected = await checkConnectivity();
    if (!isConnected) {
      showLoginFailedDialog(
        context,
        appLocalization.getLocalizedString('noInternetConnection'),
        appLocalization.getLocalizedString('noInternet'),
        appLocalization.selectedLanguageCode,
        appLocalization.getLocalizedString('ok'),
      );
      return;
    }

    try {
      showLoadingAvatar(context);

      String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate);
      String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate);
      print(
          "Generating Sales Report from $formattedFromDate to $formattedToDate");

      List<ExpensesItemModel> historyExpensesList =
          await ExpensesService.fetchHistoryExpenses(
              context, formattedFromDate, formattedToDate);
      print("historyExpensesList: $historyExpensesList");
      Navigator.pop(context);
      prepareExpensesPDF(
          historyExpensesList, formattedFromDate, formattedToDate);
    } catch (e) {
      Navigator.pop(context); // ✅ Pop after failure
      print('Error generating expenses report: $e');
      await showLoginFailedDialog(
        context,
        appLocalization.getLocalizedString('reportGenerationFailed'),
        appLocalization.getLocalizedString('tryAgain'),
        appLocalization.selectedLanguageCode,
        appLocalization.getLocalizedString('ok'),
      );
    }
  }

  Future<void> createSalesReportPressed(
      LocalizationService appLocalization) async {
    bool isConnected = await checkConnectivity();
    if (!isConnected) {
      showLoginFailedDialog(
        context,
        appLocalization.getLocalizedString('noInternetConnection'),
        appLocalization.getLocalizedString('noInternet'),
        appLocalization.selectedLanguageCode,
        appLocalization.getLocalizedString('ok'),
      );
      return;
    }

    try {
      showLoadingAvatar(context);
      String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate);
      String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate);
      print(
          "Generating Sales Report from $formattedFromDate to $formattedToDate");

      // Fetch the history expenses list
      List<ItemCart> historySalesList =
          await CartService.fetchAllOrderItemsReport(
              context, formattedFromDate, formattedToDate);
      print("historySalesList: $historySalesList");
      // Call the method to prepare the PDF
      Navigator.pop(context); // Remove the loading avatar
      prepareSalesPDF(historySalesList, formattedFromDate, formattedToDate);
    } catch (e) {
      Navigator.pop(context); // Remove the loading avatar
      print('Error generating expenses report: $e');
      // You can show an error dialog or display a message in the UI based on the exception
      await showLoginFailedDialog(
        context,
        appLocalization.getLocalizedString('reportGenerationFailed'),
        appLocalization.getLocalizedString('tryAgain'),
        appLocalization.selectedLanguageCode,
        appLocalization.getLocalizedString('ok'),
      );
    }
  }

  pw.Widget _buildCell(String text, pw.Font font, int flex) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(3),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(), // Black border for all sides
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 10, font: font),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;
    final scale = (screenSize.width / 390).clamp(0.7, 1.2);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalization.getLocalizedString('reportScreen'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.lighterTextColor,
            fontSize: 18 * scale,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(
          color: AppColors.lighterTextColor,
          size: 24 * scale,
        ),
        toolbarHeight: 56 * scale,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFilterArea(
                appLocalization: appLocalization,
                onDateRangeSelected:
                    (DateTime selectedFromDate, DateTime selectedToDate) {
                  setState(() {
                    fromDate = selectedFromDate;
                    toDate = selectedToDate;
                  });
                },
              ),
              const SizedBox(height: 20),
              CustomReportButton(
                onPressed1: () => createExpensesReportPressed(appLocalization),
                onPressed2: () => createSalesReportPressed(appLocalization),
              ),
              const SizedBox(height: 30),
              CustomTotalsSummaryArea(
                expenses: totalExpenses,
                sales: totalSales,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
