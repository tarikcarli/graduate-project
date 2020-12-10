import 'package:business_travel/models/invoice.dart';
import 'package:flutter/material.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> invoices = [];
}
