public with sharing class CourseTriggerHandler {

    //passing in trigger.new(), trigger.old(), and trigger.oldMap() 
    public static void sendEmail(List<Opportunity> courses, List<Opportunity> oldCourses, Map<Id,Opportunity> oldMap){
        
        // Create empty list of Messaging.SingleEmail S Object
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
          // create new list of courses filled with new course entries (trigger.new())
        List<Opportunity> instructorEmailCourses = new List<Opportunity>([SELECT Id, Name, Start_Date__C, Instructor__r.email, Instructor__r.name, StageName From Opportunity WHERE id in :courses]);
          // for each course record 
        for(Opportunity course : instructorEmailCourses){

            // instantiate a new email object 
            Messaging.SingleEmailMessage newemail = new Messaging.SingleEmailMessage();

            // list of instructor email adresses
            List<String> theAdresses = new List<String>();

            if(course.StageName == 'Cancelled'){
                String body = 'Dear: ' + Course.Instructor__r.name + ' Your schedulled course  ' + Course.Name + ' Beginning on' + course.Start_Date__c + 'has been cancelled';
                theAdresses.add(Course.Instructor__r.Email);
                newemail.setToAddresses(theAdresses);
                newemail.setSubject('Cancelled Course');
                newemail.setHtmlBody(body);
                emails.add(newemail);
              
           
            }
            else if(oldMap==Null||oldMap.get(course.Id)==Null){
                if(course.StageName == 'Scheduled'){
        
                    String body = 'Dear: ' + Course.Instructor__r.name + 'You have a new course ' + Course.Name + '. Beginning ' + course.Start_Date__c + '.';
                    theAdresses.add(Course.Instructor__r.Email);
                    newemail.setToAddresses(theAdresses);
                    newemail.setSubject('Scheduled');
                    newemail.setHtmlBody(body);
                    emails.add(newemail);
                }
            }
        }
        
        if(emails.size()>0){
            Messaging.sendEmail(emails, false);
        }
    }
  
    public static void ShareCourse(List<Opportunity> coursesToShare){
        // create list of opportunity share records for later insertion
    List<OpportunityShare> opportunitiesToShare = new List<OpportunityShare>();

        //  for each opportunity in trigger.new 
        for( Opportunity opportunity : coursesToShare) {
            // create opportunity share object
            OpportunityShare shareRule = new OpportunityShare();
            // set field values on share object
            shareRule.OpportunityID =  opportunity.Id;
            shareRule.OpportunityAccessLevel = 'Edit';
            shareRule.UserOrGroupId = opportunity.Instructor__c;

            // add share object to list
            opportunitiesToShare.add(shareRule);
            // insert list
        }
        insert opportunitiesToShare;
    }

    public static void newCourseSchedule(List<Opportunity> courses, List<Opportunity> oldCourses, Map<Id,Opportunity> oldMap){
  
        List<Event> Events = new List<Event>();
        // new list of events, where insertopportunities will be added to.
  
        List<Opportunity> insertedCourses = new List<Opportunity>();
        List<Opportunity> updatedCourses = new List<Opportunity>();
        List<Opportunity> cancelledCourses = new List<Opportunity>();

        // 3 lists of courses, depending on wether a course is added, removed, or changed. the instance of course will be added to the appropriate list
   
        for(Opportunity opportunity : courses){
        // loop through each course record in the courses list

            if(oldMap==Null||oldMap.get(opportunity.Id)==Null){
                insertedCourses.add(opportunity);
            // if there is no oldmap, its a new opportunity, and  that should be inserted
            
            }
     
            else if(opportunity!=oldMap.get(opportunity.Id)){
             // check if something has changed before and after the save. 
                if(opportunity.StageName == 'Cancelled' && oldMap.get(opportunity.Id).StageName!='Cancelled'){
                // checking if specifically, the status has been changed to cancelled
                    cancelledCourses.add(opportunity);
                 // add this particular record to the lsit of cancelled courses

                }
            }    
            else{

                if(opportunity.StageName != 'Completed'){
                    updatedCourses.add(opportunity);
                }
            }
            
            
        }   

        if(insertedCourses.size()>0){

            // this for loop creates a new event object for each new course record and assigns the event the releveant course information
            for(Opportunity opportunity : insertedCourses){
                Event calendarEvent = new Event();
                calendarEvent.Subject = 'Course';
                calendarEvent.StartDateTime = opportunity.Start_Date__c;
                calendarEvent.EndDateTime = opportunity.CloseDate;
                calendarEvent.OwnerId = opportunity.Instructor__c;
                calendarEvent.Location = opportunity.Location__c;
                calendarEvent.WhatId = opportunity.Id;

            
                Events.add(CalendarEvent);
            }
        }
        insert Events;
        // this block of code loops through each course record that is set to cancelled and deletes the id 
        if(cancelledCourses.size()>0){
            Set<Id> cancelledCourseIds = new Set<Id>();
         
            for(Opportunity opportunity : cancelledCourses){

                cancelledCourseIds.add(opportunity.Id);
                

            }
            // delete only the events with ids inside the cancelledcourseIds list of ids
            List<Event> eventsToDelete = new List<Event>([Select Id FROM Event WHERE WhatId in: cancelledCourseIds]);
            
            delete eventsToDelete;
            
        }
        if(updatedCourses.size()>0){
            Map<Id,Event> updatedCourseMap = new Map<Id, Event>();
            Set<Id> oppIdSet = new Set<Id>();
            for(Opportunity opp: updatedCourses){

                oppIdSet.add(opp.Id);

               
        
            }
            List<Event> eventsToUpdate = new List<Event>([SELECT Subject, StartDateTime, EndDateTime, OwnerId, Location, WhatId FROM Event WHERE WhatId in :oppIdSet]);
            if(eventsToUpdate.size()>0){
                for(Event e : eventsToUpdate){
                    updatedCourseMap.put(e.whatId, e);

                }
                for(Opportunity opp : updatedCourses){
                    Event e = updatedCourseMap.get(opp.Id);
                    e.Subject = opp.Name;
                    e.StartDateTime = opp.Start_Date__c;
                    e.EndDateTime = opp.CloseDate;
                    e.OwnerId = opp.Instructor__c;
                    e.Location = opp.Location__c;
                    e.WhatId = opp.Id;
                    System.debug(opp.CloseDate);
                    updatedCourseMap.put(opp.Id, e);
        

                }

                update updatedCourseMap.values();
            }

        }
    }
    public static boolean isFirstTime = true;
   
    public static void generateServiceInvoice(List<Opportunity> courses,Map<Id,Opportunity> oldMap){

        List<Invoice__c> invoiceList = new List<Invoice__c>();
        List<Invoice_Line_Item__c> invoiceLinesToInsert = new List<Invoice_Line_Item__c>();
        Id serviceRecTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Service Invoice').getRecordTypeId();
        Id servicelineRecTypeId = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByName().get('Services').getRecordTypeId();
      
        // check if something has changed before and after the save. 
    
        for(Opportunity opportunity : courses){
            // ensures trigger is only fired once
            if(isFirstTime){
            isFirstTime = false;
                if(opportunity!=oldMap.get(opportunity.Id)){
                    if(opportunity.StageName == 'Completed' && oldMap.get(opportunity.Id).StageName!='Completed'){
                        Invoice__c serviceInvoice = new Invoice__c();
                    
                        serviceInvoice.Course__c = opportunity.Id;
                
                        serviceInvoice.Invoice_Date__c = Date.today();
                        serviceInvoice.RecordTypeId = serviceRecTypeId;
                            
                        invoiceList.add(serviceInvoice);
                    }
                }

            }
    
        }
        if(invoiceList.size()>0){
            upsert invoiceList; 
        }  
        for(Invoice__c invoice : invoiceList){
        
        
            for(integer i =1; i<=5; i++){
                Invoice_Line_Item__c newlineitem = new Invoice_Line_Item__c();
                newlineitem.invoice__c = invoice.id;
                newlineitem.recordtypeid = servicelineRecTypeId;
                newlineitem.name = 'Course Delivery Day ' + i;
                newlineitem.Date__c = Date.today().addDays(i);
                invoiceLinesToInsert.add(newlineitem);
            }
        } 
        upsert invoiceLinesToInsert;
    } 

 }

        
        




