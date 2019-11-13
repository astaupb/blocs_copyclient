enum ClientType {
  unknown,
  firefox,
  chrome,
  safari,
  electron,
  dartio,
  curl,
}

class Token {
  final int id;
  final String userAgent;
  final String ip;
  final String location;
  final DateTime created;
  final DateTime updated;

  ClientType clientType;

  Token(this.id, this.userAgent, this.ip, this.location, this.created, this.updated,
      {this.clientType});

  factory Token.fromMap(Map<String, dynamic> map) => Token(
        map['id'],
        map['user_agent'],
        map['ip'],
        map['location'],
        DateTime.fromMillisecondsSinceEpoch(map['created']),
        DateTime.fromMillisecondsSinceEpoch(map['updated']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_agent': userAgent,
        'ip': ip,
        'location': location,
        'created': created,
        'updated': updated,
      };

  @override
  String toString() => toMap().toString();
}
