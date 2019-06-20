/// JobOptions holds options that can generally be modified by the user at any time
class JobOptions {
  bool color;
  int duplex;
  int copies;
  bool collate;
  bool a3;
  String range;
  int nup;
  int nupPageOrder;
  bool keep;

  /// JobOptions with default values
  JobOptions(
      {this.color = false,
      this.duplex = 0,
      this.copies = 1,
      this.collate = false,
      this.a3 = false,
      this.range = '',
      this.nup = 1,
      this.nupPageOrder = 0,
      this.keep = false});

  /// Build JobOptions object from map
  factory JobOptions.fromMap(Map<String, dynamic> options) => JobOptions(
        color: options['color'],
        duplex: options['duplex'],
        copies: options['copies'],
        collate: options['collate'],
        a3: options['a3'],
        range: options['range'],
        nup: options['nup'],
        nupPageOrder: options['nuppageorder'],
        keep: options['keep'],
      );

  Map<String, dynamic> toMap() => {
        'color': color,
        'duplex': duplex,
        'copies': copies,
        'collate': collate,
        'a3': a3,
        'range': range,
        'nup': nup,
        'nuppageorder': nupPageOrder,
        'keep': keep
      };

  @override
  String toString() => toMap().toString();
}

enum NupPageOrder { RIGHTTHENDOWN, DOWNTHENRIGHT, LEFTTHENDOWN, DOWNTHENLEFT }
