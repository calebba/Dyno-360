public with sharing class CurrencyData {
	public String currencyISOCode {get; private set;}
	public Decimal value {get; set;}
	public String  displayValue {set;}
	public static Map<String, Decimal> rateMap; 
	private static List<SelectOption> typeOptions; 
	
	public CurrencyData(String currencyISOCode, Decimal value) {
		this.currencyISOCode = currencyISOCode;
		
		try {
			this.value = value;
			this.displayValue = value.format();
		} catch(Exception e) {
			this.value = 0;
			this.displayValue = '0';
		}
	}
	
	public String getdisplayValue(){
		if (this.value != null){
			return this.value.format();
		}
		return '0';
	}
	public void convert(String targetCurrencyISOCode) {
		if (CurrencyData.rateMap == null)
			CurrencyData.initRates();
			
		if (!CurrencyData.rateMap.containsKey(targetCurrencyISOCode)) 
			throw new CurrencyDataException(System.Label.Currency_Not_Valid);
			
		this.value = this.value * CurrencyData.rateMap.get(targetCurrencyISOCode);
	}
	
	public static List<SelectOption> getCurrencyOptions() {
		if (typeOptions == null) {
			typeOptions = new List<SelectOption>();
			for (CurrencyType rate : [Select c.IsoCode From CurrencyType c]) {
				typeOptions.add(new SelectOption(rate.IsoCode, rate.IsoCode));
			}
		}
		return typeOptions;
	}
	
	private static void initRates() {
		CurrencyData.rateMap = new Map<String,Decimal>();
		for (CurrencyType rate : [Select c.Id, c.IsoCode, c.ConversionRate From CurrencyType c]) {
			CurrencyData.rateMap.put(rate.IsoCode, rate.ConversionRate);
		}
	}
	
	public class CurrencyDataException extends Exception {}

}