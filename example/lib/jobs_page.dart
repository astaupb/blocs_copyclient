import 'package:blocs_copyclient/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barcode_scan/barcode_scan.dart';

class JobsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  @override
  Widget build(BuildContext context) {
    JobsBloc jobsBloc = BlocProvider.of<JobsBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('My Jobs'),
        ),
        body: BlocBuilder(
          bloc: jobsBloc,
          builder: (BuildContext context, JobsState state) {
            if (state.isInit) {
              jobsBloc.onStart();
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
                        jobsBloc.onPrintbyUid(target, state.value[index].uid);
                      } catch (e) {
                        print('Jobs: $e');
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text('No printer was selected')));
                      }
                    },
                  );
                },
              );
            } else if (state.isError) {
              return Text('Ein Fehler ist aufgetreten: ${state.err}');
            }
          },
        ),
        floatingActionButton: Builder(
          builder: (BuildContext context) =>
              FloatingActionButton(onPressed: () => null),
        ));
  }
}
