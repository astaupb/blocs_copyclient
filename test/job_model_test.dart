import 'dart:convert';

import 'package:blocs_copyclient/src/models/job.dart';
import "package:test/test.dart";

import 'example_data.dart';

void main() {
  test('Fill Job with json data and get stringified map', () {
    final Job job = Job.fromMap(json.decode(jobMap));
    expect(
        job.toString(),
        equals(
            '{id: 134818, timestamp: 1564768316, info: {filename: AStA Copyclient Benutzeranleitung.pdf, title: , pagecount: 4, colored: 4, a3: false}, options: {color: false, duplex: 0, copies: 1, collate: false, a3: false, range: , nup: 1, nuppageorder: 0, keep: false, bypass: true}, estimation: 20}'));
  });

  test('calculate price before and after pagerange', () {
    Job job = Job.fromMap(json.decode(jobMap));

    print(
        'testing ${job.jobInfo.pagecount} pages with ${job.jobInfo.colored} color pages\n range: ${job.jobOptions.range}');

    expect(job.priceEstimation, 20);

    job.jobOptions.color = true;
    expect(job.priceEstimation, 80);

    job.jobOptions.color = false;
    job.jobOptions.a3 = true;
    expect(job.priceEstimation, 40);

    job.jobOptions.color = true;
    job.jobOptions.a3 = true;
    expect(job.priceEstimation, 160);

    job.jobOptions.range = '2-3';

    print(
        'testing ${job.jobInfo.pagecount} pages with ${job.jobInfo.colored} color pages\n range: ${job.jobOptions.range ?? 'All'}');

    job.jobOptions.color = false;
    job.jobOptions.a3 = false;
    expect(job.priceEstimation, 10);

    job.jobOptions.color = true;
    expect(job.priceEstimation, 40);

    job.jobOptions.a3 = true;
    expect(job.priceEstimation, 80);

    job.jobOptions.color = false;
    expect(job.priceEstimation, 20);

    print('testing same stuff with NuP 2 and 4 now');

    job.jobOptions.nup = 2;

    job.jobOptions.color = false;
    job.jobOptions.a3 = false;
    expect(job.priceEstimation, 5);

    job.jobOptions.color = true;
    expect(job.priceEstimation, 20);

    job.jobOptions.a3 = true;
    expect(job.priceEstimation, 40);

    job.jobOptions.color = false;
    expect(job.priceEstimation, 10);

    // also increase pages to nupping makes sense
    job = Job.fromMap(json.decode(longerJobMap));
    job.jobOptions.nup = 4;
    job.jobOptions.range = '2-6';

    job.jobOptions.color = false;
    job.jobOptions.a3 = false;
    expect(job.priceEstimation, 10);

    job.jobOptions.color = true;
    expect(job.priceEstimation, 40);

    job.jobOptions.a3 = true;
    expect(job.priceEstimation, 80);

    job.jobOptions.color = false;
    expect(job.priceEstimation, 20);
  });

  test('Get number of pages according to pagerange', () {
    final Job job = Job.fromMap(json.decode(jobMap));

    // test various pagerange combinations
    job.jobOptions.range = '1-2';
    expect(job.pageRangeCount, 2);

    job.jobOptions.range = '1,2';
    expect(job.pageRangeCount, 2);

    job.jobOptions.range = '1';
    expect(job.pageRangeCount, 1);

    job.jobOptions.range = '2,4';
    expect(job.pageRangeCount, 2);

    job.jobOptions.range = '1-4';
    expect(job.pageRangeCount, 4);

    job.jobOptions.range = '1,3-4';
    expect(job.pageRangeCount, 3);

    job.jobOptions.range = 'asfsvsdvds';
    expect(job.pageRangeCount, 0);

    job.jobOptions.range = '1';
    expect(job.pageRangeCount, 1);

    job.jobOptions.range = '3-4,1-2';
    expect(job.pageRangeCount, 4);

    job.jobOptions.range = '1,2,3';
    expect(job.pageRangeCount, 3);

    job.jobOptions.range = '1,2,';
    expect(job.pageRangeCount, 2);

    job.jobOptions.range = '2-';
    expect(job.pageRangeCount, 3);

    job.jobOptions.range = '';
    expect(job.pageRangeCount, 4);
  });
}
