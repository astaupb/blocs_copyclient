import 'package:blocs_copyclient/src/models/transaction.dart';

List<Transaction> exampleJournal = [
  Transaction(value: -5, description: '1 Seiten gedruckt', timestamp: '20.08.19 12:05:00'),
  Transaction(value: -100, description: '5 Seiten Farbe gedruckt', timestamp: '20.08.19 12:05:00'),
  Transaction(value: -40, description: '2 Seiten Farbe gedruckt', timestamp: '20.08.19 12:05:00'),
  Transaction(value: -50, description: '10 Seiten gedruckt', timestamp: '20.08.19 12:00:00'),
  Transaction(
      value: 500, description: 'Aufladung 5 Euro', admin_id: 8, timestamp: '20.08.19 11:45:00')
];

const String jobMap =
    '{"id":134818,"info":{"filename":"AStA Copyclient Benutzeranleitung.pdf","title":"","pagecount":4,"colored":4,"a3":false,"landscape":true},"options":{"color":false,"duplex":0,"copies":1,"collate":false,"bypass":false,"keep":false,"a3":false,"nup":1,"nuppageorder":0,"range":"", "bypass":true},"timestamp":1564768316,"created":1564768316,"updated":1565274503}';

const String longerJobMap =
    '{"id":134818,"info":{"filename":"AStA Copyclient Benutzeranleitung.pdf","title":"","pagecount":8,"colored":4,"a3":false},"options":{"color":false,"duplex":0,"copies":1,"collate":false,"bypass":false,"keep":false,"a3":false,"nup":1,"nuppageorder":0,"range":""},"timestamp":1564768316,"created":1564768316,"updated":1565274503}';
