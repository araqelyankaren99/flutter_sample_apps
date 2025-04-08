import 'dart:convert';

import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/constants.dart';
import 'package:flutter_sample_apps/middlewares/extension/string.dart';
import 'package:flutter_sample_apps/models/direction.dart';
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/models/road_info.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/token_info.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql/client.dart';

enum ErrorType { customError, serverError }

class GraphQlRepository {
  GraphQlRepository();

  GraphQLClient getGithubGraphQLClient() {
    final Link link = HttpLink(constants.getGraphQlLink());

    return GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  Future<String?> getDriverToken() async {
    final token = await TokenInfo.getToken();
    return token;
  }

  GraphQLClient getGithubGraphQLClientHeader({required String token}) {
    final Link link = HttpLink(constants.getGraphQlLink(),
        defaultHeaders: {'authentication': 'Bearer $token'},);

    return GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  /// Verify phone number, will return String(6 digits), it will be token in future requests
  Future<QueryResult> verifyPhone({required String phoneNumber}) async {
    final document = '''
        mutation {
           verifyPhone(phone: "$phoneNumber")
        }
      ''';
    final result = await _query(document: document);
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

  /// Return  authToken for creating driver
  Future<QueryResult> authenticateDriver(
      {required String token, required String phoneNumber,}) async {
    final document = '''
        mutation {
           authenticateDriver(token: "$token",phone: "$phoneNumber"){
            authToken
            tokenExpiresAfter
            refreshToken
            refreshTokenExpiresAfter
           }
        }
      ''';

    final result = await _query(document: document);
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

  Future<QueryResult> createDriverProfile(
      {required String token, required Driver driver,}) async {
    final document = '''
        mutation {
           createDriverProfile(${driver.toString()}){
            id
           }
        }
      ''';

    final result = await _query(document: document, token: token);
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

  /// Returns frequently asked questions (FAQ)
  Future<QueryResult> getFAQ() async {
    const document = '''
        query { 
          getFaqsForDriver{
            id
            question
            answer
          }
        }
        ''';
    final driverToken = await getDriverToken();

    final result = await _query(document: document, token: driverToken);
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
    final userToken = await getDriverToken();
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

  /// Returns false if phone number is already taken, otherwise returns true
  Future<QueryResult> checkPhone({required String phoneNumber}) async {
    final document = '''
                      mutation{
                        checkPhone(phone: "$phoneNumber")
                      }
                  ''';

    final driverToken = await getDriverToken();

    final result = await _query(document: document, token: driverToken);
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

  /// This method changes driver's phone number and returns new token
  Future<QueryResult> authenticateDriverEdit(
      {required String code, required String phoneNumber,}) async {
    final document = '''
                    mutation {
                      authenticateDriverEdit(token: "$code", phone: "$phoneNumber"){
                        refreshToken
                      }
                    }
                  ''';
    final userToken = await getDriverToken();
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

  Future<RoadInfo?> getRoad(
      {required LatLng origin, required LatLng destination,}) async {
    final document = '''
    mutation {
       getRoad(fromLat: ${origin.latitude}, fromLng: ${origin.longitude}, toLat: ${destination.latitude}, toLng: ${destination.longitude})
      }
      ''';

    final userToken = await TokenInfo.getToken();
    final result = await _query(document: document, token: userToken);
    if (result.data != null && !result.hasException) {
      final data = result.data;
      if (data != null) {
        final result = data['getRoad'] as String;
        final jsonData = json.decode(result) as Map<String, dynamic>;
        final routes = jsonData['routes'][0];
        final legs = routes['legs'][0];
        final distance = legs['distance'];
        final amount = distance['money'] as String;
        final km = distance['value'];
        final miles = km * milesCoefficient / 1000 as double;

        return RoadInfo(
            amount: double.parse(amount),
            miles: miles,
            direction: Direction.fromMap(jsonData),);
      }
    }
    return null;
  }

  Future<QueryResult> _query({required String document, String? token}) async {
    final client = token == null
        ? getGithubGraphQLClient()
        : getGithubGraphQLClientHeader(token: token);

    final options = MutationOptions(
      fetchPolicy: FetchPolicy.noCache,
      document: gql(
        document,
      ),
    );

    final result = await client.mutate(options);

    return result;
  }

  Stream<QueryResult> _subscribe(
      {required SubscriptionOptions document, required String token,}) async* {
    final client = clientFor(
      uri: constants.getGraphQlLink(),
      subscriptionUri: constants.getSubscriptionEndpoint(),
      token: token,
    );
    yield* client.subscribe(document);
  }

  // returns phoneNumber if user is registred
  Future<QueryResult> getDriver(String token) async {
    const document = '''
        query{ 
          thisDriver{
            phone
            
          }
        }
        ''';
    final result = await _query(document: document, token: token);
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

  /// Return true if driver is activated
  Future<QueryResult> driverIsActivated(String token) async {
    const document = '''
        query{ 
          thisDriver{
            isActivated
          }
        }
        ''';

    final result = await _query(document: document, token: token);
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

  /// Return true if driver is editable
  Future<QueryResult> driverIsEditable(String token) async {
    const document = '''
        query{ 
          thisDriver{
            isProved
          }
        }
        ''';

    final result = await _query(document: document, token: token);
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

  // returns carId if user is registred else null
  Future<QueryResult> getCar(String token) async {
    const document = '''
        query{ 
          thisUser{
            userCar{
            id
            }
          }
        }
        ''';

    final result = await _query(document: document, token: token);

    return result;
  }

  /// Returns admin phone number
  Future<String?> getAdminPhoneNumber() async {
    final driverToken = await getDriverToken();

    const document = '''
        query{
         adminPhone
        }
        ''';

    final result = await _query(document: document, token: driverToken);

    if (result.hasException) {
      final exception = result.exception;
      if (exception != null) {
        throw Exception(exception.graphqlErrors.first.message);
      }
      throw Exception('Something went wrong');
    } else {
      if (result.data != null) {
        final data = result.data;
        if (data != null) {
          return data['adminPhone'] as String?;
        }
      }
    }
    return null;
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

    final userToken = await getDriverToken();
    final result = await _query(document: document, token: userToken);
    return result;
  }

  Future<QueryResult> editUserProfile(
      {required Map<String, dynamic> userEditedInfoMap,}) async {
    final userEditedInfoMapToString = userEditedInfoMap.toString();
    final withoutBlankets = userEditedInfoMapToString.removeBrackets();

    final document = '''
       mutation{
        editUserProfile($withoutBlankets){
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
          }=pp[[h]]
        }
      }
      ''';

    final userToken = await getDriverToken();
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

  /// This method returns all unconfirmed orders
  Future<QueryResult> unconfirmedOrders() async {
    const document = '''
        query{
          unconfirmedOrders{
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
             userCar{
              id
              licensePlateNumber
              color
              car{
                createdYear
                make
                model
                transmissionType
                horsepower
            		img_url
              }
            }
          }
          fromLat
          fromLng
          toLat
          toLng
          mile
          distanceBetweenDriver
          }
        }
    ''';

    final driverToken = await getDriverToken();
    final result = await _query(document: document, token: driverToken);
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

  GraphQLClient clientFor(
      {required String uri, String? subscriptionUri, String? token,}) {
    Link link =
        HttpLink(uri, defaultHeaders: {'authentication': 'Bearer $token'});
    if (subscriptionUri != null) {
      final websocketLink = WebSocketLink(
        subscriptionUri,
        config: SocketClientConfig(
            inactivityTimeout: const Duration(seconds: 1000),
            initialPayload: {'authentication': 'Bearer $token'},),
      );

      link =
          Link.split((request) => request.isSubscription, websocketLink, link);
    }

    return GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    );
  }

//This method returns Driver's info
  Future<QueryResult> getDriverInfo() async {
    const document = '''
        query{
          thisDriver{
            id
            phone
            rating
            firstName
            lastName
            birthDate
            isProved
            city
            email
            attachment{
              name
              uploadLink
              downloadLink
            }
          }
        }
        ''';

    final driverToken = await getDriverToken();

    final result = await _query(document: document, token: driverToken);

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

//This method returns Driver's orders with 'FINISHED' and 'CANCELED' states and sorted in descending order by
  Future<QueryResult> getDriverOrders() async {
    const document = '''
        mutation{
          sortDriverOrdersWithState(how: -1, sortBy: "createdDate", states: ["FINISHED", "CANCELED"]){
		        id
            amount
            createdDate
            destination
  	        from
            dueDate
            state
            km
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
            driver{
              firstName
              lastName
              birthDate
              city
              attachment{
                uploadLink
                downloadLink
                name
              }
            }
          }
        }
        ''';
    final driverToken = await getDriverToken();
    final result = await _query(document: document, token: driverToken);
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

  //Return the list of cities
  Future<QueryResult> getCitiesByCountry(
      {required String token, required String country,}) async {
    final document = '''
      query{
        getCountry(country:"$country"){
        city
         }
       }
        ''';

    final result = await _query(document: document, token: token);
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

//This function create and return link for uploading image
  Future<QueryResult> getLinks(
      {required String token,
      required String contentType,
      required String name,}) async {
    final document = '''
    mutation {
      createAttachment(contentType:"$contentType", name: "$name"){
           uploadLink
           downloadLink
}
}
''';

    final result = await _query(document: document, token: token);
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

  /// This function subscribes to driver and checks his activity
  Stream<QueryResult> subscribeToDriverActivation(
      {required String token,}) async* {
    try {
      final options = SubscriptionOptions(
        document: gql(
          '''
  subscription {
   driverStatusChanged{
    isActivated
    isProved
   } 
  }
  ''',
        ),
      );
      final subscription = _subscribe(document: options, token: token);
      yield* subscription;
    } catch (e) {
      debugPrint('Driver status changed subscription error');
    }
  }

  Future<QueryResult> editDriverProfile({required Driver driver}) async {
    final document = '''
       mutation{
        editDriverProfile(${driver.toString()}){
          id
        }
      }
      ''';

    final userToken = await getDriverToken();
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

  Future<QueryResult> confirmOrder({required String orderId}) async {
    final document = '''
    mutation {
    confirmOrder(orderId: "$orderId") 
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
        }
      }
    ''';
    final driverToken = await getDriverToken();
    final result = await _query(document: document, token: driverToken);
    if (result.hasException) {
      final exception = result.exception;
      if (exception != null) {
        throw Exception(ErrorType.serverError);
      }
      throw Exception(ErrorType.customError);
    } else {
      return result;
    }
  }

  Future<QueryResult> startOrder({required String orderId}) async {
    final document = '''
    mutation {
    startOrder(orderId: "$orderId") {
      id
      state
  }
}
    
    ''';
    final driverToken = await getDriverToken();
    final result = await _query(document: document, token: driverToken);
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

  Future<QueryResult> awaitUser({required String orderId}) async {
    final document = '''
    mutation {
  awaitUser(orderId: "$orderId") {
    id
    state
  }
}
    ''';
    final driverToken = await getDriverToken();
    final result = await _query(document: document, token: driverToken);
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

  Future<QueryResult> finishOrder({required String orderId}) async {
    final document = '''
    mutation {
  finishOrder(orderId: "$orderId") {
    id
    state
  }
}
    ''';

    final driverToken = await getDriverToken();
    final result = await _query(document: document, token: driverToken);
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

  Future<QueryResult> cancelOrder({required String orderId}) async {
    final document = '''
    mutation 
    {
      cancelOrder(
        orderId: "$orderId",
      )
      {
        id
        state
      }
    }
    ''';

    final userToken = await getDriverToken();
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

  /// This method changes driver phone number and returns new token
  Future<QueryResult>  createOrUpdateFirebaseCloudMessagingTokenForDriver(
      {required String firebaseToken,}) async {
    final driverToken = await getDriverToken();
    final document = '''
        mutation{
          createOrUpdatePushTokenForDriver(
            token: "$firebaseToken"
          )
        }
        ''';

    final result = await _query(document: document, token: driverToken);
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

  Future<QueryResult> updateDriverLocation(
      {required LatLng currentLocation,}) async {
    final driverToken = await getDriverToken();
    final document = '''
        mutation{
  updateDriverLocation(
    lat: ${currentLocation.longitude},
    lng: ${currentLocation.latitude}
  )
}
        ''';
    final result = await _query(document: document, token: driverToken);

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

  Stream<QueryResult> subscribe(
      {required String token, required String lastOrderId,}) async* {
    try {
      final options = SubscriptionOptions(
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
      final subscription = _subscribe(document: options, token: token);
      yield* subscription;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Get user's order information by order ID
  Future<QueryResult> getOrder(String orderId) async {
    final token = await getDriverToken();

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
    km
    distanceBetweenDriver
  }
}
        ''';

    final result = await _query(document: document, token: token);
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
}
