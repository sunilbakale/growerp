import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../bloc/@bloc.dart';
import '../models/@models.dart';

class HomeForm extends StatefulWidget {
  final Authenticate authenticate;

  const HomeForm({Key key, this.authenticate}) : super(key: key);
  @override
  State<HomeForm> createState() => _HomeState(authenticate);
}

class _HomeState extends State<HomeForm> {
  List<Product> products;
  List<Category> categories;
  String selectedCategoryId;
  final Authenticate authenticate;

  _HomeState(this.authenticate);

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<CatalogBloc, CatalogState>(
            listener: (context, state) {
              if (state is CatalogError) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.errorMessage}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthConnectionProblem) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.errorMessage}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          )],
          child: BlocBuilder<CatalogBloc, CatalogState>(
          builder: (context, state) {
            if (state is CatalogLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CatalogError) {
              return Center(
                child: RaisedButton(
                    child: Text(state.errorMessage + '\nRetry?'),
                    onPressed: () {
                      BlocProvider.of<CatalogBloc>(context).add(LoadCatalog());
                    }),
              );
            } else if (state is CatalogLoaded) {
              selectedCategoryId ??=
                  state.catalog.categories[0].productCategoryId;
              categories = state.catalog.categories;
              products = state.catalog.products;
              return Scaffold(
                appBar: AppBar(
                  title:
                      Text(authenticate?.company?.name ?? 'GrowERP E-commerce'),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.shopping_cart),
                      tooltip: 'Cart',
                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                    ),
                    if (BlocProvider.of<AuthBloc>(context).state
                        is AuthUnauthenticated)
                      IconButton(
                          icon: Icon(Icons.exit_to_app),
                          tooltip: 'Login',
                          onPressed: () =>
                              BlocProvider.of<AuthBloc>(context).add(Login())),
                    if (BlocProvider.of<AuthBloc>(context).state
                        is AuthAuthenticated)
                      IconButton(
                          icon: Icon(Icons.do_not_disturb),
                          tooltip: 'Logout',
                          onPressed: () =>
                              BlocProvider.of<AuthBloc>(context).add(Logout())),
                  ],
                ),
                body: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      _categoryList(),
                      _productsGrid(),
                    ],
                  ),
                ),
              );
            } else
              return null;
          },
        ));
  }

  Widget _categoryList() {
    return Container(
      height: 110,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          var data = categories[index];
          return Column(children: <Widget>[
            GestureDetector(
              onTap: () =>
                  setState(() => selectedCategoryId = data.productCategoryId),
              child: Container(
                margin: EdgeInsets.all(10),
                width: 70,
                height: 70,
                alignment: Alignment.center,
                child: Image(
                  image: data.image,
                  height: 40,
                  width: 40,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 5),
                      blurRadius: 30,
                    )
                  ],
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Text(data.categoryName),
                Icon(
                  Icons.keyboard_arrow_right,
                  size: 14,
                )
              ],
            )
          ]);
        },
      ),
    );
  }

  Widget _productsGrid() {
    List<Product> products = this
        .products
        .where((i) => i.productCategoryId == selectedCategoryId)
        .toList();
    Size size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(35),
        bottomRight: Radius.circular(35),
      ),
      child: Container(
        height: screenHeight - 100,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Color(0xffECE9DE),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 50, bottom: 5),
              width: screenWidth,
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 4,
                itemCount: products.length,
                itemBuilder: (BuildContext context, int index) => new Container(
                    margin: EdgeInsets.only(
                      left: index % 2 == 0 ? 10 : 0,
                      right: index % 2 == 0 ? 0 : 10,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25)),
                    child: Center(
                      child: _gridItem(products[index]),
                    )),
                staggeredTileBuilder: (int index) =>
                    new StaggeredTile.count(2, index == 0 ? 2 : 3),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
            ),
            _customTitle(categories
                .firstWhere((i) => i.productCategoryId == selectedCategoryId)
                .categoryName)
          ],
        ),
      ),
    );
  }

  Widget _gridItem(product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/details',
          arguments: <String, dynamic>{'product': product}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
              child: Hero(
                  tag: '${product.productId}',
                  child: Image(
                    image: product.image,
                    height: 125,
                    fit: BoxFit.contain,
                  ))),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(product.price.toString(),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
/*          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text('${product.weight}g'),
          )
*/
        ],
      ),
    );
  }

  Widget _customTitle(title) {
    Size size = MediaQuery.of(context).size;
    double screenWidth = size.width;

    return Container(
      width: screenWidth,
      height: 60,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Center(
        child: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: <Color>[
          Color(0xffECE9DE),
          Color(0xffefebe9),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
    );
  }
}
