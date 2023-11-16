/* 
    Date: 
    - 02-10-2022
    Author, Department: 
    - Collin Wischmeyer, Eats BI
    Sponsor, Department: 
    - None, None
    Treatment, description: 
    - dunningWarning, A treatment to go to folks on Play and bright products that are set to expire soon
    Desired population:
    - Active subscriptions set to expire in the next two months
    Testing split:
    - 50/50, test/control
    Exclusions:
    - N/A - add a note about business logic
    Ect:
    - 
    - N/A - add any addn'l relevant info
*/
/********   ********   ********   ********   ********   ********   ********   ********/
/********   Dev pull, need card exp data                          *******/
/********   ********   ********   ********   ********   ********   ********   ********/

BEGIN Try
INSERT INTO collinw.treatment_dunningWarning (              
        subscription_id ,                
        product ,  
        variant ,    
        current ,      
        days_till_expiration,
        dog_name )  
/*A random set of ten*/

SELECT a.subscription_Id
        ,product_line
        ,CASE 
            WHEN RAND()<.5 THEN 0 
            ELSE 1 
        END as variant 
        ,1
        , datediff('day',subscription_expires_at,GETDATE()) :: int
        ,dog_name
FROM common.onebark_subscriptions a
where datediff('day',subscription_expires_at,GETDATE()) :: int < 60


limit 10  --in prod this would pull all of these folks of course, but here we limit in interest of quey run times 
            -- Used to flex treatment text 
   

   
END TRY  
BEGIN CATCH  
      EXECUTE   
        SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage;  
END CATCH 

/*Getting some with an overlap for test cases */
/*
SELECT a.subscription_Id
        ,product_line
        ,CASE 
            WHEN RAND()<.5 THEN 0 
            ELSE 1 
        END as variant 
        ,1
        , datediff('day',subscription_expires_at,GETDATE()) :: int
        ,dog_name
FROM common.onebark_subscriptions a
where datediff('day',subscription_expires_at,GETDATE()) :: int < 60

limit 5--in prod this would pull all of these folks of course, but here we limit in interest of quey run times 


UNION 
SELECT a.subscription_Id
        ,product_line
        ,CASE 
            WHEN RAND()<.5 THEN 0 
            ELSE 1 
        END as variant 
        ,1
        , datediff('day',subscription_expires_at,GETDATE()) :: int
        ,dog_name
FROM common.onebark_subscriptions a
where datediff('day',subscription_expires_at,GETDATE()) :: int < 60

limit 5--in prod this would pull all of these folks of course, but here we limit in interest of quey run times 

UNION 
SELECT a.subscription_Id
        ,product_line
        ,CASE 
            WHEN RAND()<.5 THEN 0 
            ELSE 1 
        END as variant 
        ,1
        , datediff('day',subscription_expires_at,GETDATE()) :: int
        ,dog_name
FROM common.onebark_subscriptions a
where datediff('day',subscription_expires_at,GETDATE()) :: int < 60

limit 5--in prod this would pull all of these folks of course, but here we limit in interest of quey run times 

)

*/