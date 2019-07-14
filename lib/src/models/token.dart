class Token {
  final int id;
  final String userAgent;
  final String ip;
  final String location;
  final DateTime created;

  Token(this.id, this.userAgent, this.ip, this.location, this.created);

  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
      map['id'],
      map['user_agent'],
      map['ip'],
      map['location'],
      DateTime.parse(map['created']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_agent': userAgent,
        'ip': ip,
        'location': location,
        'created': created,
      };

  @override
  String toString() => toMap().toString();
}
