import 'package:flutter_test/flutter_test.dart';
import 'package:tillhere/data/datasources/local/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    const testPasscode = 'test_passcode_123';
    const testJsonData = '{"test": "data", "number": 42, "array": [1, 2, 3]}';
    
    test('should encrypt and decrypt JSON data successfully', () {
      // Arrange & Act
      final encryptedData = EncryptionService.encryptJson(testJsonData, testPasscode);
      final decryptedData = EncryptionService.decryptJson(encryptedData, testPasscode);
      
      // Assert
      expect(decryptedData, equals(testJsonData));
    });
    
    test('should produce different encrypted output for same input', () {
      // Arrange & Act
      final encrypted1 = EncryptionService.encryptJson(testJsonData, testPasscode);
      final encrypted2 = EncryptionService.encryptJson(testJsonData, testPasscode);
      
      // Assert
      expect(encrypted1, isNot(equals(encrypted2)));
      
      // But both should decrypt to the same data
      final decrypted1 = EncryptionService.decryptJson(encrypted1, testPasscode);
      final decrypted2 = EncryptionService.decryptJson(encrypted2, testPasscode);
      expect(decrypted1, equals(testJsonData));
      expect(decrypted2, equals(testJsonData));
    });
    
    test('should fail decryption with wrong passcode', () {
      // Arrange
      final encryptedData = EncryptionService.encryptJson(testJsonData, testPasscode);
      
      // Act & Assert
      expect(
        () => EncryptionService.decryptJson(encryptedData, 'wrong_passcode'),
        throwsA(isA<EncryptionException>()),
      );
    });
    
    test('should fail decryption with corrupted data', () {
      // Arrange
      final encryptedData = EncryptionService.encryptJson(testJsonData, testPasscode);
      final corruptedData = encryptedData.substring(0, encryptedData.length - 10) + 'corrupted';
      
      // Act & Assert
      expect(
        () => EncryptionService.decryptJson(corruptedData, testPasscode),
        throwsA(isA<EncryptionException>()),
      );
    });
    
    test('should fail decryption with invalid base64 data', () {
      // Arrange
      const invalidBase64 = 'invalid_base64_data!@#';
      
      // Act & Assert
      expect(
        () => EncryptionService.decryptJson(invalidBase64, testPasscode),
        throwsA(isA<EncryptionException>()),
      );
    });
    
    test('should fail decryption with too short data', () {
      // Arrange
      const tooShortData = 'dGVzdA=='; // "test" in base64, too short for valid encrypted data
      
      // Act & Assert
      expect(
        () => EncryptionService.decryptJson(tooShortData, testPasscode),
        throwsA(isA<EncryptionException>()),
      );
    });
    
    test('should handle empty JSON data', () {
      // Arrange
      const emptyJson = '{}';
      
      // Act
      final encryptedData = EncryptionService.encryptJson(emptyJson, testPasscode);
      final decryptedData = EncryptionService.decryptJson(encryptedData, testPasscode);
      
      // Assert
      expect(decryptedData, equals(emptyJson));
    });
    
    test('should handle large JSON data', () {
      // Arrange
      final largeJson = '{"data": "${List.generate(1000, (i) => 'item_$i').join(',')}"}';
      
      // Act
      final encryptedData = EncryptionService.encryptJson(largeJson, testPasscode);
      final decryptedData = EncryptionService.decryptJson(encryptedData, testPasscode);
      
      // Assert
      expect(decryptedData, equals(largeJson));
    });
    
    test('should handle special characters in JSON', () {
      // Arrange
      const specialJson = '{"special": "äöü🚀💫⭐", "unicode": "\\u0041\\u0042\\u0043"}';
      
      // Act
      final encryptedData = EncryptionService.encryptJson(specialJson, testPasscode);
      final decryptedData = EncryptionService.decryptJson(encryptedData, testPasscode);
      
      // Assert
      expect(decryptedData, equals(specialJson));
    });
    
    test('should handle different passcode lengths', () {
      // Arrange
      const shortPasscode = '123';
      const longPasscode = 'this_is_a_very_long_passcode_with_many_characters_1234567890';
      
      // Act
      final encrypted1 = EncryptionService.encryptJson(testJsonData, shortPasscode);
      final encrypted2 = EncryptionService.encryptJson(testJsonData, longPasscode);
      
      final decrypted1 = EncryptionService.decryptJson(encrypted1, shortPasscode);
      final decrypted2 = EncryptionService.decryptJson(encrypted2, longPasscode);
      
      // Assert
      expect(decrypted1, equals(testJsonData));
      expect(decrypted2, equals(testJsonData));
      
      // Cross-decryption should fail
      expect(
        () => EncryptionService.decryptJson(encrypted1, longPasscode),
        throwsA(isA<EncryptionException>()),
      );
      expect(
        () => EncryptionService.decryptJson(encrypted2, shortPasscode),
        throwsA(isA<EncryptionException>()),
      );
    });
    
    test('should produce base64 encoded output', () {
      // Arrange & Act
      final encryptedData = EncryptionService.encryptJson(testJsonData, testPasscode);
      
      // Assert
      expect(() => Uri.parse('data:text/plain;base64,$encryptedData'), returnsNormally);
      expect(encryptedData, matches(RegExp(r'^[A-Za-z0-9+/]*={0,2}$')));
    });
  });
}
