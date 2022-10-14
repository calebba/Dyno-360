trigger ApprovalSubmissionTrigger on Dyno_Nobel_Contract__c (after update) {

      for(Dyno_Nobel_Contract__c c: Trigger.new) {
        if (c.status__c == 'Tender Under Review' || c.status__c == 'Tender Ready for Approval' || c.status__c == 'Contract Ready for Approval') {
 
            // create the new approval request to submit
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitted for approval. Please approve.');
            req1.setObjectId(c.Id);
            // submit the approval request for processing
            try {
                // We use try-catch because the contract may already be in another approval process.
                Approval.ProcessResult result = Approval.process(req1);
                // display if the reqeust was successful
                System.assert(result.isSuccess());  
                System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
            } catch (Exception ex) {}
 
        }
 
    }

}