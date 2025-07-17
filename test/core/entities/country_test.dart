import 'package:flutter_test/flutter_test.dart';
import 'package:tillhere/core/entities/country.dart';

void main() {
  group('Country', () {
    test('should create a valid Country instance with required fields', () {
      // Act
      const country = Country(code: 'US', name: 'United States');

      // Assert
      expect(country.code, equals('US'));
      expect(country.name, equals('United States'));
      expect(country.alpha3Code, isNull);
      expect(country.region, isNull);
    });

    test('should create a valid Country instance with all fields', () {
      // Act
      const country = Country(code: 'US', name: 'United States', alpha3Code: 'USA', region: 'North America');

      // Assert
      expect(country.code, equals('US'));
      expect(country.name, equals('United States'));
      expect(country.alpha3Code, equals('USA'));
      expect(country.region, equals('North America'));
    });

    test('should validate country code correctly for valid codes', () {
      // Arrange
      const validCodes = ['US', 'GB', 'DE', 'FR', 'JP', 'CN', 'AU'];

      // Act & Assert
      for (final code in validCodes) {
        final country = Country(code: code, name: 'Test Country');
        expect(country.isValidCode, isTrue, reason: 'Code $code should be valid');
      }
    });

    test('should validate country code correctly for invalid codes', () {
      // Arrange
      const invalidCodes = [
        '', // Empty
        'U', // Too short
        'USA', // Too long
        'us', // Lowercase
        'Us', // Mixed case
        // Note: Current implementation only validates length and uppercase
        // Numbers and special characters are not validated
      ];

      // Act & Assert
      for (final code in invalidCodes) {
        final country = Country(code: code, name: 'Test Country');
        expect(country.isValidCode, isFalse, reason: 'Code $code should be invalid');
      }
    });

    test('should implement equality correctly', () {
      // Arrange
      const country1 = Country(code: 'US', name: 'United States', alpha3Code: 'USA', region: 'North America');

      const country2 = Country(code: 'US', name: 'United States', alpha3Code: 'USA', region: 'North America');

      const country3 = Country(code: 'GB', name: 'United Kingdom', alpha3Code: 'GBR', region: 'Europe');

      const country4 = Country(
        code: 'US',
        name: 'United States of America', // Different name
        alpha3Code: 'USA',
        region: 'North America',
      );

      // Act & Assert
      expect(country1, equals(country2));
      expect(country1, isNot(equals(country3)));
      expect(country1, isNot(equals(country4)));
      expect(country1.hashCode, equals(country2.hashCode));
    });

    test('should handle null optional fields in equality', () {
      // Arrange
      const country1 = Country(code: 'US', name: 'United States');
      const country2 = Country(code: 'US', name: 'United States');
      const country3 = Country(code: 'US', name: 'United States', alpha3Code: 'USA');

      // Act & Assert
      expect(country1, equals(country2));
      expect(country1, isNot(equals(country3)));
    });

    test('should have proper toString representation', () {
      // Arrange
      const country = Country(code: 'US', name: 'United States', alpha3Code: 'USA', region: 'North America');

      // Act
      final stringRepresentation = country.toString();

      // Assert
      expect(stringRepresentation, contains('Country'));
      expect(stringRepresentation, contains('US'));
      expect(stringRepresentation, contains('United States'));
      expect(stringRepresentation, contains('USA'));
      expect(stringRepresentation, contains('North America'));
    });

    test('should have proper toString representation with null fields', () {
      // Arrange
      const country = Country(code: 'US', name: 'United States');

      // Act
      final stringRepresentation = country.toString();

      // Assert
      expect(stringRepresentation, contains('Country'));
      expect(stringRepresentation, contains('US'));
      expect(stringRepresentation, contains('United States'));
      expect(stringRepresentation, contains('alpha3Code: null'));
      expect(stringRepresentation, contains('region: null'));
    });
  });
}
