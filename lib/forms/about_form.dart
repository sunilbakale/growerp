import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../widgets/text_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Center(
            child: Wrap(
      spacing: 20,
      runSpacing: 20,
      children: <Widget>[
        Bloc(
            header: 'About Growerp',
            content: TextSpan(children: <TextSpan>[
              _text('GrowERP is a Flutter frontend for either Moqui '
                  'or Apache OFBiz(coming soon). All modules can be ran unchanged,'
                  ' natively on currenty Mobile(IOS,Android) and in '
                  'the browser(Flutter in beta). '
                  'Linux, Mac and Windows will be available soon.\n'
                  'Yes, even this site is developed with Flutter. GrowERP is '
                  'targetted at the smaller businesses like hotels, restaurants, '
                  'freelancers, dentists and ecommerce frontends and to larger '
                  'companies wanting a mobile app for a particular ERP system '
                  'function.\n\n'
                  'All apps have full state management and automated tests '
                  'covering at least 50% of the app and can be tried in '
                  'the browser and downloaded from either '
                  'the App- or Play-Store.\n\n'
                  'All apps are available on github currently in a '),
              _textLink('https://www.github.com/growerp/growerp',
                  'single repository'),
              _text(' in several branches.\n\n'),
              _text('Currently just the moqui backend component can be found '),
              _textLink('https://www.github.com/growerp/growerp-backend-mobile',
                  'here.'),
              _text(
                  '\nThe Apache OFBiz component will follow later when the REST '
                  'interface is available. Installation instructions are in '
                  'the README files inside the project directory.\n\n'),
              _textLink('https://www.antwebsystems.com',
                  'GrowERP is an initiative of Antwebsystems Co.Ltd'),
            ])),
        Bloc(
            header: 'Growerp Applications',
            content: TextSpan(children: <TextSpan>[
              _text('We are working on the following apps:\n'),
              _textLink('https://ecommerce.growerp.com', '1. ecommerce\n'),
              _text('2. restaurant\n'),
              _text('3. hotel.\n\n'),
            ])),
      ],
    )));
  }
}

TextSpan _textLink(final String url, final String text) {
  return TextSpan(
      text: text,
      style: TextStyle(
          color: Colors.blueAccent, decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          if (await canLaunch(url)) {
            await launch(url, forceSafariVC: false);
          }
        });
}

TextSpan _text(final String text) {
  return TextSpan(text: text, style: TextStyle(color: Colors.black));
}
