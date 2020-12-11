import 'package:business_travel/providers/invoice.dart';
import 'package:business_travel/providers/location.dart';
import 'package:business_travel/providers/task.dart';
import 'package:business_travel/providers/user.dart';

class GlobalProvider {
  static UserProvider userProvider;
  static TaskProvider taskProvider;
  static LocationProvider locationProvider;
  static InvoiceProvider invoiceProvider;
}
