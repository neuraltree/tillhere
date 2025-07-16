import 'dart:io';
import 'dart:ui' as ui;

import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../core/entities/country.dart';

/// Service for detecting device locale and mapping it to country codes
/// Uses Flutter's built-in locale detection to determine the user's country
class LocaleDetectionService {
  // Mapping of locale codes to country codes
  static const Map<String, String> _localeToCountryMap = {
    // Major countries
    'en_US': 'US', 'en_GB': 'GB', 'de_DE': 'DE', 'fr_FR': 'FR', 'ja_JP': 'JP',
    'zh_CN': 'CN', 'hi_IN': 'IN', 'pt_BR': 'BR', 'en_AU': 'AU', 'en_CA': 'CA',
    'it_IT': 'IT', 'es_ES': 'ES', 'ru_RU': 'RU', 'ko_KR': 'KR', 'es_MX': 'MX',
    'tr_TR': 'TR', 'ar_SA': 'SA', 'es_AR': 'AR', 'en_ZA': 'ZA', 'ar_EG': 'EG',
    'en_NG': 'NG', 'sw_KE': 'KE', 'en_GH': 'GH', 'ar_MA': 'MA', 'ar_TN': 'TN',
    'ar_DZ': 'DZ', 'am_ET': 'ET', 'en_UG': 'UG', 'sw_TZ': 'TZ', 'en_ZW': 'ZW',
    'en_ZM': 'ZM', 'en_MW': 'MW', 'pt_MZ': 'MZ', 'pt_AO': 'AO', 'fr_CD': 'CD',
    'fr_CG': 'CG', 'fr_CM': 'CM', 'fr_CI': 'CI', 'fr_SN': 'SN', 'fr_ML': 'ML',
    'fr_BF': 'BF', 'fr_NE': 'NE', 'fr_TD': 'TD', 'fr_CF': 'CF', 'fr_GN': 'GN',
    'en_SL': 'SL', 'en_LR': 'LR', 'en_GM': 'GM', 'pt_GW': 'GW', 'pt_CV': 'CV',
    'pt_ST': 'ST', 'es_GQ': 'GQ', 'fr_GA': 'GA', 'fr_DJ': 'DJ', 'so_SO': 'SO',
    'ti_ER': 'ER', 'en_SS': 'SS', 'rw_RW': 'RW', 'rn_BI': 'BI', 'ar_KM': 'KM',
    'en_SC': 'SC', 'en_MU': 'MU', 'mg_MG': 'MG', 'dv_MV': 'MV', 'si_LK': 'LK',
    'bn_BD': 'BD', 'ur_PK': 'PK', 'fa_AF': 'AF', 'fa_IR': 'IR', 'ar_IQ': 'IQ',
    'ar_SY': 'SY', 'ar_JO': 'JO', 'ar_LB': 'LB', 'he_IL': 'IL', 'ar_PS': 'PS',
    'ar_YE': 'YE', 'ar_OM': 'OM', 'ar_AE': 'AE', 'ar_QA': 'QA', 'ar_BH': 'BH',
    'ar_KW': 'KW', 'th_TH': 'TH', 'vi_VN': 'VN', 'ms_MY': 'MY', 'en_SG': 'SG',
    'id_ID': 'ID', 'tl_PH': 'PH', 'my_MM': 'MM', 'km_KH': 'KH', 'lo_LA': 'LA',
    'ms_BN': 'BN', 'pt_TL': 'TL', 'en_FJ': 'FJ', 'en_PG': 'PG', 'en_SB': 'SB',
    'bi_VU': 'VU', 'fr_NC': 'NC', 'fr_PF': 'PF', 'sm_WS': 'WS', 'to_TO': 'TO',
    'en_KI': 'KI', 'tvl_TV': 'TV', 'na_NR': 'NR', 'pau_PW': 'PW', 'mh_MH': 'MH',
    'chk_FM': 'FM', 'es_DO': 'DO', 'ht_HT': 'HT', 'en_JM': 'JM', 'es_CU': 'CU',
    'en_BS': 'BS', 'en_BB': 'BB', 'en_TT': 'TT', 'en_GD': 'GD', 'en_VC': 'VC',
    'en_LC': 'LC', 'en_DM': 'DM', 'en_AG': 'AG', 'en_KN': 'KN', 'es_CO': 'CO',
    'es_VE': 'VE', 'en_GY': 'GY', 'nl_SR': 'SR', 'es_EC': 'EC', 'es_PE': 'PE',
    'es_BO': 'BO', 'es_PY': 'PY', 'es_UY': 'UY', 'es_CL': 'CL', 'es_GT': 'GT',
    'en_BZ': 'BZ', 'es_SV': 'SV', 'es_HN': 'HN', 'es_NI': 'NI', 'es_CR': 'CR',
    'es_PA': 'PA', 'is_IS': 'IS', 'no_NO': 'NO', 'sv_SE': 'SE', 'fi_FI': 'FI',
    'da_DK': 'DK', 'et_EE': 'EE', 'lv_LV': 'LV', 'lt_LT': 'LT', 'pl_PL': 'PL',
    'cs_CZ': 'CZ', 'sk_SK': 'SK', 'hu_HU': 'HU', 'sl_SI': 'SI', 'hr_HR': 'HR',
    'bs_BA': 'BA', 'sr_RS': 'RS', 'sr_ME': 'ME', 'mk_MK': 'MK', 'sq_AL': 'AL',
    'bg_BG': 'BG', 'ro_RO': 'RO', 'ro_MD': 'MD', 'uk_UA': 'UA', 'be_BY': 'BY',
    'hy_AM': 'AM', 'az_AZ': 'AZ', 'ka_GE': 'GE', 'kk_KZ': 'KZ', 'ky_KG': 'KG',
    'tg_TJ': 'TJ', 'tk_TM': 'TM', 'uz_UZ': 'UZ', 'mn_MN': 'MN', 'ne_NP': 'NP',
    'dz_BT': 'BT', 'en_NZ': 'NZ', 'ca_AD': 'AD', 'fr_MC': 'MC', 'it_SM': 'SM',
    'it_VA': 'VA', 'mt_MT': 'MT', 'el_CY': 'CY', 'lb_LU': 'LU', 'de_LI': 'LI',
    'de_CH': 'CH', 'de_AT': 'AT', 'nl_BE': 'BE', 'nl_NL': 'NL', 'en_IE': 'IE',
    'pt_PT': 'PT',
  };

  // Fallback mapping for language codes only (when full locale is not available)
  static const Map<String, String> _languageToCountryMap = {
    'en': 'US',
    'de': 'DE',
    'fr': 'FR',
    'ja': 'JP',
    'zh': 'CN',
    'hi': 'IN',
    'pt': 'BR',
    'it': 'IT',
    'es': 'ES',
    'ru': 'RU',
    'ko': 'KR',
    'tr': 'TR',
    'ar': 'SA',
    'sw': 'KE',
    'am': 'ET',
    'rw': 'RW',
    'rn': 'BI',
    'mg': 'MG',
    'dv': 'MV',
    'si': 'LK',
    'bn': 'BD',
    'ur': 'PK',
    'fa': 'IR',
    'he': 'IL',
    'th': 'TH',
    'vi': 'VN',
    'ms': 'MY',
    'id': 'ID',
    'tl': 'PH',
    'my': 'MM',
    'km': 'KH',
    'lo': 'LA',
    'bi': 'VU',
    'sm': 'WS',
    'to': 'TO',
    'tvl': 'TV',
    'na': 'NR',
    'pau': 'PW',
    'mh': 'MH',
    'chk': 'FM',
    'ht': 'HT',
    'is': 'IS',
    'no': 'NO',
    'sv': 'SE',
    'fi': 'FI',
    'da': 'DK',
    'et': 'EE',
    'lv': 'LV',
    'lt': 'LT',
    'pl': 'PL',
    'cs': 'CZ',
    'sk': 'SK',
    'hu': 'HU',
    'sl': 'SI',
    'hr': 'HR',
    'bs': 'BA',
    'sr': 'RS',
    'mk': 'MK',
    'sq': 'AL',
    'bg': 'BG',
    'ro': 'RO',
    'uk': 'UA',
    'be': 'BY',
    'hy': 'AM',
    'az': 'AZ',
    'ka': 'GE',
    'kk': 'KZ',
    'ky': 'KG',
    'tg': 'TJ',
    'tk': 'TM',
    'uz': 'UZ',
    'mn': 'MN',
    'ne': 'NP',
    'dz': 'BT',
    'ca': 'AD',
    'mt': 'MT',
    'el': 'CY',
    'lb': 'LU',
    'nl': 'NL',
  };

  /// Detects the device's country code based on locale
  ///
  /// Returns a Result containing the detected country code or a Failure
  Future<Result<String>> detectCountryCode() async {
    try {
      // Try to get country code from platform-specific methods first
      final platformResult = await _getPlatformCountryCode();
      if (platformResult.isSuccess) {
        return platformResult;
      }

      // Fallback to locale-based detection
      final localeResult = await _getCountryFromLocale();
      if (localeResult.isSuccess) {
        return localeResult;
      }

      // Final fallback to US
      return Result.success('US');
    } catch (e) {
      // If all else fails, default to US
      return Result.success('US');
    }
  }

  /// Gets country code from platform-specific methods
  Future<Result<String>> _getPlatformCountryCode() async {
    try {
      // Use Flutter's built-in locale detection
      final locale = ui.PlatformDispatcher.instance.locale;

      if (locale.countryCode != null && locale.countryCode!.length == 2) {
        return Result.success(locale.countryCode!.toUpperCase());
      }

      return Result.failure(CacheFailure('Platform country code not available'));
    } catch (e) {
      return Result.failure(CacheFailure('Failed to get platform country code: $e'));
    }
  }

  /// Gets country code from device locale
  Future<Result<String>> _getCountryFromLocale() async {
    try {
      final locale = Platform.localeName; // e.g., "en_US", "de_DE", "ja_JP"

      // Try exact locale match first
      if (_localeToCountryMap.containsKey(locale)) {
        return Result.success(_localeToCountryMap[locale]!);
      }

      // Try language code only
      final languageCode = locale.split('_')[0];
      if (_languageToCountryMap.containsKey(languageCode)) {
        return Result.success(_languageToCountryMap[languageCode]!);
      }

      // Try to extract country code from locale if it follows standard format
      if (locale.contains('_') && locale.split('_').length >= 2) {
        final countryPart = locale.split('_')[1];
        if (countryPart.length == 2) {
          return Result.success(countryPart.toUpperCase());
        }
      }

      return Result.failure(CacheFailure('Could not determine country from locale: $locale'));
    } catch (e) {
      return Result.failure(CacheFailure('Failed to get country from locale: $e'));
    }
  }

  /// Detects the device's country and returns a Country entity
  ///
  /// Returns a Result containing the detected Country or a Failure
  Future<Result<Country>> detectCountry() async {
    try {
      final countryCodeResult = await detectCountryCode();
      if (countryCodeResult.isFailure) {
        return Result.failure(countryCodeResult.failure!);
      }

      final countryCode = countryCodeResult.data!;

      // Create a basic Country entity
      // The name will be filled in by other services if needed
      final country = Country(code: countryCode, name: _getCountryName(countryCode));

      return Result.success(country);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to detect country: $e'));
    }
  }

  /// Gets a basic country name for a country code
  String _getCountryName(String countryCode) {
    const countryNames = {
      'US': 'United States',
      'GB': 'United Kingdom',
      'DE': 'Germany',
      'FR': 'France',
      'JP': 'Japan',
      'CN': 'China',
      'IN': 'India',
      'BR': 'Brazil',
      'AU': 'Australia',
      'CA': 'Canada',
      'IT': 'Italy',
      'ES': 'Spain',
      'RU': 'Russia',
      'KR': 'South Korea',
      'MX': 'Mexico',
      // Add more as needed
    };

    return countryNames[countryCode] ?? countryCode;
  }

  /// Checks if a country code is supported
  bool isCountrySupported(String countryCode) {
    return _localeToCountryMap.containsValue(countryCode.toUpperCase()) ||
        _languageToCountryMap.containsValue(countryCode.toUpperCase());
  }

  /// Gets all supported country codes
  List<String> getSupportedCountryCodes() {
    final codes = <String>{};
    codes.addAll(_localeToCountryMap.values);
    codes.addAll(_languageToCountryMap.values);
    return codes.toList()..sort();
  }
}
