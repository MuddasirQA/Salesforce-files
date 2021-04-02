@isTest
public with sharing class CourseTriggerHandler_Test {

        @testSetup
        private static void testSetup() {
    
            List<Opportunity> opps = new List<Opportunity>();
            for(Integer i =0; i < 201; i++){
                Opportunity Course = new Opportunity ( Name='DEX450', StageName='Scheduled', Start_Date__c = Date.today(), CloseDate = Date.today().addDays(5), 
                Service_Tax_Rate__c = 0.3, VAT_Rate__c = 0.2, Location__c = 'London', Course__c ='a014L000002DmWEQA0', Instructor__c = '0054L000000Vd4tQAC' );
                                                                                              
                opps.add(Course);
                
            }
    
            insert opps;
    
            List<Auto_Number__c> autoNumberList = new List<Auto_Number__c>();
            Auto_Number__c autoNumService = new Auto_Number__c (Name = 'Service Invoice Number', Service_Invoice_Index__c = 1, Expense_Invoice_Index__c = 1);
            autoNumberList.add( autoNumService);
            
            insert autoNumberList;
    
            
            
            Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User user = [SELECT Id FROM User WHERE profileId = :profile.Id LIMIT 1];
            System.runAs(user){
            }
    
    
        }
        
        @isTest
        public static void EventTest() {
    
            
    
            Test.startTest();
                    List<Opportunity> opps = [SELECT Id, StageName,Name,Start_Date__c,CloseDate, Service_Tax_Rate__c,VAT_rate__c,Location__c, Instructor__c FROM Opportunity ];
                   
                for(Integer i = 0; i < opps.size(); i++){
    
                    opps[i].Start_Date__c = Date.today();
                    
                }
             
                update opps;   
            Test.stopTest();
            System.assertEquals(201, [SELECT count() FROM Event ]);
    
        }
        @isTest
        public static void courseChangedToCancelled(){
        Integer emailLimit = 0;    
        Test.startTest();
            List<Opportunity> opps = [SELECT Id, StageName,Name,Start_Date__c,CloseDate, Service_Tax_Rate__c,VAT_rate__c,Location__c, Instructor__c FROM Opportunity ];
            for(Integer i = 0; i < opps.size(); i++){
    
                    opps[i].StageName = 'Cancelled';
                                     
            }   
            update opps;
            emailLimit= Limits.getEmailInvocations();
            Test.stopTest();
            System.assertEquals(2, emailLimit);
            
        }
        @isTest

        public static void AutoNumGenerator(){
            String serviceRecordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Service Invoice').getRecordTypeId();   
            List<Invoice__c> invoiceList = new List<Invoice__c>();
        
            
            for(Integer i = 0; i<201; i++){
                Invoice__c serviceInvoices = new Invoice__c(Name='invoice', RecordTypeId = serviceRecordType, Course__c = '0064L000002a4zkQAA', Invoice_Date__c = Date.today());
                invoiceList.add(serviceInvoices);
            }
            insert invoiceList;
        
            Test.startTest();
            Test.stopTest();
                List<Invoice__c> invA = [SELECT Name FROM Invoice__c ORDER BY Name ASC LIMIT 1 ];
                List<Invoice__c> invZ = [SELECT Name FROM Invoice__c ORDER BY Name DESC LIMIT 1 ];
                String getFirstInvoice = invA[0].Name;
                String getLastLastInvoice =  invZ[0].Name;

          
                System.assertEquals(201, [SELECT count() FROM Invoice__c]);
                System.assertEquals('INV-{0001}', getFirstInvoice);
                System.assertEquals('INV-{0201}', getLastLastInvoice);
                

        }
        @isTest

        public static void ExpenseAutoNumGenerator(){
            String serviceRecordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Expense Invoices').getRecordTypeId();   
            List<Invoice__c> invoiceList = new List<Invoice__c>();
        
            
            for(Integer i = 0; i<201; i++){
                Invoice__c serviceInvoices = new Invoice__c(Name='abc', RecordTypeId = serviceRecordType, Course__c = '0064L000002a4zkQAA', Invoice_Date__c = Date.today());
                
                invoiceList.add(serviceInvoices);
            }
            insert invoiceList;
        
            Test.startTest();
            Test.stopTest();
                List<Invoice__c> invA  = [SELECT Name FROM Invoice__c ORDER BY Name ASC LIMIT 1 ];
                List<Invoice__c> invZ = [SELECT Name FROM Invoice__c ORDER BY Name DESC LIMIT 1 ];
                String getFirstInvoice = invA[0].Name;
                String getLastInvoice = invZ[0].Name;

          
                System.assertEquals(201, [SELECT count() FROM Invoice__c]);
                System.assertEquals('EXPINV-{0001}', getFirstInvoice);
                System.assertEquals('EXPINV-{0201}', getLastInvoice);
                

        }
        @isTest

        public static void generateServiceInvoice(){
        String serviceRecordType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Service Invoice').getRecordTypeId();   
             
            Test.startTest();
                List<Opportunity> oppList = [SELECT StageName,Name,Start_Date__c,CloseDate, Service_Tax_Rate__c,VAT_rate__c,Location__c, Instructor__c FROM Opportunity ];
                for(Integer i = 0; i < oppList.size(); i++){
        
                        oppList[i].StageName = 'Completed';
                       
                                         
                }   
                upsert oppList;
               
                Test.stopTest();
                List<Invoice__c> invoiceList = [Select Id FROM Invoice__c];
                System.assertEquals(1, invoiceList.size());

        }
     

    }