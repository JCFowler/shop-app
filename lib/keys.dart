const _FIREBASE_API_KEY = 'AIzaSyCbVNnLRfDoWcueFQuiD3T77Pic-JhULwA';

const FIREBASE_URL =
    'https://my-shop-tutorial-default-rtdb.asia-southeast1.firebasedatabase.app/';

const SIGN_UP_URL =
    'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_FIREBASE_API_KEY';
const SIGN_IN_URL =
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_FIREBASE_API_KEY';

const _PRODUCTS_URL = '${FIREBASE_URL}products';
const _FAVORITES_URL = '${FIREBASE_URL}userFavorites';
const _ORDERS_URL = '${FIREBASE_URL}orders';

String PRODUCTS_BASE_URL(String token) {
  return '$_PRODUCTS_URL.json?auth=$token';
}

String FETCH_PRODUCTS_URL(String token, String userId, bool filterByUser) {
  if (filterByUser) {
    return '$_PRODUCTS_URL.json?auth=$token&orderBy="creatorId"&equalTo="$userId"';
  } else {
    return '$_PRODUCTS_URL.json?auth=$token';
  }
}

String PRODUCT_ID_URL(String token, String id) {
  return '$_PRODUCTS_URL/$id.json?auth=$token';
}

String ALL_FAVORITES_URL(String token, String userId) {
  return '$_FAVORITES_URL/$userId.json?auth=$token';
}

String FAVORITES_ID_URL(String token, String productId, String userId) {
  return '$_FAVORITES_URL/$userId/$productId.json?auth=$token';
}

String ORDERS_URL(String token, String userId) {
  return '$_ORDERS_URL/$userId.json?auth=$token';
}
