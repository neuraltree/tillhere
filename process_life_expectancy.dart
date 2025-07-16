import 'dart:convert';
import 'dart:io';

void main() async {
  // Read the raw World Bank API response
  final file = File('life_expectancy_data.json');
  final content = await file.readAsString();
  
  // Parse the JSON response
  final List<dynamic> response = json.decode(content);
  
  // The second element contains the actual data
  if (response.length < 2) {
    print('Invalid response format');
    return;
  }
  
  final List<dynamic> data = response[1];
  
  // Process the data to create a country -> life expectancy mapping
  final Map<String, Map<String, dynamic>> countryData = {};
  
  for (final item in data) {
    final countryId = item['country']['id'] as String;
    final countryName = item['country']['value'] as String;
    final countryIso3 = item['countryiso3code'] as String;
    final year = int.parse(item['date'] as String);
    final value = item['value'] as double?;
    
    // Skip regional aggregates and focus on actual countries
    // Country codes are typically 2 characters, regional codes are different
    if (countryId.length != 2 || value == null) continue;
    
    // Initialize country entry if not exists
    if (!countryData.containsKey(countryId)) {
      countryData[countryId] = {
        'code': countryId,
        'name': countryName,
        'iso3': countryIso3,
        'data': <Map<String, dynamic>>[],
      };
    }
    
    // Add the data point
    (countryData[countryId]!['data'] as List).add({
      'year': year,
      'value': value,
    });
  }
  
  // Sort data by year for each country and get the most recent value
  final Map<String, dynamic> processedData = {};
  
  for (final entry in countryData.entries) {
    final countryCode = entry.key;
    final countryInfo = entry.value;
    final dataPoints = countryInfo['data'] as List<Map<String, dynamic>>;
    
    // Sort by year descending to get most recent first
    dataPoints.sort((a, b) => (b['year'] as int).compareTo(a['year'] as int));
    
    if (dataPoints.isNotEmpty) {
      final mostRecent = dataPoints.first;
      processedData[countryCode] = {
        'name': countryInfo['name'],
        'iso3': countryInfo['iso3'],
        'lifeExpectancy': mostRecent['value'],
        'year': mostRecent['year'],
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }
  
  // Create the final structure
  final output = {
    'metadata': {
      'source': 'World Bank API',
      'indicator': 'SP.DYN.LE00.IN',
      'description': 'Life expectancy at birth, total (years)',
      'generatedAt': DateTime.now().toIso8601String(),
      'totalCountries': processedData.length,
    },
    'countries': processedData,
  };
  
  // Write to assets directory
  final assetsDir = Directory('assets');
  if (!await assetsDir.exists()) {
    await assetsDir.create();
  }
  
  final outputFile = File('assets/life_expectancy.json');
  await outputFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(output)
  );
  
  print('✅ Processed ${processedData.length} countries');
  print('📁 Output saved to: ${outputFile.path}');
  
  // Show some sample data
  print('\n📊 Sample data:');
  final sampleCountries = ['US', 'GB', 'DE', 'JP', 'IN'];
  for (final code in sampleCountries) {
    if (processedData.containsKey(code)) {
      final country = processedData[code];
      print('  $code (${country['name']}): ${country['lifeExpectancy']} years (${country['year']})');
    }
  }
}
