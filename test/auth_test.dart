import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Mock authentication',
    () {
      final provider = MockAuthProvider();

      test('should not be initialized to begin with', () {
        expect(provider._isIinitialized, false);
      });

      test('cannot logout if not initialized', () {
        expect(provider.logOut(),
            throwsA(const TypeMatcher<NotInitializedException>()));
      });

      test('should be able to be initialized', () async {
        await provider.inititalize();
        expect(provider._isIinitialized, true);
      });

      test('user should be null after initialization', () {
        expect(provider.currentUser, null);
      });

      test(
        'should be able to initialize in less than 2 seconds',
        () async {
          await provider.inititalize();
          expect(provider._isIinitialized, true);
        },
        timeout: const Timeout(Duration(seconds: 2)),
      );

      test('create user should delegate to login functions', () async {
        final badEmailUser = provider.createUser(
          email: 'foo@bar.com',
          password: 'anypassword',
        );
        expect(badEmailUser,
            throwsA(const TypeMatcher<UserNotFoundAuthException>()));

        final badPasswordUser = provider.createUser(
          email: 'someone@bae.com',
          password: 'foobar',
        );
        expect(badPasswordUser,
            throwsA(const TypeMatcher<WrongPasswordAuthException>()));

        final user = await provider.createUser(
          email: 'foo',
          password: 'bar',
        );
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, false);
      });

      test('logged in user should be able to get verified', () {
        provider.sendEmailVerification();
        final user = provider.currentUser;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
      });

      test('should be able to logout and login again', () async {
        await provider.logOut();
        await provider.login(
          email: 'email',
          password: 'password',
        );
      });
    },
  );
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isIinitialized = false;
  bool get isInitialized => _isIinitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> inititalize() {
    // TODO: implement inititalize
    throw UnimplementedError();
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
