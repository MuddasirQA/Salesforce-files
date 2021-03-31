trigger InvoiceTrigger on Invoice__c (after insert, after update, before insert, before update) {
  
  if(Trigger.isAfter){
    if(Trigger.isInsert){
     
        
   
    }
    if(Trigger.isUpdate){
 
    
    }
    if(Trigger.isDelete){
     
    }
}
if(Trigger.isBefore){
  if(Trigger.isInsert){
    InvoiceTriggerHandler.UpdateAutoNumbers(Trigger.new);

  }
}


}