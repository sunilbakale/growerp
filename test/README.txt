run tests:

just test: 
flutter test

test with coverage:  
flutter test --coverage && genhtml -o coverage coverage/lcov.info && xdg-open coverage/index.html