import 'blocs/auth_bloc_test.dart' as auth_bloc;
import 'blocs/login_bloc_test.dart' as login_bloc;
import 'forms/login_form_test.dart' as login_form;
import 'blocs/catalog_bloc_test.dart' as catalog_bloc;
import 'forms/register_form_test.dart' as register_form;
import 'blocs/changePw_bloc_test.dart' as changePw_bloc;

void main() {
  // _blocs
  auth_bloc.main();
  login_bloc.main();
  catalog_bloc.main();
  changePw_bloc.main();

  // _forms
  login_form.main();
  register_form.main();

  // _widgets

  // _localization
  
}
