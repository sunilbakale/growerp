// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../bloc/bloc.dart';

const String _loremIpsumParagraph =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod '
    'tempor incididunt ut labore et dolore magna aliqua. Vulputate dignissim '
    'suspendisse in est. Ut ornare lectus sit amet. Eget nunc lobortis mattis '
    'aliquam faucibus purus in. Hendrerit gravida rutrum quisque non tellus '
    'orci ac auctor. Mattis aliquam faucibus purus in massa. Tellus rutrum '
    'tellus pellentesque eu tincidunt tortor. Nunc eget lorem dolor sed. Nulla '
    'at volutpat diam ut venenatis tellus in metus. Tellus cras adipiscing enim '
    'eu turpis. Pretium fusce id velit ut tortor. Adipiscing enim eu turpis '
    'egestas pretium. Quis varius quam quisque id. Blandit aliquam etiam erat '
    'velit scelerisque. In nisl nisi scelerisque eu. Semper risus in hendrerit '
    'gravida rutrum quisque. Suspendisse in est ante in nibh mauris cursus '
    'mattis molestie. Adipiscing elit duis tristique sollicitudin nibh sit '
    'amet commodo nulla. Pretium viverra suspendisse potenti nullam ac tortor '
    'vitae.\n'
    '\n'
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod '
    'tempor incididunt ut labore et dolore magna aliqua. Vulputate dignissim '
    'suspendisse in est. Ut ornare lectus sit amet. Eget nunc lobortis mattis '
    'aliquam faucibus purus in. Hendrerit gravida rutrum quisque non tellus '
    'orci ac auctor. Mattis aliquam faucibus purus in massa. Tellus rutrum '
    'tellus pellentesque eu tincidunt tortor. Nunc eget lorem dolor sed. Nulla '
    'at volutpat diam ut venenatis tellus in metus. Tellus cras adipiscing enim '
    'eu turpis. Pretium fusce id velit ut tortor. Adipiscing enim eu turpis '
    'egestas pretium. Quis varius quam quisque id. Blandit aliquam etiam erat '
    'velit scelerisque. In nisl nisi scelerisque eu. Semper risus in hendrerit '
    'gravida rutrum quisque. Suspendisse in est ante in nibh mauris cursus '
    'mattis molestie. Adipiscing elit duis tristique sollicitudin nibh sit '
    'amet commodo nulla. Pretium viverra suspendisse potenti nullam ac tortor '
    'vitae';

const double _fabDimension = 56.0;

class HomeForm extends StatefulWidget {
  final AuthBloc authBloc;

  HomeForm({@required this.authBloc})
      : assert(authBloc != null);

  @override
  _HomeFormState createState() {
    return _HomeFormState();
  }
}

class _HomeFormState
    extends State<HomeForm> {
  ContainerTransitionType _transitionType = ContainerTransitionType.fadeThrough;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => BlocProvider.of<AuthBloc>(context)
                .add(LoggedOut()))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          _OpenContainerWrapper(
            transitionType: _transitionType,
            closedBuilder: (BuildContext _, VoidCallback openContainer) {
              return _ExampleCard(openContainer: openContainer);
            },
          ),
          const SizedBox(height: 16.0),
          Row(
            children: <Widget>[
              Expanded(
                child: _OpenContainerWrapper(
                  transitionType: _transitionType,
                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                    return _SmallerCard(
                      openContainer: openContainer,
                      image: 'assets/reservation.png',
                      subtitle: 'Reservation',
                    );
                  },
                ),
              ),
              Expanded(
                child: _OpenContainerWrapper(
                  transitionType: _transitionType,
                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                    return _SmallerCard(
                      openContainer: openContainer,
                      image: 'assets/single-bed.png',
                      subtitle: 'Rooms',
                    );
                  },
                ),
              ),
              Expanded(
                child: _OpenContainerWrapper(
                  transitionType: _transitionType,
                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                    return _SmallerCard(
                      openContainer: openContainer,
                      image: 'assets/check-in.png',
                      subtitle: 'Check-In',
                    );
                  },
                ),
              ),
              Expanded(
                child: _OpenContainerWrapper(
                  transitionType: _transitionType,
                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                    return _SmallerCard(
                      openContainer: openContainer,
                      image: 'assets/check-out.png',
                      subtitle: 'Check-Out',
                    );
                  },
                ),
              ),
              Expanded(
                child: _OpenContainerWrapper(
                  transitionType: _transitionType,
                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                    return _SmallerCard(
                      openContainer: openContainer,
                      image: 'assets/myInfo.png',
                      subtitle: 'My Info',
                    );
                  },
                ),
              ),
              const SizedBox(width: 8.0),
            ],
          ),
        ],
      ),
      floatingActionButton: OpenContainer(
        transitionType: _transitionType,
        openBuilder: (BuildContext context, VoidCallback _) {
          return _DetailsPage();
        },
        closedElevation: 6.0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(_fabDimension / 2),
          ),
        ),
        closedColor: Theme.of(context).colorScheme.secondary,
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return SizedBox(
            height: _fabDimension,
            width: _fabDimension,
            child: Center(
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper({
    this.closedBuilder,
    this.transitionType,
  });

  final OpenContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        return _DetailsPage();
      },
      tappable: false,
      closedBuilder: closedBuilder,
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({this.openContainer});

  final VoidCallback openContainer;

  @override
  Widget build(BuildContext context) {
    return _InkWellOverlay(
      openContainer: openContainer,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.green,
              child: Center(
                child: Image.asset(
                  'assets/growerp.jpg',
                  width: 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallerCard extends StatelessWidget {
  const _SmallerCard({
    this.openContainer,
    this.image,
    this.subtitle,
  });

  final VoidCallback openContainer;
  final String image;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _InkWellOverlay(
      openContainer: openContainer,
      
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(image),
          Text(subtitle)
        ],
      ),
    );
  }
}


class _InkWellOverlay extends StatelessWidget {
  const _InkWellOverlay({
    this.openContainer,
    this.width,
    this.height,
    this.child,
  });

  final VoidCallback openContainer;
  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: InkWell(
        onTap: openContainer,
        child: child,
      ),
    );
  }
}

class _DetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details page')),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.black38,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(70.0),
              child: Image.asset(
                'assets/growerp.jpg',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Title',
                  // TODO(shihaohong): Remove this once Flutter stable adopts the modern
                  // Material text style nomenclature.
                  // ignore: deprecated_member_use
                  style: Theme.of(context).textTheme.headline.copyWith(
                        color: Colors.black54,
                        fontSize: 30.0,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  _loremIpsumParagraph,
                  // TODO(shihaohong): Remove this once Flutter stable adopts the modern
                  // Material text style nomenclature.
                  // ignore: deprecated_member_use
                  style: Theme.of(context).textTheme.body1.copyWith(
                        color: Colors.black54,
                        height: 1.5,
                        fontSize: 16.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
