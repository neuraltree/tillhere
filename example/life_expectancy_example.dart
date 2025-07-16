import 'package:flutter/material.dart';
import 'package:tillhere/core/entities/user_settings.dart';
import 'package:tillhere/core/services/life_expectancy_service.dart';
import 'package:tillhere/data/datasources/local/life_expectancy_local_datasource.dart';
import 'package:tillhere/data/datasources/local/locale_detection_service.dart';
import 'package:tillhere/data/datasources/local/database_helper.dart';
import 'package:tillhere/data/repositories/settings_repository_impl.dart';

/// Example demonstrating how to use the life expectancy feature
/// This shows the complete flow from setup to generating future weeks
class LifeExpectancyExample {
  late final LifeExpectancyService _lifeExpectancyService;
  late final SettingsRepositoryImpl _settingsRepository;

  LifeExpectancyExample() {
    // Initialize dependencies
    final lifeExpectancyDataSource = LifeExpectancyLocalDataSource();
    final localeDetectionService = LocaleDetectionService();
    final databaseHelper = DatabaseHelper();
    
    _lifeExpectancyService = LifeExpectancyService(
      lifeExpectancyDataSource,
      localeDetectionService,
    );
    
    _settingsRepository = SettingsRepositoryImpl(databaseHelper);
  }

  /// Example 1: Basic setup - compute death date for a user
  Future<void> basicSetupExample() async {
    print('=== Basic Setup Example ===');
    
    // User's date of birth
    final dateOfBirth = DateTime(1990, 5, 15);
    
    // Compute death date (will auto-detect country from locale)
    final result = await _lifeExpectancyService.computeDeathDate(dateOfBirth);
    
    if (result.isSuccess) {
      final settings = result.data!;
      print('✅ Death date computed successfully!');
      print('   Date of Birth: ${settings.dateOfBirth}');
      print('   Death Date: ${settings.deathDate}');
      print('   Country: ${settings.countryCode}');
      print('   Life Expectancy: ${settings.lifeExpectancyYears} years');
      print('   Current Age: ${settings.currentAgeInYears} years');
      print('   Weeks Lived: ${settings.weeksLived}');
      print('   Weeks Remaining: ${settings.weeksRemaining}');
      
      // Save settings to database
      await _settingsRepository.updateUserSettings(settings);
      print('   Settings saved to database');
    } else {
      print('❌ Failed to compute death date: ${result.failure}');
    }
  }

  /// Example 2: Specify country explicitly
  Future<void> specificCountryExample() async {
    print('\n=== Specific Country Example ===');
    
    final dateOfBirth = DateTime(1985, 12, 25);
    
    // Compute death date for a specific country
    final result = await _lifeExpectancyService.computeDeathDate(
      dateOfBirth,
      countryCode: 'JP', // Japan
    );
    
    if (result.isSuccess) {
      final settings = result.data!;
      print('✅ Death date computed for Japan!');
      print('   Life Expectancy: ${settings.lifeExpectancyYears} years');
      print('   Death Date: ${settings.deathDate}');
    } else {
      print('❌ Failed: ${result.failure}');
    }
  }

  /// Example 3: Generate future weeks
  Future<void> generateWeeksExample() async {
    print('\n=== Generate Future Weeks Example ===');
    
    // Get existing settings from database
    final settingsResult = await _settingsRepository.getUserSettings();
    if (settingsResult.isFailure) {
      print('❌ No settings found. Run basic setup first.');
      return;
    }
    
    final settings = settingsResult.data!;
    
    // Generate future weeks (limit to first 10 for example)
    final weeksResult = await _lifeExpectancyService.generateFutureWeeks(
      settings,
      maxWeeks: 10,
    );
    
    if (weeksResult.isSuccess) {
      final weeks = weeksResult.data!;
      print('✅ Generated ${weeks.length} future weeks:');
      
      for (final week in weeks) {
        final status = week.isPast ? '(Past)' : 
                      week.isCurrent ? '(Current)' : '(Future)';
        print('   Week ${week.weekNumber}: ${week.formattedRange} $status');
      }
    } else {
      print('❌ Failed to generate weeks: ${weeksResult.failure}');
    }
  }

  /// Example 4: Get life expectancy statistics
  Future<void> statisticsExample() async {
    print('\n=== Life Expectancy Statistics Example ===');
    
    final settingsResult = await _settingsRepository.getUserSettings();
    if (settingsResult.isFailure) {
      print('❌ No settings found. Run basic setup first.');
      return;
    }
    
    final settings = settingsResult.data!;
    
    // Get detailed statistics
    final statsResult = await _lifeExpectancyService.getLifeExpectancyStats(settings);
    
    if (statsResult.isSuccess) {
      final stats = statsResult.data!;
      print('✅ Life Expectancy Statistics:');
      print('   Total Life Expectancy: ${stats.totalLifeExpectancyYears} years');
      print('   Total Weeks: ${stats.totalLifeExpectancyWeeks}');
      print('   Total Days: ${stats.totalLifeExpectancyDays}');
      print('   Current Age: ${stats.currentAge} years');
      print('   Days Lived: ${stats.daysLived}');
      print('   Weeks Lived: ${stats.weeksLived}');
      print('   Days Remaining: ${stats.daysRemaining}');
      print('   Weeks Remaining: ${stats.weeksRemaining}');
      print('   Percentage Lived: ${stats.percentageLived.toStringAsFixed(1)}%');
      print('   Country: ${stats.countryCode}');
      print('   Last Updated: ${stats.lastUpdated}');
    } else {
      print('❌ Failed to get statistics: ${statsResult.failure}');
    }
  }

  /// Example 5: Update life expectancy data
  Future<void> updateLifeExpectancyExample() async {
    print('\n=== Update Life Expectancy Example ===');
    
    final settingsResult = await _settingsRepository.getUserSettings();
    if (settingsResult.isFailure) {
      print('❌ No settings found. Run basic setup first.');
      return;
    }
    
    final currentSettings = settingsResult.data!;
    
    // Check if update is needed
    if (_lifeExpectancyService.needsRefresh(currentSettings)) {
      print('🔄 Life expectancy data needs refresh...');
      
      final updateResult = await _lifeExpectancyService.updateLifeExpectancy(
        currentSettings,
        forceRefresh: true,
      );
      
      if (updateResult.isSuccess) {
        final updatedSettings = updateResult.data!;
        print('✅ Life expectancy updated!');
        print('   New Death Date: ${updatedSettings.deathDate}');
        print('   Updated At: ${updatedSettings.lastCalculatedAt}');
        
        // Save updated settings
        await _settingsRepository.updateUserSettings(updatedSettings);
      } else {
        print('❌ Failed to update: ${updateResult.failure}');
      }
    } else {
      print('✅ Life expectancy data is fresh, no update needed.');
    }
  }

  /// Example 6: Working with different countries
  Future<void> multipleCountriesExample() async {
    print('\n=== Multiple Countries Example ===');
    
    final lifeExpectancyDataSource = LifeExpectancyLocalDataSource();
    
    // Get life expectancy for multiple countries
    final countryCodes = ['US', 'GB', 'DE', 'JP', 'CN', 'IN', 'BR', 'AU'];
    final result = await lifeExpectancyDataSource.getMultipleLifeExpectancies(countryCodes);
    
    if (result.isSuccess) {
      final lifeExpectancies = result.data!;
      print('✅ Life expectancy data for ${lifeExpectancies.length} countries:');
      
      // Sort by life expectancy (highest first)
      final sortedEntries = lifeExpectancies.entries.toList()
        ..sort((a, b) => b.value.yearsAtBirth.compareTo(a.value.yearsAtBirth));
      
      for (final entry in sortedEntries) {
        final country = entry.key;
        final lifeExp = entry.value;
        print('   $country: ${lifeExp.yearsAtBirth.toStringAsFixed(1)} years (${lifeExp.year})');
      }
    } else {
      print('❌ Failed to get multiple countries: ${result.failure}');
    }
  }

  /// Example 7: Error handling and validation
  Future<void> errorHandlingExample() async {
    print('\n=== Error Handling Example ===');
    
    // Try with invalid date of birth (future date)
    final futureDate = DateTime.now().add(const Duration(days: 365));
    final result = await _lifeExpectancyService.computeDeathDate(futureDate);
    
    if (result.isFailure) {
      print('✅ Correctly caught invalid date: ${result.failure}');
    }
    
    // Try with invalid country code
    final lifeExpectancyDataSource = LifeExpectancyLocalDataSource();
    final invalidCountryResult = await lifeExpectancyDataSource.getLifeExpectancy('XX');
    
    if (invalidCountryResult.isFailure) {
      print('✅ Correctly caught invalid country: ${invalidCountryResult.failure}');
    }
  }

  /// Run all examples
  Future<void> runAllExamples() async {
    print('🌍 Life Expectancy Feature Examples\n');
    
    await basicSetupExample();
    await specificCountryExample();
    await generateWeeksExample();
    await statisticsExample();
    await updateLifeExpectancyExample();
    await multipleCountriesExample();
    await errorHandlingExample();
    
    print('\n🎉 All examples completed!');
  }
}

/// Flutter widget example showing how to integrate the life expectancy feature
class LifeExpectancyWidget extends StatefulWidget {
  const LifeExpectancyWidget({Key? key}) : super(key: key);

  @override
  State<LifeExpectancyWidget> createState() => _LifeExpectancyWidgetState();
}

class _LifeExpectancyWidgetState extends State<LifeExpectancyWidget> {
  late final LifeExpectancyService _lifeExpectancyService;
  late final SettingsRepositoryImpl _settingsRepository;
  
  UserSettings? _userSettings;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    // Initialize services
    final lifeExpectancyDataSource = LifeExpectancyLocalDataSource();
    final localeDetectionService = LocaleDetectionService();
    final databaseHelper = DatabaseHelper();
    
    _lifeExpectancyService = LifeExpectancyService(
      lifeExpectancyDataSource,
      localeDetectionService,
    );
    
    _settingsRepository = SettingsRepositoryImpl(databaseHelper);
    
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _settingsRepository.getUserSettings();
    
    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _userSettings = result.data;
      } else {
        _error = result.failure.toString();
      }
    });
  }

  Future<void> _setupLifeExpectancy(DateTime dateOfBirth) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _lifeExpectancyService.computeDeathDate(dateOfBirth);
    
    if (result.isSuccess) {
      final settings = result.data!;
      await _settingsRepository.updateUserSettings(settings);
      setState(() {
        _userSettings = settings;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.failure.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadUserSettings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_userSettings == null || !_userSettings!.hasBasicSetup) {
      return _buildSetupScreen();
    }

    return _buildLifeExpectancyScreen();
  }

  Widget _buildSetupScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Set up your life expectancy tracking'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // In a real app, you'd show a date picker
              final dateOfBirth = DateTime(1990, 5, 15);
              await _setupLifeExpectancy(dateOfBirth);
            },
            child: const Text('Set Date of Birth'),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeExpectancyScreen() {
    final settings = _userSettings!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Life Expectancy Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          _buildStatCard('Current Age', '${settings.currentAgeInYears} years'),
          _buildStatCard('Life Expectancy', '${settings.lifeExpectancyYears?.toStringAsFixed(1)} years'),
          _buildStatCard('Weeks Lived', '${settings.weeksLived}'),
          _buildStatCard('Weeks Remaining', '${settings.weeksRemaining}'),
          _buildStatCard('Country', settings.countryCode ?? 'Unknown'),
          
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // Generate and show future weeks
              final result = await _lifeExpectancyService.generateFutureWeeks(
                settings,
                maxWeeks: 52, // Next year
              );
              
              if (result.isSuccess) {
                // In a real app, you'd navigate to a weeks view
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Generated ${result.data!.length} future weeks'),
                  ),
                );
              }
            },
            child: const Text('View Future Weeks'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main function to run the examples
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final example = LifeExpectancyExample();
  await example.runAllExamples();
}
