public with sharing class FormulaProcessingUtil {
	private static String ADD = '+';
	private static String SUBTRACT = '-';
	private static String MULTIPLY = '*';
	private static String DIVIDE = '/';
	private static String LEFTPAREN = '(';
	private static String RIGHTPAREN = ')';
	private static String allOperators = '+-*/';
	private static String allCharacters = '+-*/()';
	private static String EMPTYCHAR = '';
	private static String ZERO = '0';
	private static Map<String, Integer> precedenceMapping = new Map<String, Integer>{ADD => 1,SUBTRACT => 1,MULTIPLY => 2,DIVIDE => 2,LEFTPAREN => 0};
	
	private String formulaText;
	private List<String> outputInRPN = new List<String>();
	private Stack operatorStack;
	private String finalValue;
	public List<String> tokendValues = new List<String>();
	
	public FormulaProcessingUtil(String formulaText) {
		this.formulaText = formulaText;
	}
	
	public String execute() {
		if(this.formulaText != null) {
			operatorStack = new Stack(formulaText.length());
			formulaText = formulaText.trim();
			tokenizeString();
			System.debug('****TOKENED VALUES: ' + tokendValues);
			runShuntingYard();
			System.debug('****OUTPUT IN RPN: ' + outputInRPN);
			runRPNInterpreter();
		} else {
			finalValue = ZERO;
		}
		return finalValue;
	}
	
	private void runRPNInterpreter() {
		Stack numberFieldStack = new Stack(outputInRPN.size());
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
		finalValue = Double.valueOf(numberFieldStack.pop()).format();
	}
	
	private void runShuntingYard() {
		for(String s : tokendValues) {
			if(isNumber(s)) {
				outputInRPN.add(s);
			}
			else if(isOperator(s)) {
				while(!operatorStack.isEmpty() && operatorStack.peek() != LEFTPAREN) {
					if(higherPrecedence(s)) {
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
	}
	
	private Boolean isOperator(String val) {
		if(allOperators.contains(val)) {
			return true;
		} else {
			return false;
		}
	}
	
	private Boolean higherPrecedence(String val) {
		if(!operatorStack.isEmpty()) {
			Integer currentValuePrecedence = precedenceMapping.get(val);
			Integer topOfStackPrecedence = precedenceMapping.get(operatorStack.peek());
			if(topOfStackPrecedence >= currentValuePrecedence) {
				return true;
			}	
		}
		return false;
	}
	
	private Boolean isNumber(String num) {
		try {
			Double.valueOf(num);
			return true;
		} catch(Exception e) {
			return false;
		}
	}
	
	public void tokenizeString() {
		List<String> numberFieldList = new List<String>();
		for(Integer i=0; i<this.formulaText.length(); i++) {
			String value = this.formulaText.substring(i,i+1).trim();
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
						numberFieldList.add(this.formulaText.substring(i,i+2).trim());
						i++;
					}else if(allCharacters.contains(this.formulaText.substring(i-1,i).trim())) {
						numberFieldList.add(this.formulaText.substring(i,i+2).trim());
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
	}
	
  class Stack {
    private Integer maxSize;
    private String[] stackArray;
  
    private Integer top;
  
    public Stack(Integer max) {
      maxSize = max;
      stackArray = new String[maxSize];
      top = -1;
    }
  
    public void push(String j) {
      stackArray[++top] = j;
    }
  
    public String pop() {
      return stackArray[top--];
    }
  
    public String peek() {
      return stackArray[top];
    }
  
    public boolean isEmpty() {
      return (top == -1);
    }
  }
}