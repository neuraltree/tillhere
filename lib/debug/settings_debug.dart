import 'package:flutter/material.dart';
import '../data/datasources/local/database_helper.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../core/entities/user_settings.dart';

/// Debug utility to test settings persistence
class SettingsDebugHelper {
  static Future<void> debugSettingsPersistence() async {
    print('🔍 DEBUG: Starting settings persistence test...');
    
    try {
      // Initialize database and repository
      final databaseHelper = DatabaseHelper();
      final settingsRepository = SettingsRepositoryImpl(databaseHelper);
      
      // Test 1: Check if database is accessible
      print('📊 DEBUG: Testing database access...');
      final db = await databaseHelper.database;
      print('✅ DEBUG: Database initialized successfully');
      
      // Test 2: Check if settings table exists
      print('📊 DEBUG: Checking settings table...');
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='settings'");
      if (tables.isNotEmpty) {
        print('✅ DEBUG: Settings table exists');
      } else {
        print('❌ DEBUG: Settings table does not exist!');
        return;
      }
      
      // Test 3: Try to read current settings
      print('📊 DEBUG: Reading current settings...');
      final readResult = await settingsRepository.getUserSettings();
      if (readResult.isSuccess) {
        final currentSettings = readResult.data!;
        print('✅ DEBUG: Current settings loaded:');
        print('   - Date of birth: ${currentSettings.dateOfBirth}');
        print('   - Country code: ${currentSettings.countryCode}');
        print('   - Death date: ${currentSettings.deathDate}');
        print('   - Has basic setup: ${currentSettings.hasBasicSetup}');
      } else {
        print('❌ DEBUG: Failed to read settings: ${readResult.failure}');
      }
      
      // Test 4: Try to save test settings
      print('📊 DEBUG: Testing settings save...');
      final testSettings = UserSettings(
        dateOfBirth: DateTime(1990, 1, 1),
        countryCode: 'US',
        deathDate: DateTime(2070, 1, 1),
        lifeExpectancyYears: 80.0,
        lastCalculatedAt: DateTime.now(),
      );
      
      final saveResult = await settingsRepository.updateUserSettings(testSettings);
      if (saveResult.isSuccess) {
        print('✅ DEBUG: Test settings saved successfully');
        
        // Test 5: Verify the save by reading back
        print('📊 DEBUG: Verifying saved settings...');
        final verifyResult = await settingsRepository.getUserSettings();
        if (verifyResult.isSuccess) {
          final savedSettings = verifyResult.data!;
          print('✅ DEBUG: Verified settings:');
          print('   - Date of birth: ${savedSettings.dateOfBirth}');
          print('   - Country code: ${savedSettings.countryCode}');
          print('   - Death date: ${savedSettings.deathDate}');
          print('   - Has basic setup: ${savedSettings.hasBasicSetup}');
          
          if (savedSettings.hasBasicSetup) {
            print('✅ DEBUG: Settings persistence is working correctly!');
          } else {
            print('❌ DEBUG: Settings saved but hasBasicSetup is false');
          }
        } else {
          print('❌ DEBUG: Failed to verify saved settings: ${verifyResult.failure}');
        }
      } else {
        print('❌ DEBUG: Failed to save test settings: ${saveResult.failure}');
      }
      
      // Test 6: Check raw database content
      print('📊 DEBUG: Checking raw database content...');
      final rawSettings = await db.query(DatabaseHelper.tableSettings);
      print('✅ DEBUG: Raw settings in database:');
      for (final setting in rawSettings) {
        print('   - ${setting['key']}: ${setting['value']} (${setting['type']})');
      }
      
    } catch (e) {
      print('❌ DEBUG: Unexpected error during settings debug: $e');
    }
  }
  
  /// Clear all settings for testing
  static Future<void> clearAllSettings() async {
    try {
      final databaseHelper = DatabaseHelper();
      final db = await databaseHelper.database;
      await db.delete(DatabaseHelper.tableSettings);
      print('✅ DEBUG: All settings cleared');
    } catch (e) {
      print('❌ DEBUG: Failed to clear settings: $e');
    }
  }
}
