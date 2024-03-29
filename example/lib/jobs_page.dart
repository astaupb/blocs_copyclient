import 'package:barcode_scan/barcode_scan.dart';
import 'package:blocs_copyclient/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  JoblistBloc jobsBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Jobs'),
        ),
        body: BlocBuilder(
          bloc: jobsBloc,
          builder: (BuildContext context, JoblistState state) {
            if (state.isInit) {
              return Container(width: 0.0, height: 0.0);
            } else if (state.isBusy) {
              return Center(child: CircularProgressIndicator());
            } else if (state.isResult) {
              return ListView.builder(
                itemCount: state.value.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(state.value[index].jobInfo.filename),
                    onTap: () async {
                      try {
                        String target = await BarcodeScanner.scan();
                        jobsBloc.onPrintById(target, state.value[index].id);
                      } catch (e) {
                        print('Jobs: $e');
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('No printer was selected')));
                      }
                    },
                  );
                },
              );
            } else if (state.isException) {
              return Text('Ein Fehler ist aufgetreten: ${state.error}');
            }
            return Container(width: 0.0, height: 0.0);
          },
        ),
        floatingActionButton: Builder(
          builder: (BuildContext context) => FloatingActionButton(
            onPressed: () => jobsBloc.onRefresh(),
            child: Icon(Icons.refresh),
          ),
        ));
  }

  @override
  void initState() {
    jobsBloc = BlocProvider.of<JoblistBloc>(context);
    super.initState();
  }
}
