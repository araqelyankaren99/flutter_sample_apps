import 'dart:async';
import 'dart:convert';
import 'package:flutter_sample_apps/src/middlewares/extensions/datetime.dart';
import 'package:flutter_sample_apps/src/middlewares/extensions/string.dart';
import 'package:flutter_sample_apps/src/models/direction.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/models/road_info.dart';
import 'package:flutter_sample_apps/src/models/user.dart';
import 'package:flutter_sample_apps/src/screens/map_view/shared/token_info.dart';
import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/screens/profile/payment/stripe_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQlRepository {
  GraphQlRepository();

  GraphQLClient getGithubGraphQLClient() {
    final link = HttpLink(
      constants.getGraphQlLink(),
    );

    return GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  Future<String?> getUserToken() async {
    final token = await TokenInfo.getToken();
    return token;
  }

  Future<String?> getOrderId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('order_id');
  }

  GraphQLClient getGithubGraphQLClientHeader({required String token}) {
    final link = HttpLink(constants.getGraphQlLink(),
        defaultHeaders: {'Authentication': 'Bearer $token'});

    return GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  /// This method returns ephemeral key
  Future<String> getEphemeralKey() async {
    const apiVersion = StripePreferences.apiVersion;
    const document = '''
        mutation {
           ephemeralKey(apiVersion: "$apiVersion")
        }
      ''';
    final userToken = await getUserToken();

    final result = await _query(document: document, token: userToken);

    final data = result.data;
    if (data != null) {
      return data['ephemeralKey'];
    }
    return '';
  }

  /// Checks customer has payment method or not
  Future<QueryResult> hasPaymentMethod() async {
    const document = '''
        query { 
          paymentMethods{
            id
          }
        }
        ''';

    final userToken = await getUserToken();

    final result = await _query(document: document, token: userToken);

    return result;
  }

  Future<QueryResult> getMinimalAmount() async {
    const document = '''
       query{ 
          _getPrices
        }
    ''';

    final userToken = await getUserToken();

    final result = await _query(document: document, token: userToken);

    return result;
  }

  /// Verify phone number, will return String(6 digits), it will be token in future requests
  Future<QueryResult> verifyPhone({required String phoneNumber}) async {
    final document = '''
        mutation {
           verifyPhone(phone: "$phoneNumber")
        }
      ''';

    final result = await _query(document: document);

    return result;
  }

  /// This is method for rating driver
  Future<QueryResult> rateDriver(
      String orderID, double rating, String comment) async {
    final document = '''
        mutation {
           rateDriver(orderId: "$orderID",
           comment: "${comment.replaceAll('\n', ' ')}",
           rate: $rating,
           ){
           }
        }
      ''';
    final userToken = await getUserToken();

    final result = await _query(document: document, token: userToken);

    return result;
  }

  /// Return  authToken for creating user
  Future<QueryResult> authenticateUser(
      {required String token, required String phoneNumber}) async {
    final document = '''
        mutation {
           authenticateUser(token: "$token",phone: "$phoneNumber"){
            authToken
            tokenExpiresAfter
            refreshToken
            refreshTokenExpiresAfter
           }
        }
      ''';

    final result = await _query(document: document);

    return result;
  }

  Future<QueryResult> createUserProfile(
      {required String token, required User user}) async {
    final document = '''
        mutation {
           createUserProfile(${user.toString()}){
            id
           }
        }
      ''';

    final result = await _query(document: document, token: token);

    return result;
  }

  /// Returns frequently asked questions (FAQ)
  Future<QueryResult> getFAQ() async {
    const document = '''
        query { 
          getFaqsForUser{
            id
            question
            answer
          }
        }
        ''';
    final userToken = await getUserToken();
    final result = await _query(document: document, token: userToken);

    return result;
  }

  /// Returns user's orders with FINISHED status and sorted in descending order
  Future<QueryResult> userOrders() async {
    const document = '''
        mutation{
          sortUserOrdersWithState(how: -1, sortBy: "createdDate", state: "FINISHED"){
	          id
            amount
            comment
            createdDate
            destination
            invoice{
              pdf
            }
            driver{
              id
              firstName
              lastName
              phone
              rating
              birthDate
              city
              email
            }
            dueDate
            from
            state
            user{
              id
            }
          }
        }
        ''';
    final userToken = await getUserToken();
    final result = await _query(document: document, token: userToken);

    if (result.hasException) {
      final exception = result.exception;
      if (exception != null) {
        throw Exception(exception.graphqlErrors.first.message);
      }
      throw Exception('Something went wrong');
    } else {
      return result;
    }
  }

  /// Returns about app text
  Future<QueryResult> getAbout() async {
    const document = '''
        query { 
          about
        }
        ''';
    final userToken = await getUserToken();

    final result = await _query(document: document, token: userToken);

    return result;
  }

  Future<QueryResult> _query({required String document, String? token}) async {
    final _client = token == null
        ? getGithubGraphQLClient()
        : getGithubGraphQLClientHeader(token: token);

    final options = MutationOptions(
      fetchPolicy: FetchPolicy.noCache,
      document: gql(
        document,
      ),
    );

    final result = await _client
        .mutate(options)
        .timeout(const Duration(minutes: 2), onTimeout: () {
      throw Exception('time out');
    });
    return result;
  }

  /// Returns phoneNumber if user is registred
  Future<QueryResult> getUser(String token) async {
    const document = '''
        query{ 
          thisUser{
            phone
          }
        }
        ''';

    final result = await _query(document: document, token: token);

    return result;
  }

  Future<RoadInfo?> getRoad(
      {required LatLng origin, required LatLng destination}) async {
    final document = '''
    mutation {
       getRoad(fromLat: ${origin.latitude}, fromLng: ${origin.longitude}, toLat: ${destination.latitude}, toLng: ${destination.longitude})
      }
      ''';

    final userToken = await getUserToken();
    final result = await _query(document: document, token: userToken);
    if (result.data != null && !result.hasException) {
      final data = result.data;
      if (data != null) {
        final result = data['getRoad'];
        final jsonData = json.decode(result) as Map<String, dynamic>;
        final routes = jsonData['routes'][0];
        final legs = routes['legs'][0];
        final distance = legs['distance'];
        final amount = distance['money'] as String;
        final m = distance['value'];
        final miles = m / constants.milesCoefficient;

        return RoadInfo(
            amount: double.parse(amount),
            miles: miles,
            direction: Direction.fromMap(jsonData));
      }
    }
    return null;
  }

  /// User's order query
  Future<QueryResult> _getOrder(String orderId) async {
    final token = await getUserToken() ?? '';

    final document = '''
      query {
  order(orderId: "$orderId") {
    id
    amount
    comment
    createdDate
    destination
    dueDate
    from
    driver {
      id
      firstName
      lastName
      phone
      rating
      birthDate
      city
      email
    }
    user {
      id
      phone
      email
      firstName
      lastName
      birthDate
      country
      city
    }
    state
    fromLat
    fromLng
    toLat
    toLng
    rating
    mile
  }
}
        ''';

    final result = await _query(document: document, token: token);
    if (result.data != null) {
      return result;
    } else {
      throw Exception('Get order Error');
    }
  }

  /// Get user's order information by order ID
  Future<Order?> getOrder(String orderId) async {
    final result = await _getOrder(orderId);
    final _data = result.data;
    if (_data != null) {
      final _order = _data['order'];
      return Order.fromJson(_order);
    }
    return null;
  }

  /// Get user's order status state by order ID
  Future<String> getOrderStatusState(String orderId) async {
    final result = await _getOrder(orderId);

    final _data = result.data;
    if (_data != null) {
      final _orderStatusState = _data['order']['state'];
      return _orderStatusState;
    } else {
      throw Exception('Get order status state Error');
    }
  }

  /// Send driver request
  Future<Order?> createOrder(Order order) async {
    final document = '''
      mutation {
        createOrder(
          orderInput:
          {
            from: "${order.from}", 
            destination: "${order.destination}", 
            comment: "${order.comment?.replaceAll('\n', ' ') ?? ''}",
            amount: ${order.amount},
            dueDate:"${order.dueDate.difference(DateTime.now()).inMinutes > 0 ? order.dueDate.toIso8601String() : DateTime.now().get20MinutesLaterRounded().toIso8601String()}",
            fromLat:${order.fromLat},
            fromLng:${order.fromLng},
            toLat: ${order.toLat},
            toLng: ${order.toLng},
            mile: ${order.mile}
          }
        )
        {
          id
          amount
          comment
          createdDate
          destination
          dueDate
          from
          state
          user{
            id
            phone
            email
            firstName
            lastName 
            birthDate 
            country
            city
          }
          fromLat
          fromLng
          toLat
          toLng
          mile
        }
      }
      ''';
    final userToken = await getUserToken();
    final result = await _query(document: document, token: userToken);
    if (result.data != null && !result.hasException) {
      final data = result.data;
      if (data != null) {
        final order = Order.fromJson(data['createOrder']);
        await _setOrderIdInSharedPrefs(order.id);
        return order;
      }
    } else {
      throw Exception();
    }
    return null;
  }

  Future<void> _setOrderIdInSharedPrefs(String orderId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('order_id', orderId);
  }

  /// Cancel driver request
  Future<OrderStatus> cancelOrder(Order order) async {
    final document = '''
    mutation 
    {
      cancelOrder(
        orderId: "${order.id}"
      )
      {
        id
        state
      }
    }
    ''';
    final userToken = await getUserToken();
    final result = await _query(document: document, token: userToken);
    if (result.data != null) {
      final data = result.data;
      if (data != null) {
        return StateExtension.castStringToStatusEnum(
            data['cancelOrder']['state']);
      } else {
        throw Exception();
      }
    }
    return OrderStatus.none;
  }

  Future<QueryResult> getUserInfo() async {
    const document = '''
        query{ 
          thisUser{
            id
            firstName
            lastName
            phone
            email
            birthDate
            country
            city
          }
        }
        ''';

    final userToken = await getUserToken();
    final result = await _query(document: document, token: userToken);
    return result;
  }

  Future<QueryResult> editUserProfile(
      {required Map<String, dynamic> userEditedInfoMap}) async {
    final userEditedInfo = userEditedInfoMap.toString().removeBrackets();

    final document = '''
       mutation{
        editUserProfile($userEditedInfo){
          id
          phone
          email
          firstName
          lastName
          birthDate
          role
          attachment{
            downloadLink
            uploadLink
          }
        }
      }
      ''';

    final userToken = await getUserToken();
    final result = await _query(document: document, token: userToken);

    return result;
  }

  /// This method returns false if phone is already taken and true if phone number doesn't have an account
  Future<QueryResult> checkPhone({required String phoneNumber}) async {
    final document = '''
        mutation{
          checkPhone(phone: "$phoneNumber")
        }
        ''';

    final userToken = await getUserToken();
    final result = await _query(document: document, token: userToken);

    return result;
  }

  /// This method changes user phone number and returns new token
  Future<QueryResult> authenticateUserEdit(
      {required String code, required String phoneNumber}) async {
    final document = '''
        mutation{
          authenticateUserEdit(token: "$code", phone: "$phoneNumber"){
            refreshToken
          }
        }
        ''';

    final userToken = await getUserToken();
    final result = await _query(document: document, token: userToken);
    return result;
  }

  /// Subscribe to order state changes
  Stream<QueryResult> subscribeToStates(
      WebSocketLink webSocketLink, String token) async* {
    final lastOrderId = await getOrderId();
    final client = clientFor(
      uri: constants.getGraphQlLink(),
      websocketLink: webSocketLink,
      subscriptionUri: constants.getSubscriptionEndpoint(),
      token: token,
    );

    final _options = SubscriptionOptions(
      document: gql(
        '''
      subscription {
        orderChanged(orderId: "$lastOrderId") {
          id
          driver {
            id
            phone
            rating
            firstName
            lastName
            birthDate
            city
            email
          }
          state
        }
      }
  ''',
      ),
    );

    yield* client.subscribe(_options);
  }

  /// This method changes user phone number and returns new token
  Future<String> createOrUpdateFirebaseCloudMessagingTokenForUser(
      {required String firebaseToken}) async {
    final userToken = await getUserToken();
    final document = '''
        mutation{
          createOrUpdatePushTokenForUser(
            token: "$firebaseToken"
          )
        }
        ''';
    final result = await _query(document: document, token: userToken);
    final data = result.data;
    if (data != null) {
      return data['createOrUpdatePushTokenForUser'];
    } else {
      throw Exception('Something went wrong!');
    }
  }

  /// Subscription graphql client configs
  GraphQLClient clientFor(
      {required String uri,
      required WebSocketLink websocketLink,
      String? subscriptionUri,
      String? token}) {
    Link link =
        HttpLink(uri, defaultHeaders: {'authentication': 'Bearer $token'});
    if (subscriptionUri != null) {
      link =
          Link.split((request) => request.isSubscription, websocketLink, link);
    }

    return GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    );
  }
}
