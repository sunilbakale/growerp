// _copyright 2018 _the _flutter _architecture _sample _authors. _all rights reserved.
// _use of this source code is governed by the _m_i_t license that can be found
// in the _l_i_c_e_n_s_e file.

import 'blocs/auth_bloc_test.dart' as auth_bloc;
import 'blocs/login_bloc_test.dart' as login_bloc;
import 'forms/login_form_test.dart' as login_form;
import 'blocs/catalog_bloc_test.dart' as catalog_bloc;
import 'forms/register_form_test.dart' as register_form;

void main() {
  // _blocs
  auth_bloc.main();
  login_bloc.main();
  catalog_bloc.main();

  // _forms
  login_form.main();
  register_form.main();

  // _widgets

  // _localization
  
}
