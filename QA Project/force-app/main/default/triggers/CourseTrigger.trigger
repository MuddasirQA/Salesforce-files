trigger CourseTrigger on Opportunity (after insert, after update) {
  if(Trigger.isAfter){
    if(Trigger.isInsert){
        CourseTriggerHandler.ShareCourse(Trigger.new);
        CourseTriggerHandler.newCourseSchedule(Trigger.new, Trigger.old, Trigger.oldMap);
        CourseTriggerHandler.sendEmail(Trigger.new, Trigger.old, Trigger.oldMap);
        
   
    }
    if(Trigger.isUpdate){
      CourseTriggerHandler.generateServiceInvoice(Trigger.new, Trigger.oldMap);
      CourseTriggerHandler.newCourseSchedule(Trigger.new, Trigger.old, Trigger.oldMap);
      CourseTriggerHandler.sendEmail(Trigger.new, Trigger.old, Trigger.oldmap);
    
    }
    if(Trigger.isDelete){
     
    }
}

}