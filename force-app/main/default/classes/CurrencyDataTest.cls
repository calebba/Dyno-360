@isTest
public class CurrencyDataTest {
	@isTest static void testCurrencyData() {
		CurrencyData data = new CurrencyData('USD', 2.00);
		System.assertEquals('USD', data.currencyIsoCode);
		System.assertEquals(2.00, data.value);
	}
	
	@isTest static void testConvert() {
		// Insert fake currency
		Decimal rate = [Select ConversionRate from CurrencyType where IsoCode='CAD' Limit 1].ConversionRate;
		
		CurrencyData data = new CurrencyData('USD', 2.00);
		data.convert('CAD');
		System.assertEquals((2.00*rate), data.value);
        		
		// Catch invalid currency
		try {
			data.convert('TST');
			System.assert(false, 'Failed invalid currency test');
		}
		catch (CurrencyData.CurrencyDataException cde) {
			
		}
	}
	
	@isTest static void testGetCurrencyOptions() {
		List<String> currencyTypes = new List<String>();
		for (CurrencyType rate : [Select c.IsoCode From CurrencyType c]) {
			currencyTypes.add(rate.IsoCode);	
		}
		
		List<SelectOption> options = CurrencyData.getCurrencyOptions();
		Boolean found;
		for (String currencyType : currencyTypes) {
			found = false;
			for (SelectOption option : options) {
				if (option.getValue() == currencyType)
					found = true;
			}
			System.assert(found, 'Currency Type ' + currencyType + ' not found in the options list.');
		}
	}
}