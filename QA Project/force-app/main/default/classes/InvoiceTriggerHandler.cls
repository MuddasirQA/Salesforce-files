public class InvoiceTriggerHandler {
    
    public static void UpdateAutoNumbers(List<Invoice__c> courseInvoices){
        Auto_Number__c[] Index = [SELECT  Service_Invoice_Index__c, Expense_Invoice_Index__c FROM Auto_Number__c];
        
        Auto_Number__c incr = [SELECT Service_Invoice_Index__c, Expense_Invoice_Index__c FROM Auto_Number__c LIMIT 1];
        List<Auto_Number__c> toUpdate = new List<Auto_Number__c>();
        
        String ServiceRecordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Service Invoice').getRecordTypeId();
        String ExpenseRecordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Expense Invoices').getRecordTypeId();
        
        for (Invoice__c a : courseInvoices){
            
            if(a.RecordTypeId == ServiceRecordType){
                
                Decimal toInteger = Index[0].Service_Invoice_Index__c.intValue();
                String toString = toInteger.toPlainString();
                Integer size = toString.length();            
                Integer addZeros = 4 - size;            
                String placeHolder = '';
                
                for(Integer i = 0; i < addZeros; i++){
                    placeHolder += '0';
                }
                
                a.Name = 'INV-{'+ placeHolder + Index[0].Service_Invoice_Index__c + '}';
                
                incr.Service_Invoice_Index__c += 1;
               
            }
            
            else if(a.RecordTypeId == ExpenseRecordType){
                
                Decimal toInteger = Index[0].Expense_Invoice_Index__c.intValue();
                String toString = toInteger.toPlainString();
                Integer size = toString.length();            
                Integer addZeros = 4 - size;            
                String placeHolder = '';
                
                for(Integer i = 0; i < addZeros; i++){
                    placeHolder += '0';
                }
                
                a.Name = 'EXPINV-{' + placeHolder + Index[0].Expense_Invoice_Index__c + '}';
                
                incr.Expense_Invoice_Index__c += 1;
               
                
                
            }
        }
        update incr;
    }


    
}