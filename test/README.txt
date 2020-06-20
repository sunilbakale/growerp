run tests:

just test: 
flutter test

test with coverage:  
flutter test --coverage && genhtml -o coverage coverage/lcov.info && xdg-open coverage/index.html

example tests:
https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library/test
