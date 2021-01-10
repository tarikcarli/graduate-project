import 'package:business_travel/models/invoice.dart';
import 'package:business_travel/providers/invoice.dart';
import 'package:business_travel/providers/task.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/invoice_create_screen.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/widgets/drawer_widget.dart';
import 'package:business_travel/widgets/invoice_list_item.dart';
import 'package:business_travel/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InvoicesScreen extends StatefulWidget {
  @override
  _InvoicesScreenState createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  InvoiceProvider _invoiceProvider;
  TaskProvider _taskProvider;
  UserProvider _userProvider;
  bool _loading = true;
  bool _firstLoading = true;
  int _taskId = 0;
  List<Invoice> _invoices = [];
  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstLoading) {
      _firstLoading = false;
      _invoiceProvider = Provider.of<InvoiceProvider>(context, listen: true);
      _invoiceProvider.addListener(changeTaskToState);
      getInvoices();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _invoiceProvider.removeListener(changeTaskToState);
  }

  void changeTaskToState() {
    setState(() {
      _invoices = _invoiceProvider.filterInvoice(_taskId);
    });
  }

  Future<void> getInvoices() async {
    try {
      if (_userProvider.user.role == "admin")
        await _invoiceProvider.fetchAndSetInvoices(
          token: _userProvider.token,
          adminId: _userProvider.user.id,
        );
      else
        await _invoiceProvider.fetchAndSetInvoices(
          token: _userProvider.token,
          operatorId: _userProvider.user.id,
        );
      _invoices = _invoiceProvider.invoices;
      setState(() {});
    } catch (error) {
      await CustomDialog.show(
        ctx: context,
        withCancel: false,
        title: "Faturalar Alınamadı",
        content: "Durum: ${error.toString()}",
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _select(String value) {
    _taskId = int.tryParse(value);

    _invoices = _invoiceProvider.filterInvoice(_taskId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Faturalar',
          style: style.copyWith(
            color: Theme.of(context).accentColor,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _select,
            initialValue: _taskId.toString(),
            itemBuilder: (BuildContext context) {
              return _taskProvider
                  .tasksIdAndNameToMap()
                  .map((Map<String, String> element) {
                return PopupMenuItem<String>(
                  value: element["value"],
                  child: Text(
                    element["display"],
                    style: _taskId.toString() == element["value"]
                        ? style.copyWith(color: Theme.of(context).primaryColor)
                        : style,
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: _loading
          ? ProgressWidget()
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _invoices.length > 0
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _invoices.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              InvoiceListItem(
                                invoice: _invoices[i],
                                user: _userProvider.user,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: Center(
                          child: Text(
                            'Hiç Faturanız Yok!',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
              ],
            ),
      floatingActionButton: _userProvider.user.role == "operator"
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateInvoiceScreen(),
                  ),
                );
                setState(() {});
              },
              child: Icon(
                Icons.add,
                color: Theme.of(context).accentColor,
              ),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }
}
