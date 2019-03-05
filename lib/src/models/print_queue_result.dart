import '../models/print_queue_task.dart';

class PrintQueueResult {
  final List<PrintQueueTask> incoming;
  final List<PrintQueueTask> processing;

  PrintQueueResult(this.incoming, this.processing);

  Map<String, dynamic> toMap() => {
        'incoming': incoming.toString(),
        'processing': processing.toString(),
      };

  @override
  String toString() => toMap().toString();
}
