# growerp hotel
GrowERP Flutter frontend component for Android, IOS and Web using Flutter.

Under development.
This is the Hotel branch for a hotel desk reservation and together with the
ecommerce app by customers themselves.

This hotel branch will have the following functions:

Hotel:

Room type = accommodationType
Room number = accommodationspot

we have rooms/tables/accomspot with different types/areas/accomarea and status: ready for rent, cleaning

customers make a reservation for room type: check availability

customers check-in --> room occupied --> checkout/payment -> toClean

customers check-out -> room toClean -> cleaning -> toCheck

employees clean room -> room toCheck (opt) -> checking -> available

employee check room -> room available
employee check room -> room unAvailable

main menu:

1. reservations(orders): create/change/cancel
2. check-in: find customer, assign room
3. check-out: print receipt, order complete, room -> cleaning
4. rooms for clean: -> available -> print
5. my info
6. logout

Setup menu

1. hotel
2. room types with room numbers
3. employees
4. customers
5. export orders, rooms & status

For the backend you need the Moqui ERP system (moqui.org) 
with an extra component: https://github.com/growerp/growerp-backend-mobile
