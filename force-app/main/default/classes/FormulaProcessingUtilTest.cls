@isTest
public with sharing class FormulaProcessingUtilTest {
	testmethod static void testFormulaProcessingUtilOne() {
		FormulaProcessingUtil runUtil = new FormulaProcessingUtil('2+2');
		System.assertEquals('4', runUtil.execute());
		runUtil = new FormulaProcessingUtil('2-2');
		System.assertEquals('0', runUtil.execute());
		runUtil = new FormulaProcessingUtil('2/2');
		System.assertEquals('1', runUtil.execute());
		runUtil = new FormulaProcessingUtil('2*2');
		System.assertEquals('4', runUtil.execute());
		runUtil = new FormulaProcessingUtil('23.32+(4*2)');
		System.assertEquals('31.32', runUtil.execute());
		runUtil = new FormulaProcessingUtil('(23.32+(4*200))');
		System.assertEquals('823.32', runUtil.execute());
		runUtil = new FormulaProcessingUtil('0+0');
		System.assertEquals('0', runUtil.execute());
		runUtil = new FormulaProcessingUtil('2/0');
		System.assertEquals('0', runUtil.execute());
		runUtil = new FormulaProcessingUtil(null);
		System.assertEquals('0', runUtil.execute());
		runUtil = new FormulaProcessingUtil(' 2 + 2 + 2 + 2 ');
		System.assertEquals('8', runUtil.execute());
		runUtil = new FormulaProcessingUtil('1-2-3');
		System.assertEquals('-4', runUtil.execute());
		runUtil = new FormulaProcessingUtil('-1+3');
		System.assertEquals('2', runUtil.execute());
		runUtil = new FormulaProcessingUtil('2*(-1+3)');
		System.assertEquals('4', runUtil.execute());
		runUtil = new FormulaProcessingUtil('2*(-1+-3)');
		System.assertEquals('-8', runUtil.execute());
		runUtil = new FormulaProcessingUtil('2*(-1*-3)');
		System.assertEquals('6', runUtil.execute());
		runUtil = new FormulaProcessingUtil('3*(-1/-3)');
		System.assertEquals('1', runUtil.execute());
		runUtil = new FormulaProcessingUtil('3/(-1/-3)');
		System.assertEquals('9', runUtil.execute());
		runUtil = new FormulaProcessingUtil('3/(-1/-3)+1');
		System.assertEquals('10', runUtil.execute());
		runUtil = new FormulaProcessingUtil('3+(-1*-3)+1');
		System.assertEquals('7', runUtil.execute());
		runUtil = new FormulaProcessingUtil('3+(-3*-200000)*2');
		System.assertEquals('1,200,003', runUtil.execute());
		runUtil = new FormulaProcessingUtil('100000+100000-100000');
		System.assertEquals('100,000', runUtil.execute());
		runUtil = new FormulaProcessingUtil('100000+100000+-100000');
		System.assertEquals('100,000', runUtil.execute());
	}
}