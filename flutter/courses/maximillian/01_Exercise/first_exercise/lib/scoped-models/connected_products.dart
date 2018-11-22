import 'dart:convert' as Convert;
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/user.dart';

class ConnectedProducts extends Model {
  List<Product> _products = [];
  int _selProductIndex;

  User _authenticatedUser;

  void addProduct(
    String title,
    String description,
    String image,
    double price,
  ) {
    final Map<String, dynamic> productData = {
      title: title,
      'description': description,
      'image':
          'https://www.livemint.com/rf/Image-621x414/LiveMint/Period2/2017/10/31/Photos/Processed/fruits-kFLF--621x414@LiveMint.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    http
        .post(
      'https://flutter-products-gs.firebaseio.com/products.json',
      body: Convert.json.encode(productData),
    )
        .then((http.Response response) {
          final Map<String, dynamic> responseData =
              Convert.json.decode(response.body);
          print(responseData);
          final Product newProduct = Product(
              id: responseData['name'],
              title: title,
              description: description,
              image: image,
              price: price,
              userEmail: _authenticatedUser.email,
              userId: _authenticatedUser.id);
          _products.add(newProduct);
          notifyListeners();
    });
  }
}

mixin ProductsModel on ConnectedProducts {
  bool _showFavorites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(
          _products.where((Product product) => product.isFavorite).toList());
    }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _selProductIndex;
  }

  Product get selectedProduct {
    if (selectedProductIndex == null) {
      return null;
    } else {
      return _products[selectedProductIndex];
    }
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  void deleteProduct() {
    _products.removeAt(selectedProductIndex);
  }

  void fetchProducts() {
    http
        .get('https://flutter-products-gs.firebaseio.com/products.json')
        .then((http.Response response) {

          final List<Product> fetchedProductList = [];
          final Map<String, dynamic> productListData =
              Convert.json.decode(response.body);
          print('FETCH PRODUCT');
          print(productListData);
          productListData
              .forEach((String productId, dynamic productData) {
            final Product product = Product(
                id: productId,
                title: productData['title'],
                description: productData['description'],
                image: productData['image'],
                price: productData['price'],
                userEmail: productData['userEmail'],
                userId: productData['userId']
            );
            fetchedProductList.add(product);
          });
      _products = fetchedProductList;
      notifyListeners();
    });
  }

  void updateProduct(
    String title,
    String description,
    String image,
    double price,
  ) {
    final Product updatedProduct = Product(
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id);
    _products[selectedProductIndex] = updatedProduct;
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = _products[selectedProductIndex].isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
      title: selectedProduct.title,
      description: selectedProduct.description,
      price: selectedProduct.price,
      image: selectedProduct.image,
      userEmail: _authenticatedUser.email,
      userId: _authenticatedUser.id,
      isFavorite: newFavoriteStatus,
    );
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void selectProduct(int index) {
    _selProductIndex = index;
    if (_selProductIndex != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProducts {
  void login(String email, String password) {
    _authenticatedUser = User(
      id: '12345',
      email: email,
      password: password,
    );
  }
}