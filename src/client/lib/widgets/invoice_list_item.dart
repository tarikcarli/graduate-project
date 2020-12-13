import 'package:business_travel/models/user.dart';
import 'package:business_travel/screens/invoice_edit_screen.dart';
import 'package:business_travel/screens/invoice_single_screen.dart';
import 'package:business_travel/utilities/global_provider.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/invoice.dart';

class InvoiceListItem extends StatelessWidget {
  final Invoice invoice;
  final User user;

  InvoiceListItem({
    @required this.invoice,
    @required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      tileColor: invoice.isAccepted == null
          ? Colors.yellow[200]
          : invoice.isAccepted
              ? Colors.green[200]
              : Colors.red[200],
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            URL.getBinaryPhoto(path: invoice.photo.path),
          ),
        ),
        title: Text(
          '${MyProvider.task.taskIdToName(invoice.taskId)}',
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Tarih: ${DateFormat.yMd().format(invoice.invoicedAt)}\nTutar: ${invoice.price}',
          maxLines: 2,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.details,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => SingleInvoiceScreen(invoice: invoice),
                      ),
                    );
                  },
                ),
              ),
              if (user.role == "operator")
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => EditInvoiceScreen(invoice),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
