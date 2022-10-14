global with sharing class SLIAdjustments {

	public decimal PriceAdjustment { get; set; }
	public decimal QuantityAdjustment { get; set; }
	
	public List<PAndQAdjustment> Adjustments { get; set; }
	
	public SLIAdjustments() {
		PriceAdjustment = 0;
		QuantityAdjustment = 0;
		Adjustments = new List<PAndQAdjustment>();
	}
	
	public void AddLine(string PHL1) {
		Adjustments.add(new PAndQAdjustment(PHL1));
	}
	
	public class PAndQAdjustment {
		public String PHL1 { get; set; }
		public decimal PriceAdjustment { get; set; }
		public decimal QuantityAdjustment { get; set; }
		public PAndQAdjustment(string phl) {
			PriceAdjustment = 0;
			QuantityAdjustment = 0;
			PHL1 = phl;
		} 
	}
}