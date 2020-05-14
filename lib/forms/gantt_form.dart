import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart';
import 'dart:math';
import 'homeForm_data.dart';

class GanttForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new GanttFormState();
  }
}

class GanttFormState extends State<GanttForm> with TickerProviderStateMixin {
  AnimationController animationController;

  DateTime ganttFromDate = DateTime(2018, 1, 1);
  DateTime ganttThruDate = DateTime(2019, 1, 1);

  List<Room> roomsInChart;
  List<Reservation> reservationsInChart;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        duration: Duration(microseconds: 2000), vsync: this);
    animationController.forward();

    reservationsInChart = reservations;
    roomsInChart = rooms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: GanttChart(
                animationController: animationController,
                ganttFromDate: ganttFromDate,
                ganttThruDate: ganttThruDate,
                reservationsInChart: reservationsInChart,
                roomsInChart: roomsInChart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GanttChart extends StatelessWidget {
  final AnimationController animationController;
  final DateTime ganttFromDate;
  final DateTime ganttThruDate;
  final List<Reservation> reservationsInChart;
  final List<Room> roomsInChart;

  int chartColumns;
  int chartColumnsToFitScreen = 12;
  Animation<double> width;

  GanttChart({
    this.animationController,
    this.ganttFromDate,
    this.ganttThruDate,
    this.reservationsInChart,
    this.roomsInChart,
  }) {
    chartColumns = calculateNumberOfMonthsBetween(ganttFromDate, ganttThruDate);
  }

  Color randomColorGenerator() {
    var r = new Random();
    return Color.fromRGBO(r.nextInt(256), r.nextInt(256), r.nextInt(256), 0.75);
  }

  int calculateNumberOfMonthsBetween(DateTime from, DateTime to) {
    return to.month - from.month + 12 * (to.year - from.year) + 1;
  }

  int calculateDistanceToLeftBorder(DateTime reservationStartedAt) {
    if (reservationStartedAt.compareTo(ganttFromDate) <= 0) {
      return 0;
    } else
      return calculateNumberOfMonthsBetween(
              ganttFromDate, reservationStartedAt) -
          1;
  }

  int calculateRemainingWidth(
      DateTime reservationStartedAt, DateTime reservationEndedAt) {
    int reservationLength = calculateNumberOfMonthsBetween(
        reservationStartedAt, reservationEndedAt);
    if (reservationStartedAt.compareTo(ganttFromDate) >= 0 &&
        reservationStartedAt.compareTo(ganttThruDate) <= 0) {
      if (reservationLength <= chartColumns)
        return reservationLength;
      else
        return chartColumns -
            calculateNumberOfMonthsBetween(ganttFromDate, reservationStartedAt);
    } else if (reservationStartedAt.isBefore(ganttFromDate) &&
        reservationEndedAt.isBefore(ganttFromDate)) {
      return 0;
    } else if (reservationStartedAt.isBefore(ganttFromDate) &&
        reservationEndedAt.isBefore(ganttThruDate)) {
      return reservationLength -
          calculateNumberOfMonthsBetween(reservationStartedAt, ganttFromDate);
    } else if (reservationStartedAt.isBefore(ganttFromDate) &&
        reservationEndedAt.isAfter(ganttThruDate)) {
      return chartColumns;
    }
    return 0;
  }

  List<Widget> buildChartBars(
      List<Reservation> reservationsInChart, double chartWidth, Color color) {
    List<Widget> chartBars = new List();
    var last;
    for (int i = 0; i < reservationsInChart.length; i++) {
      if (last != null && reservationsInChart[i].roomId == last.roomId)
        continue;
      last = reservationsInChart[i];
      var remainingWidth = calculateRemainingWidth(
          reservationsInChart[i].fromDate, reservationsInChart[i].thruDate);
      if (remainingWidth > 0) {
        chartBars.add(Row(children: <Widget>[
          Container(
            height: 20,
            width: chartWidth / 12,
            child: Text(
              reservationsInChart[i].roomId.toString(),
              textAlign: TextAlign.center,
            ),
          ),
          Row(children: buildReservations(reservationsInChart, i, chartWidth)),
        ]));
      }
    }

    return chartBars;
  }

  List<Widget> buildReservations(
      List reservations, int index, double chartWidth) {
    DateTime lastDate = ganttFromDate;
    List<Widget> chartContent = new List();
    int currentRoomId = reservations[index].roomId;
    while (index < reservations.length &&
        reservations[index].roomId == currentRoomId) {
      chartContent.add(
        Container(
          decoration: BoxDecoration(
              color: Colors.green, borderRadius: BorderRadius.circular(10.0)),
          height: 20.0,
          width: reservationsInChart[index]
                  .thruDate
                  .difference(reservationsInChart[index].fromDate)
                  .inDays *
              chartWidth /
              365,
          margin: EdgeInsets.only(
              left: ((reservationsInChart[index]
                          .fromDate
                          .difference(lastDate)
                          .inDays *
                      chartWidth /
                      365)),
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
      index++;
    }
    return chartContent;
  }

  Widget buildHeader(double chartWidth, Color color) {
    List<Widget> headerItems = new List();

    DateTime tempDate = ganttFromDate;

    headerItems.add(Container(
      width: chartWidth / chartColumnsToFitScreen,
      child: new Text(
        'NAME',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10.0,
        ),
      ),
    ));

    for (int i = 0; i < chartColumns; i++) {
      headerItems.add(Container(
        width: chartWidth / chartColumnsToFitScreen,
        child: new Text(
          tempDate.month.toString() + '/' + tempDate.year.toString(),
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

  Widget buildGrid(double chartWidth) {
    List<Widget> gridColumns = new List();

    for (int i = 0; i <= chartColumns; i++) {
      gridColumns.add(Container(
        decoration: BoxDecoration(
            border: Border(
                right:
                    BorderSide(color: Colors.grey.withAlpha(100), width: 1.0))),
        width: chartWidth / chartColumnsToFitScreen,
        // height: 300.0,
      ));
    }

    return Row(
      children: gridColumns,
    );
  }

  Widget buildChart(List<Reservation> reservations, double chartWidth) {
    Color color = randomColorGenerator();
    var chartBars = buildChartBars(reservations, chartWidth, color);
    return Container(
      height: chartBars.length * 29.0 + 25.0 + 4.0,
      child: ListView(
        physics: new ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Stack(fit: StackFit.loose, children: <Widget>[
            buildGrid(chartWidth),
            buildHeader(chartWidth, color),
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

  List<Widget> buildChartContent(double chartWidth) {
    List<Widget> chartContent = new List();

    reservations.sort((a, b) {
      // sort by roomId and fromDate
      var r = a.roomId.compareTo(b.roomId);
      if (r != 0) return r;
      return a.fromDate.compareTo(b.fromDate);
    });

    if (reservations.length > 0) {
      chartContent.add(buildChart(reservations, chartWidth));
    }

    return chartContent;
  }

  @override
  Widget build(BuildContext context) {
    var chartWidth = MediaQuery.of(context).size.width;
    return Container(
      child: MediaQuery.removePadding(
        child: ListView(children: buildChartContent(chartWidth)),
        removeTop: true,
        context: context,
      ),
    );
  }
}
