import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart';
import '../data/data.dart';
import 'package:intl/intl.dart';

const DAY = 1, WEEK = 2, MONTH = 3; // columnPeriod values

int chartInDays;
int chartColumns; // total columns on chart
int columnsOnScreen; // periods plus room column

class GanttForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new GanttFormState();
  }
}

class GanttFormState extends State<GanttForm> {
  DateTime ganttFromDate = DateTime(2018, 1, 1);
  int columnPeriod = MONTH; //DAY,  WEEK, MONTH
  List<Room> roomsInChart;
  List<Reservation> reservationsInChart;

  @override
  void initState() {
    super.initState();
    columnPeriod = columnPeriod;
    ganttFromDate = ganttFromDate;
    reservationsInChart = reservations;
    roomsInChart = rooms;
  }

  @override
  Widget build(BuildContext context) {
    switch (columnPeriod) {
      case MONTH:
        {
          chartColumns = 13;
          columnsOnScreen = 4;
          chartInDays = 365;
        }
        break;
      case WEEK:
        {
          chartColumns = 21;
          columnsOnScreen = 8;
          chartInDays = (chartColumns-1) * 7;
        }
        break;
      case DAY:
        {
          chartColumns = 36;
          columnsOnScreen = 21;
          chartInDays = chartColumns;
        }
        break;
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: GanttChart(
              columnPeriod: columnPeriod,
              ganttFromDate: ganttFromDate,
              reservationsInChart: reservationsInChart,
              roomsInChart: roomsInChart,
            ),
          ),
        ],
      ),
    );
  }
}

class GanttChart extends StatelessWidget {
  final int columnPeriod;
  final DateTime ganttFromDate;
  final List<Reservation> reservationsInChart;
  final List<Room> roomsInChart;

  GanttChart({
    this.columnPeriod,
    this.ganttFromDate,
    this.reservationsInChart,
    this.roomsInChart,
  });

  @override
  Widget build(BuildContext context) {
    reservationsInChart.sort((a, b) {
      // sort by roomId and fromDate
      var r = a.roomId.compareTo(b.roomId);
      if (r != 0) return r;
      return a.fromDate.compareTo(b.fromDate);
    });
    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child: MediaQuery.removePadding(
        child:
            ListView(children: [buildChart(reservationsInChart, screenWidth)]),
        removeTop: true,
        context: context,
      ),
    );
  }

  Widget buildChart(List<Reservation> reservations, double screenWidth) {
    Color color = Colors.lightGreen;
    var chartBars = buildChartBars(reservations, screenWidth, color);
    return Container(
      height: chartBars.length * 29.0 + 25.0 + 4.0,
      child: ListView(
        physics: new ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Stack(fit: StackFit.loose, children: <Widget>[
            buildGrid(screenWidth),
            buildHeader(screenWidth, color),
            Container(
                margin: EdgeInsets.only(top: 25.0),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: chartBars,
                        ),
                      ),
                    ],
                  ),
                )),
          ]),
        ],
      ),
    );
  }

  Widget buildGrid(double screenWidth) {
    List<Widget> gridColumns = new List();

    for (int i = 0; i <= chartColumns; i++) {
      gridColumns.add(Container(
        decoration: BoxDecoration(
            border: Border(
                right:
                    BorderSide(color: Colors.grey.withAlpha(100), width: 1.0))),
        width: screenWidth / columnsOnScreen,
        // height: 300.0,
      ));
    }

    return Row(
      children: gridColumns,
    );
  }

  Widget buildHeader(double screenWidth, Color color) {
    List<Widget> headerItems = new List();

    DateTime tempDate = ganttFromDate;

    headerItems.add(Container(
      width: screenWidth / columnsOnScreen,
      child: new Text(
        'Room',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10.0,
        ),
      ),
    ));

    const List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    const List<String> days = ["Sun","Mon", "Tue", "Wen", "Thu", "Fri", "Sat"];
    String headerText;
    int year = ganttFromDate.year;
    for (int i = 0; i < chartColumns; i++) {
      if (columnPeriod == MONTH) {
        headerText = months[(ganttFromDate.month + i - 1)%11] + ' ' + year.toString();
        if ((ganttFromDate.month + i) == 11 ) year++;
      }
      var formatter = new DateFormat('yyyy-MM-dd');
      if (columnPeriod == WEEK) {
        headerText = 'Week starting: ' + days[(ganttFromDate.weekday)%6] + '\n' +
          formatter.format(ganttFromDate.add(new Duration(days:i*7)));
      }
      if (columnPeriod == DAY) {
        headerText = days[(ganttFromDate.weekday + i)%6] + '\n' +
        formatter.format(ganttFromDate.add(new Duration(days:i)));
      }
      headerItems.add(Container(
        width: screenWidth / columnsOnScreen,
        child: new Text( headerText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.0,
          ),
        ),
      ));
      tempDate = Utils.nextMonth(tempDate);
    }

    return Container(
      height: 25.0,
      color: color.withAlpha(100),
      child: Row(
        children: headerItems,
      ),
    );
  }

  List<Widget> buildChartBars(
      List<Reservation> reservationsInChart, double screenWidth, Color color) {
    List<Widget> chartBars = new List();
    var last;
    for (int i = 0; i < reservationsInChart.length; i++) {
      if (last != null && reservationsInChart[i].roomId == last.roomId)
        continue; // skip more than one reservation for a single room
      last = reservationsInChart[i];
      chartBars.add(Row(children: <Widget>[
        Container(
          height: 20,
          width: screenWidth / columnsOnScreen,
          child: Text(
            reservationsInChart[i].roomId.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        Row(children: buildReservations(reservationsInChart, i, screenWidth)),
      ]));
    }
    return chartBars;
  }

  List<Widget> buildReservations(
      List reservations, int index, double screenWidth) {
    DateTime lastDate = ganttFromDate;
    List<Widget> chartContent = new List();
    int currentRoomId = reservations[index].roomId;
    double halfDay;
    while (index < reservations.length &&
        reservations[index].roomId == currentRoomId) {
          // define the scale of 1 day
        double dayScale;
        if (columnPeriod == DAY) dayScale = screenWidth / columnsOnScreen;
        if (columnPeriod == WEEK) dayScale = screenWidth / (columnsOnScreen*7);
        if (columnPeriod == MONTH) dayScale = screenWidth / (columnsOnScreen*365/12);
        if (halfDay == null) halfDay = dayScale/2;
      chartContent.add(
        Container(
          decoration: BoxDecoration(
              color: Colors.green, borderRadius: BorderRadius.circular(10.0)),
          height: 20.0,
          width: reservationsInChart[index]
                  .thruDate
                  .difference(reservationsInChart[index].fromDate)
                  .inDays * dayScale,
          margin: EdgeInsets.only(
              left: reservationsInChart[index]
                      .fromDate
                      .difference(lastDate)
                      .inDays * dayScale + halfDay,
              top: 4.0,
              bottom: 4.0),
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              reservationsInChart[index].customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.0),
            ),
          ),
        ),
      );
      lastDate = reservationsInChart[index].thruDate;
      index++; halfDay = 0.00;
    }
    return chartContent;
  }
}
