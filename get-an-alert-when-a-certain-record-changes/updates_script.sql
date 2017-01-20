UPDATE  TOP  ( 200 )  humanresources . employeepayhistory 
SET     modifieddate  =  @ModifiedDate 
WHERE   (  businessentityid  =  @Param1  ) 
       AND  (  ratechangedate  =  @Param2  ) 
       AND  (  rate  =  @Param3  ) 
       AND  (  payfrequency  =  @Param4  ) 
       AND  (  modifieddate  =  @Param5  )