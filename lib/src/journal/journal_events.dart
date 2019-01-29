class JournalEvent {}

class InitJournal extends JournalEvent {
  String token;

  InitJournal(this.token);

  Map<String, dynamic> toMap() => {'token': token};

  @override
  toString() => toMap().toString();
}

class RefreshJournal extends JournalEvent {}
