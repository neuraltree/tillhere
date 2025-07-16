#!/bin/bash

# List of major countries (ISO 2-letter codes)
countries=(
    "US" "GB" "DE" "FR" "JP" "CN" "IN" "BR" "AU" "CA" "IT" "ES" "RU" "KR" "MX"
    "TR" "SA" "AR" "ZA" "EG" "NG" "KE" "GH" "MA" "TN" "DZ" "ET" "UG" "TZ" "ZW"
    "ZM" "MW" "MZ" "AO" "CD" "CG" "CM" "CI" "SN" "ML" "BF" "NE" "TD" "CF" "GN"
    "SL" "LR" "GM" "GW" "CV" "ST" "GQ" "GA" "DJ" "SO" "ER" "SS" "RW" "BI" "KM"
    "SC" "MU" "MG" "MV" "LK" "BD" "PK" "AF" "IR" "IQ" "SY" "JO" "LB" "IL" "PS"
    "YE" "OM" "AE" "QA" "BH" "KW" "TH" "VN" "MY" "SG" "ID" "PH" "MM" "KH" "LA"
    "BN" "TL" "FJ" "PG" "SB" "VU" "NC" "PF" "WS" "TO" "KI" "TV" "NR" "PW" "MH"
    "FM" "DO" "HT" "JM" "CU" "BS" "BB" "TT" "GD" "VC" "LC" "DM" "AG" "KN" "CO"
    "VE" "GY" "SR" "EC" "PE" "BO" "PY" "UY" "CL" "GT" "BZ" "SV" "HN" "NI" "CR"
    "PA" "IS" "NO" "SE" "FI" "DK" "EE" "LV" "LT" "PL" "CZ" "SK" "HU" "SI" "HR"
    "BA" "RS" "ME" "MK" "AL" "BG" "RO" "MD" "UA" "BY" "AM" "AZ" "GE" "KZ" "KG"
    "TJ" "TM" "UZ" "MN" "NP" "BT" "NZ" "AD" "MC" "SM" "VA" "MT" "CY" "LU" "LI"
    "CH" "AT" "BE" "NL" "IE" "PT"
)

echo "🌍 Fetching life expectancy data for ${#countries[@]} countries..."

# Create temp directory
mkdir -p temp_data

# Counter for progress
count=0
total=${#countries[@]}

# Fetch data for each country
for country in "${countries[@]}"; do
    count=$((count + 1))
    echo "[$count/$total] Fetching data for $country..."
    
    # Fetch most recent 3 years of data
    curl -s "https://api.worldbank.org/v2/country/$country/indicator/SP.DYN.LE00.IN?format=json&per_page=5&date=2020:2023" \
        -o "temp_data/${country}.json"
    
    # Small delay to be nice to the API
    sleep 0.1
done

echo "📊 Processing and merging data..."

# Create the merged JSON file using a simple Python script
cat > process_merged_data.py << 'EOF'
import json
import os
from datetime import datetime
import glob

def process_country_data():
    merged_data = {
        "metadata": {
            "source": "World Bank API",
            "indicator": "SP.DYN.LE00.IN",
            "description": "Life expectancy at birth, total (years)",
            "generatedAt": datetime.now().isoformat(),
            "totalCountries": 0
        },
        "countries": {}
    }
    
    # Process each country file
    for file_path in glob.glob("temp_data/*.json"):
        country_code = os.path.basename(file_path).replace('.json', '')
        
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
            
            # World Bank API returns [metadata, data_array]
            if len(data) < 2 or not data[1]:
                continue
                
            country_data = data[1]
            
            # Find the most recent non-null value
            most_recent = None
            for entry in country_data:
                if entry.get('value') is not None:
                    most_recent = entry
                    break
            
            if most_recent:
                merged_data["countries"][country_code] = {
                    "name": most_recent["country"]["value"],
                    "iso3": most_recent.get("countryiso3code", ""),
                    "lifeExpectancy": most_recent["value"],
                    "year": int(most_recent["date"]),
                    "lastUpdated": datetime.now().isoformat()
                }
                
        except Exception as e:
            print(f"Error processing {country_code}: {e}")
            continue
    
    merged_data["metadata"]["totalCountries"] = len(merged_data["countries"])
    
    # Create assets directory if it doesn't exist
    os.makedirs("assets", exist_ok=True)
    
    # Write the merged data
    with open("assets/life_expectancy.json", 'w') as f:
        json.dump(merged_data, f, indent=2)
    
    print(f"✅ Successfully processed {len(merged_data['countries'])} countries")
    
    # Show some sample data
    print("\n📊 Sample data:")
    sample_countries = ['US', 'GB', 'DE', 'JP', 'IN', 'CN', 'BR', 'AU', 'CA', 'FR']
    for code in sample_countries:
        if code in merged_data["countries"]:
            country = merged_data["countries"][code]
            print(f"  {code} ({country['name']}): {country['lifeExpectancy']:.1f} years ({country['year']})")

if __name__ == "__main__":
    process_country_data()
EOF

# Run the processing script
python3 process_merged_data.py

# Clean up temp files
rm -rf temp_data
rm process_merged_data.py

echo "🎉 Life expectancy data saved to assets/life_expectancy.json"
