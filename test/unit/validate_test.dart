import 'package:flutter_test/flutter_test.dart';
import 'package:cosmox_client_flutter/core/common.dart';

void main() {
  group('Validate', () {
    group('username', () {
      test('returns error message when username is null', () {
        expect(Validate.username(null), isNotNull);
      });

      test('returns error message when username is empty', () {
        expect(Validate.username(''), isNotNull);
      });

      test('returns null for valid username', () {
        expect(Validate.username('admin'), isNull);
      });

      test('returns null for username with numbers', () {
        expect(Validate.username('user123'), isNull);
      });
    });

    group('password', () {
      test('returns error message when password is null', () {
        expect(Validate.password(null), isNotNull);
      });

      test('returns error message when password is empty', () {
        expect(Validate.password(''), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validate.password('password123'), isNull);
      });
    });

    group('email', () {
      test('returns error message when email is null', () {
        expect(Validate.email(null), isNotNull);
      });

      test('returns error message when email is empty', () {
        expect(Validate.email(''), isNotNull);
      });

      test('returns error message for invalid email format', () {
        expect(Validate.email('notanemail'), isNotNull);
        expect(Validate.email('@example.com'), isNotNull);
        expect(Validate.email('test@'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validate.email('test@example.com'), isNull);
        expect(Validate.email('user.name@domain.org'), isNull);
      });
    });

    group('path', () {
      test('returns error message when path is null', () {
        expect(Validate.path(null), isNotNull);
      });

      test('returns error message when path is empty', () {
        expect(Validate.path(''), isNotNull);
      });

      test('returns null for valid path', () {
        expect(Validate.path('/media'), isNull);
        expect(Validate.path('/home/user/documents'), isNull);
      });
    });

    group('serverAddress', () {
      test('returns error when address is null', () {
        expect(Validate.serverAddress(null), isNotNull);
      });

      test('returns error when address is empty', () {
        expect(Validate.serverAddress(''), isNotNull);
      });

      test('returns error for invalid address format', () {
        expect(Validate.serverAddress('not-a-url'), isNotNull);
        expect(Validate.serverAddress('ftp://example.com'), isNotNull);
      });

      test('returns null for valid HTTP address', () {
        expect(Validate.serverAddress('http://localhost'), isNull);
        expect(Validate.serverAddress('http://localhost:8080'), isNull);
        expect(Validate.serverAddress('https://example.com'), isNull);
        expect(Validate.serverAddress('https://example.com:443'), isNull);
      });

      test('returns null for IP address', () {
        expect(Validate.serverAddress('http://192.168.1.1'), isNull);
        expect(Validate.serverAddress('http://127.0.0.1:8080'), isNull);
      });

      test('uses custom error message when provided', () {
        final customMsg = 'Please enter a valid server';
        expect(Validate.serverAddress('', invalidText: customMsg), customMsg);
      });
    });
  });
}
