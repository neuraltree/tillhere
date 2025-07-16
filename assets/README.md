# Life Expectancy Data

This directory contains the life expectancy data used by the TillHere app.

## Files

- `life_expectancy.json` - Life expectancy data for all countries (World Bank API)

## Data Source

The life expectancy data is sourced from the World Bank Data API:

- **API Endpoint**: `https://api.worldbank.org/v2/country/{code}/indicator/SP.DYN.LE00.IN?format=json`
- **Indicator**: SP.DYN.LE00.IN (Life expectancy at birth, total years)
- **Source**: World Bank Group
- **License**: Creative Commons Attribution 4.0 International License

## Data Structure

```json
{
  "metadata": {
    "source": "World Bank API",
    "indicator": "SP.DYN.LE00.IN",
    "description": "Life expectancy at birth, total (years)",
    "generatedAt": "2024-01-15T10:30:00Z",
    "totalCountries": 195
  },
  "countries": {
    "US": {
      "name": "United States",
      "iso3": "USA",
      "lifeExpectancy": 78.9,
      "year": 2023,
      "lastUpdated": "2024-01-15T10:30:00Z"
    },
    "GB": {
      "name": "United Kingdom",
      "iso3": "GBR",
      "lifeExpectancy": 81.2,
      "year": 2023,
      "lastUpdated": "2024-01-15T10:30:00Z"
    }
  }
}
```

## Updating the Data

To update the life expectancy data with fresh information from the World Bank API:

1. **Run the fetch script:**
```bash
./fetch_life_expectancy.sh
```

This script will:
- Fetch data for all major countries from the World Bank API
- Process and merge the data into a single JSON file
- Save the result to `assets/life_expectancy.json`

2. **Manual update (if needed):**
```bash
# Fetch data for specific countries
curl "https://api.worldbank.org/v2/country/US;GB;DE;FR;JP/indicator/SP.DYN.LE00.IN?format=json&per_page=100&date=2020:2023" > raw_data.json

# Process with the included Python script
python3 process_data.py raw_data.json
```

## Data Coverage

The current dataset includes life expectancy data for approximately 195 countries and territories, covering:

- All UN member states
- Major territories and dependencies
- Most recent available data (typically 2020-2023)

## Data Quality

- Data is validated for reasonable ranges (0-150 years)
- Only countries with valid 2-letter ISO codes are included
- Regional aggregates and invalid entries are filtered out
- Most recent non-null values are used for each country

## Usage in App

The data is loaded by `LifeExpectancyLocalDataSource` and cached in memory for fast access:

```dart
final dataSource = LifeExpectancyLocalDataSource();
final result = await dataSource.getLifeExpectancy('US');
```

## Update Frequency

Life expectancy data changes slowly, so updates are typically needed:
- Annually when new World Bank data is released
- When adding support for new countries
- When fixing data quality issues

## License and Attribution

This data is derived from the World Bank's World Development Indicators database, which is available under the Creative Commons Attribution 4.0 International License.

**Attribution**: World Bank Group, World Development Indicators, Life expectancy at birth, total (years) [SP.DYN.LE00.IN]

## Technical Notes

- File size: ~50KB (compressed JSON)
- Load time: <100ms on typical devices
- Memory usage: ~200KB when cached
- Countries supported: 195+
- Data freshness: Updated annually

## Troubleshooting

**If the data file is missing or corrupted:**
1. Re-run `./fetch_life_expectancy.sh`
2. Check network connectivity
3. Verify World Bank API is accessible
4. Check file permissions in assets directory

**If specific countries are missing:**
1. Check if the country code is valid (2-letter ISO)
2. Verify the country has data in World Bank API
3. Add the country code to the fetch script if needed

**If data seems outdated:**
1. Check the `generatedAt` timestamp in metadata
2. Re-run the fetch script to get latest data
3. World Bank typically updates data annually
