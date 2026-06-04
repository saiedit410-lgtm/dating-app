import 'package:dating_app/core/config/app_environment.dart';
import 'package:dating_app/core/config/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironment.fromName', () {
    test('parses known environment names case-insensitively', () {
      expect(AppEnvironment.fromName('dev'), AppEnvironment.dev);
      expect(AppEnvironment.fromName('STAGING'), AppEnvironment.staging);
      expect(AppEnvironment.fromName('Prod'), AppEnvironment.prod);
    });

    test('falls back to dev for unknown/empty values (fail-safe)', () {
      expect(AppEnvironment.fromName(''), AppEnvironment.dev);
      expect(AppEnvironment.fromName('bogus'), AppEnvironment.dev);
    });

    test('isProduction is true only for prod', () {
      expect(AppEnvironment.prod.isProduction, isTrue);
      expect(AppEnvironment.dev.isProduction, isFalse);
      expect(AppEnvironment.staging.isProduction, isFalse);
    });
  });

  group('EnvConfig.resolve', () {
    test('defaults to dev with verbose logging when APP_ENV is unset', () {
      final config = EnvConfig.resolve();

      expect(config.environment, AppEnvironment.dev);
      expect(config.appName, contains('Spark'));
      expect(config.enableVerboseLogging, isTrue);
    });
  });
}
