class Room {
  int id;
  String name;
  Room({this.id, this.name});
}
List <Room> rooms = [
  Room(id: 1, name: "Red Room"),
  Room(id: 2, name: "Blue Room"),
  Room(id: 3, name: "Green Room"),
  Room(id: 4, name: "Dark Room"),
];

class Customer {
  int id;
  String name;
  Customer({this.id, this.name});

}

List <Customer> cusomers = [
  Customer(id: 1, name: "Jan Jansen"),
  Customer(id: 2, name: "Cees Boomsma"),
  Customer(id: 3, name: "Piet Groten")
];

class Reservation {
  int id;
  DateTime fromDate;
  DateTime thruDate;
  int roomId;
  int customerId;
  String customerName;
  Reservation({this.id, this.fromDate, this.thruDate, 
    this.roomId, this.customerId, this.customerName});
}

List <Reservation> reservations = [
  Reservation( id: 100, fromDate: DateTime(2018, 1, 29),
    thruDate: DateTime(2018 , 1, 30), roomId: 1, customerId: 3,
    customerName: "jan Jansen"),
  Reservation( id: 100, fromDate: DateTime(2018, 2, 10),
    thruDate: DateTime(2018 , 2, 17), roomId: 1, customerId: 3,
    customerName: "Piet lemmon"),
  Reservation( id: 100, fromDate: DateTime(2018, 1, 29),
    thruDate: DateTime(2018 , 1, 31), roomId: 2, customerId: 1,
    customerName: "Jan de boer"),
  Reservation( id: 100, fromDate: DateTime(2018, 1, 29),
    thruDate: DateTime(2018 , 1, 31), roomId: 3, customerId: 2,
    customerName: "Cees Jansma"),
  Reservation( id: 100, fromDate: DateTime(2018, 3, 10),
    thruDate: DateTime(2018 , 3, 20), roomId: 4, customerId: 2,
    customerName: "1Hans de Groot"),
  Reservation( id: 100, fromDate: DateTime(2018, 3, 20),
    thruDate: DateTime(2018 , 3, 24), roomId: 4, customerId: 2,
    customerName: "2Hans de Groot"),
];

