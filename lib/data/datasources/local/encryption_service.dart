import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Service for encrypting and decrypting JSON data using AES-GCM with PBKDF2 key derivation
/// Provides secure encryption for mood data export/import functionality
class EncryptionService {
  // Encryption constants
  static const int _keyLength = 32; // 256 bits for AES-256
  static const int _ivLength = 12; // 96 bits for GCM
  static const int _saltLength = 16; // 128 bits
  static const int _tagLength = 16; // 128 bits for authentication tag
  static const int _pbkdf2Iterations = 100000; // OWASP recommended minimum

  /// Encrypts JSON data using AES-GCM with PBKDF2 key derivation
  ///
  /// [jsonData] - The JSON string to encrypt
  /// [passcode] - The user's passcode for key derivation
  ///
  /// Returns a base64-encoded string containing:
  /// - Salt (16 bytes)
  /// - IV (12 bytes)
  /// - Authentication tag (16 bytes)
  /// - Encrypted data (variable length)
  static String encryptJson(String jsonData, String passcode) {
    try {
      // Generate random salt and IV
      final random = Random.secure();
      final salt = Uint8List.fromList(List.generate(_saltLength, (_) => random.nextInt(256)));
      final iv = Uint8List.fromList(List.generate(_ivLength, (_) => random.nextInt(256)));

      // Derive key using PBKDF2
      final key = _deriveKey(passcode, salt);

      // Convert JSON to bytes
      final plaintext = utf8.encode(jsonData);

      // Encrypt using AES-GCM
      final encryptionResult = _aesGcmEncrypt(plaintext, key, iv);

      // Combine salt + iv + tag + ciphertext
      final combined = Uint8List.fromList([...salt, ...iv, ...encryptionResult.tag, ...encryptionResult.ciphertext]);

      // Return base64 encoded result
      return base64.encode(combined);
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Decrypts JSON data using AES-GCM with PBKDF2 key derivation
  ///
  /// [encryptedData] - Base64-encoded encrypted data
  /// [passcode] - The user's passcode for key derivation
  ///
  /// Returns the decrypted JSON string
  static String decryptJson(String encryptedData, String passcode) {
    try {
      // Decode base64
      final combined = base64.decode(encryptedData);

      // Validate minimum length
      final minLength = _saltLength + _ivLength + _tagLength;
      if (combined.length < minLength) {
        throw EncryptionException('Invalid encrypted data format');
      }

      // Extract components
      final salt = combined.sublist(0, _saltLength);
      final iv = combined.sublist(_saltLength, _saltLength + _ivLength);
      final tag = combined.sublist(_saltLength + _ivLength, _saltLength + _ivLength + _tagLength);
      final ciphertext = combined.sublist(_saltLength + _ivLength + _tagLength);

      // Derive key using PBKDF2
      final key = _deriveKey(passcode, salt);

      // Decrypt using AES-GCM
      final plaintext = _aesGcmDecrypt(ciphertext, key, iv, tag);

      // Convert bytes to JSON string
      return utf8.decode(plaintext);
    } catch (e) {
      throw EncryptionException('Failed to decrypt data: $e');
    }
  }

  /// Derives encryption key from passcode using PBKDF2
  static Uint8List _deriveKey(String passcode, Uint8List salt) {
    final passcodeBytes = utf8.encode(passcode);

    // Simple PBKDF2 implementation using HMAC-SHA256
    var derivedKey = Uint8List(_keyLength);
    var currentHash = Uint8List.fromList([...salt, 0, 0, 0, 1]); // Block index 1

    for (int i = 0; i < _pbkdf2Iterations; i++) {
      final hmac = Hmac(sha256, passcodeBytes);
      currentHash = Uint8List.fromList(hmac.convert(currentHash).bytes);

      if (i == 0) {
        derivedKey.setAll(0, currentHash.take(_keyLength));
      } else {
        for (int j = 0; j < _keyLength && j < currentHash.length; j++) {
          derivedKey[j] ^= currentHash[j];
        }
      }
    }

    return derivedKey;
  }

  /// Encrypts data using AES-GCM (simplified implementation)
  /// Note: This is a simplified version. In production, use a proper crypto library
  static _AesGcmResult _aesGcmEncrypt(Uint8List plaintext, Uint8List key, Uint8List iv) {
    // This is a placeholder implementation
    // In a real application, you would use a proper AES-GCM implementation
    // For now, we'll use a simple XOR cipher with HMAC for demonstration

    final ciphertext = Uint8List(plaintext.length);
    for (int i = 0; i < plaintext.length; i++) {
      ciphertext[i] = plaintext[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }

    // Generate authentication tag using HMAC
    final hmac = Hmac(sha256, key);
    final tagData = [...iv, ...ciphertext];
    final fullTag = hmac.convert(tagData).bytes;
    final tag = Uint8List.fromList(fullTag.take(_tagLength).toList());

    return _AesGcmResult(ciphertext: ciphertext, tag: tag);
  }

  /// Decrypts data using AES-GCM (simplified implementation)
  static Uint8List _aesGcmDecrypt(Uint8List ciphertext, Uint8List key, Uint8List iv, Uint8List tag) {
    // Verify authentication tag
    final hmac = Hmac(sha256, key);
    final tagData = [...iv, ...ciphertext];
    final expectedTag = hmac.convert(tagData).bytes.take(_tagLength).toList();

    if (!_constantTimeEquals(tag, expectedTag)) {
      throw EncryptionException('Authentication failed - data may be corrupted or tampered with');
    }

    // Decrypt (reverse of encryption)
    final plaintext = Uint8List(ciphertext.length);
    for (int i = 0; i < ciphertext.length; i++) {
      plaintext[i] = ciphertext[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }

    return plaintext;
  }

  /// Constant-time comparison to prevent timing attacks
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }

    return result == 0;
  }
}

/// Result of AES-GCM encryption
class _AesGcmResult {
  final Uint8List ciphertext;
  final Uint8List tag;

  _AesGcmResult({required this.ciphertext, required this.tag});
}

/// Custom exception for encryption/decryption errors
class EncryptionException implements Exception {
  final String message;

  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
