#!/bin/bash
set -x

flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
sensible-browser coverage/html/index-sort-l.html


