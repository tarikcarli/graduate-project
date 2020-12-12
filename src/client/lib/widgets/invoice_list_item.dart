import 'package:business_travel/utilities/global_provider.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/invoice.dart';

class InvoiceListItem extends StatelessWidget {
  final Invoice invoice;
  InvoiceListItem({this.invoice});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          URL.getBinaryPhoto(path: invoice.photo.path),
        ),
      ),
      title: Text('${MyProvider.task.taskIdToName(invoice.taskId)}'),
      subtitle: Text(
          'Tarih: ${DateFormat.yMd().format(invoice.invoicedAt)}\nTutar: ${invoice.price}'),
    );
  }
}
