import 'package:meta/meta.dart';
import '../models/print_queue_task.dart';

class PrintQueueResult {
  final List<PrintQueueTask> incoming;
  final List<PrintQueueTask> processing;

  PrintQueueResult(this.incoming, this.processing);

  Map<String, dynamic> toMap() => {
        'incoming': incoming,
        'processing': processing,
      };

  @override
  String toString() => toMap().toString();
}
