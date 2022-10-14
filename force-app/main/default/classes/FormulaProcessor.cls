public with sharing class FormulaProcessor {
	private static final String ADD = '+';
	private static final String SUBTRACT = '-';
	private static final String MULTIPLY = '*';
	private static final String DIVIDE = '/';
	private static final String LEFTPAREN = '(';
	private static final String RIGHTPAREN = ')';
	private static final String allOperators = '+-*/';
	private static final String allCharacters = '+-*/()';
	private static final String EMPTYCHAR = '';
	private static final String ZERO = '0';
	private static final Map<String, Integer> precedenceMapping = new Map<String, Integer>{ADD => 1,SUBTRACT => 1,MULTIPLY => 2,DIVIDE => 2,LEFTPAREN => 0};
	
	public static Double process(String formulaText) {
		if(formulaText != null && formulaText != '') {
			return runRPNInterpreter(runShuntingYard(tokenizeString(formulaText.trim())));
		} else {
			return 0.00;
		}
	}
	
	public static Double process(String formulaText, List<Formula_Line_Item__c> components) {
		return process(parse(formulaText, components));
	}

	public static Double process(Id formulaId) {
		Formula__c formula = [SELECT Id, Formula_Text__c FROM Formula__c WHERE Id = :formulaId];
		return process(formula.Formula_Text__c, [Select Formula_Component__r.Name, Formula_Component__r.Value__c From Formula_Line_Item__c where Formula__c =:formula.Id]);
	}
	
	public static Double process(Formula__c formula) {
		return process(formula.Formula_Text__c, [Select Formula_Component__r.Name, Formula_Component__r.Value__c From Formula_Line_Item__c where Formula__c =:formula.Id]);
	}
	
	public static String parse(String formulaText, List<Formula_Line_Item__c> components) {
		String parsedText = formulaText;
		
		if (parsedText == null)
			return '';
		
		for (Formula_Line_Item__c component : components) {
			parsedText = parsedText.replaceAll(component.Formula_Component__r.Name, String.valueOf(component.Formula_Component__r.Value__c));
		}
		
		return parsedText;
	}
	
	private static Double runRPNInterpreter(List<String> outputInRPN) {
		Stack numberFieldStack = new Stack();
		String currentValue;
		for(String s : outputInRPN) {
			if(isNumber(s)) {
				numberFieldStack.push(s);
			} else {
				currentValue = s;
				Double a, b = 0.00;
				for(Integer i=0; i<currentValue.length(); i++) {
					if(currentValue.subString(i,i+1) == ADD) {
						a = Double.valueOf(numberFieldStack.pop());
						b = Double.valueOf(numberFieldStack.pop());
						numberFieldStack.push(String.valueOf(b+a));
						break;
					}
					if(currentValue.subString(i,i+1) == SUBTRACT) {
						a = Double.valueOf(numberFieldStack.pop());
						b = Double.valueOf(numberFieldStack.pop());
						numberFieldStack.push(String.valueOf(b-a));
						break;
					}
					if(currentValue.subString(i,i+1) == MULTIPLY) {
						a = Double.valueOf(numberFieldStack.pop());
						b = Double.valueOf(numberFieldStack.pop());
						numberFieldStack.push(String.valueOf(b*a));
						break;
					}
					if(currentValue.subString(i,i+1) == DIVIDE) {
						a = Double.valueOf(numberFieldStack.pop());
						b = Double.valueOf(numberFieldStack.pop());
						if(a != 0) {
							numberFieldStack.push(String.valueOf(b/a));
						} else {
							numberFieldStack.push(ZERO);
						}
						break;
					}
				}
			}
		}
		return Double.valueOf(numberFieldStack.pop());
	}
	
	private static List<String> runShuntingYard(List<String> tokendValues) {
		Stack operatorStack = new Stack();
		List<String> outputInRPN = new List<String>();
		
		for(String s : tokendValues) {
			if(isNumber(s)) {
				outputInRPN.add(s);
			}
			else if(isOperator(s)) {
				while(!operatorStack.isEmpty() && operatorStack.peek() != LEFTPAREN) {
					if(higherPrecedence(operatorStack, s)) {
						outputInRPN.add(operatorStack.pop());
					} else {
						break;
					}
				}
				operatorStack.push(s);
			}else if(s == LEFTPAREN) {
				operatorStack.push(s);
			}else if(s == RIGHTPAREN) {
				while(!operatorStack.isEmpty() && operatorStack.peek() != LEFTPAREN) {
					outputInRPN.add(operatorStack.pop());
				}
				if(!operatorStack.isEmpty()) {
					operatorStack.pop();
				}
			}
		}
		while(!operatorStack.isEmpty()) {
			outputInRPN.add(operatorStack.pop());
		}
		
		return outputInRPN;
	}
	
	private static Boolean isOperator(String val) {
		if(allOperators.contains(val)) {
			return true;
		} else {
			return false;
		}
	}
	
	private static Boolean higherPrecedence(Stack operatorStack, String val) {
		if(!operatorStack.isEmpty()) {
			Integer currentValuePrecedence = FormulaProcessor.precedenceMapping.get(val);
			Integer topOfStackPrecedence = FormulaProcessor.precedenceMapping.get(operatorStack.peek());
			if(topOfStackPrecedence >= currentValuePrecedence) {
				return true;
			}	
		}
		return false;
	}
	
	private static Boolean isNumber(String num) {
		try {
			Double.valueOf(num);
			return true;
		} catch(Exception e) {
			return false;
		}
	}
	
	public static List<String> tokenizeString(String text) {
		List<String> numberFieldList = new List<String>();
		List<String> tokendValues = new List<String>();
		
		for(Integer i=0; i<text.length(); i++) {
			String value = text.substring(i,i+1).trim();
			if(allCharacters.contains(value)) {
				String numValue = EMPTYCHAR;
				for(String s : numberFieldList) {
					numValue += s;
				}
				if(numValue != EMPTYCHAR) {
					numberFieldList.clear();
					tokendValues.add(numValue);
				}
				if(value == SUBTRACT) {//check for possible negative number
					if(i==0) {
						numberFieldList.add(text.substring(i,i+2).trim());
						i++;
					}else if(allCharacters.contains(text.substring(i-1,i).trim())) {
						numberFieldList.add(text.substring(i,i+2).trim());
						i++;
					} else {
						tokendValues.add(value);
					}
				} else {
					tokendValues.add(value);
				}
			} else {
				numberFieldList.add(value);
			}
		}
		if(numberFieldList.size() > 0) {
			String numValue = EMPTYCHAR;
			for(String s : numberFieldList) {
				numValue += s;
			}
			if(numValue != EMPTYCHAR) {
				tokendValues.add(numValue);
			}			
		}
		
		return tokendValues;
	}
	
  class Stack {

    private List<String> stackList = new List<String>();

	public void push(String input) {
		stackList.add(input);
	}
	
	public String pop() {
		return stackList.remove(stackList.size()-1);
	}
	
	public String peek() {
		return stackList.get(stackList.size()-1);
	}
	
	public boolean isEmpty() {
		return stackList.size() == 0;
	}
  }
 
}