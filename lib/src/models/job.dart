import 'jobinfo.dart';
import 'joboptions.dart';

const String scope = 'Job:';

class Job {
  final int id;
  final int timestamp;
  JobOptions jobOptions;
  final JobInfo jobInfo;

  Job({this.id, this.timestamp, this.jobOptions, this.jobInfo});

  factory Job.fromMap(Map<String, dynamic> jobs) {
    JobOptions _jobOptions;
    JobInfo _jobInfo;

    try {
      _jobOptions = JobOptions.fromMap(jobs['options']);
    } catch (e) {
      print('$scope Job-Options map is damaged or incomplete');
    }
    try {
      _jobInfo = JobInfo.fromMap(jobs['info']);
    } catch (e) {
      print('$scope Job-Info map is damaged or incomplete');
    }

    return Job(
      id: jobs['id'],
      timestamp: jobs['timestamp'],
      jobOptions: _jobOptions,
      jobInfo: _jobInfo,
    );
  }

  /// return number of pages printed after applying the pagerange
  int get pageRangeCount {
    int count = 0;
    if (jobOptions.range == '') return jobInfo.pagecount;
    for (String split
        in (jobOptions.range.replaceAll(RegExp('![0-9]+(?:[-,]?[0-9]+)*'), '')).split(',')) {
      if (split.contains('-')) {
        final List<int> hyphenSplit =
            split.split('-').map((String number) => int.tryParse(number)).toList();
        for (int i = 1; i < hyphenSplit.length; i++) {
          count += (hyphenSplit[i] ?? jobInfo.pagecount) - hyphenSplit[i - 1] + 1;
        }
      } else if (int.tryParse(split) != null) {
        count += 1;
      }
    }
    return count;
  }

  /// return worst case price estimation in cents as integer
  int get priceEstimation {
    int _price = 0;

    int _basePrice = 5;
    int _colorPrice = _basePrice * 4;
    int _colorPages = jobInfo.colored;
    int _totalPages = jobInfo.pagecount;
    int _bwPages = _totalPages - _colorPages;

    // adjust page counts according to page range
    if (jobOptions.range != '') {
      _totalPages = pageRangeCount;
      if (_colorPages >= _totalPages) {
        _colorPages = _totalPages;
      } else {
        // _colorPages < _totalPages
        _bwPages = _totalPages - _colorPages;
      }
    }

    // adjust prices if medium is A3
    if (jobOptions.a3) {
      _basePrice *= 2;
      _colorPrice *= 2;
    }

    // take colored pages out of calculation if color is turned off and vice versa
    if (!jobOptions.color) {
      _colorPages = 0;
      _bwPages = _totalPages;
    }

    if (jobOptions.nup == 4) {
      if (_totalPages <= 4) {
        if (jobOptions.color && _colorPages >= 1) {
          _bwPages = 0;
          _colorPages = 1;
        } else {
          _bwPages = 1;
        }
      } else {
        if (jobOptions.color) {
          if (_bwPages >= _colorPages) _bwPages -= _colorPages;
          //if (_bwPages > _colorPages * 3)
          _bwPages = _bwPages ~/ 4 + ((_bwPages % 4 > 0) ? 1 : 0);
        } else {
          _bwPages = _bwPages ~/ 4 + ((_bwPages % 4 > 0) ? 1 : 0);
        }
      }
    }

    if (jobOptions.nup == 2) {
      if (_totalPages <= 2) {
        if (jobOptions.color && _colorPages > 0) {
          _colorPages = 1;
        } else {
          _bwPages = 1;
        }
      } else {
        if (jobOptions.color) {
          if (_bwPages >= _colorPages) _bwPages -= _colorPages;
          //if (_bwPages > _colorPages)
          _bwPages = _bwPages ~/ 2 + (_bwPages % 2);
        } else {
          _bwPages = _bwPages ~/ 2 + (_bwPages % 2);
        }
      }
    }

    // add price of all b/w pages
    _price += _bwPages * _basePrice * jobOptions.copies;

    // add price of all color pages
    _price += _colorPages * jobOptions.copies * _colorPrice;

    return _price;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp,
        'info': jobInfo.toMap(),
        'options': jobOptions.toMap(),
        'estimation': priceEstimation,
      };

  @override
  String toString() => toMap().toString();
}
