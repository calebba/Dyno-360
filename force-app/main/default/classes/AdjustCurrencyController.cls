public with sharing class AdjustCurrencyController {
	
	private Double conversionValue;
	public String noDecimalValue {get; set;}
	public String conversionFormatted {get; set;}
	
	public AdjustCurrencyController() {
		conversionValue = 0.0;
		if (noDecimalValue == 'No'){
			conversionValue = 0;
		}
		conversionFormatted = null;
	}
	
	public Double getConversionValue() {
		return conversionValue;
	}
	
	public void setConversionValue(Double cv) {
		if(cv != null) {
			conversionValue = cv;
			String tempFormat = cv + '';
			
			List<String> strSplit = new List<String>();
			if(tempFormat.contains('.')) {
				strSplit = tempFormat.split('\\.',0);
				tempFormat = addCommas(strSplit[0]) + '.' + strSplit[1];
			} else {
				tempFormat = addCommas(tempFormat) + '.00';
			}
			conversionFormatted = tempFormat;
		}
	}
	
	private String addCommas(String str) {
		String newStr = '';
		if(str.length() > 9) {
			//Do it at 3,6,9
			newStr = str.substring(0, str.length()-9) + ',' + str.substring(str.length()-9, str.length()-6) + ',' + str.substring(str.length()-6, str.length()-3) + ',' + str.substring(str.length()-3,str.length());
		} else if(str.length() > 6) {
			//Do it at 3,6
			newStr = str.substring(0, str.length()-6) + ',' + str.substring(str.length()-6, str.length()-3) + ',' + str.substring(str.length()-3,str.length());
		} else if(str.length() > 3) {
			//Do it at 3
			newStr = str.substring(0, str.length()-3) + ',' + str.substring(str.length()-3,str.length());
		} else {
			newStr = str;
		}
		return newStr;
	}
}