/* 
    Date: 
    - 02-10-2022
    Author, Department: 
    - Collin Wischmeyer, Eats BI
    Sponsor, Department: 
    - None, None
    Treatment, description: 
    - recentContact, A treatment to let consultants know that customers recently contacted 
                    - Also to present a survey to customers on how our service was 
    Desired population:
    - Active customers with a happy contact in the past 15 days
    Testing split:
    - 50/50, test/control
    Exclusions:
    - N/A - add a note about business logic
    Ect:
    - 
    - N/A - add any addn'l relevant info
*/

/********   ********   ********   ********   ********   ********   ********   ********/
/********      Dev pull, data is interventions not happy interactions    ********/
/********   ********   ********   ********   ********   ********   ********   ********/

/*TRUNCATE TABLE collinw.treatment_recentContact */
/*SELECT * FROM collinw.treatment_recentContact */
BEGIN Try

INSERT INTO collinw.treatment_recentContact (              
        user_id ,                
        product ,  
        variant ,    
        current ,      
        days_since_contact,
        convo_type,
        who_started_convo)  
/*A random set of ten*/
/*The thinking with the union is to have 0 act as control 
   and have 2 act as variant for the BARK started convos*/

SELECT * FROM (
SELECT hs.subscription_id
        ,'All'
        ,CASE WHEN RAND()<.5 THEN 0 ELSE 2 END as variant 
        ,1
        , datediff('day' ,date_intervention_applied_et, GETDATE())
        ,convo_type
        ,who_started_convo
FROM common.happy_subscription_costs hs
where datediff('day' ,date_intervention_applied_et, GETDATE())<70
        AND convo_type IS NOT NULL and who_started_convo IN ('agent', 'welcome')
--in prod this would pull all of these folks of course, but here we limit in interest of quey run times 
UNION
SELECT hs.subscription_id
        ,'All'
        ,CASE WHEN RAND()<.5 THEN 0 ELSE 1 END as variant 
        ,1
        , datediff('day' ,date_intervention_applied_et, GETDATE())
        ,convo_type
        ,who_started_convo
FROM common.happy_subscription_costs hs
where datediff('day' ,date_intervention_applied_et, GETDATE())<50
        AND convo_type IS NOT NULL and who_started_convo IN ('customer')
) a
limit 10--in prod this would pull all of these folks of course, but here we limit in interest of quey run times 


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


/*

SELECT * FROM  collinw.treatment_recentContact
*/

/*Getting some with an overlap for test cases */
/*

SELECT a.box_user_id
        ,'eats'
        ,CASE 
            WHEN RAND()<.5 THEN 0 
            ELSE 1 
        END as variant 
        ,1
        , 53 + (10 - (10 *RAND()) )
FROM common.onebark_customers a
        LEFT JOIN 
where(total_active_classic_subscriptions+total_active_bright_subscriptions + total_active_superchewer_subscriptions ) > 1
        and  is_ever_eats::int = 0

limit 5--in prod this would pull all of these folks of course, but here we limit in interest of quey run times 


UNION 

SELECT a.box_user_id
        ,'eats'
        ,CASE 
            WHEN RAND()<.5 THEN 0 
            ELSE 1 
        END as variant 
        ,1
        , 53 + (10 - (10 *RAND()) )
FROM common.onebark_customers a
where(total_active_classic_subscriptions+total_active_bright_subscriptions + total_active_superchewer_subscriptions ) > 1
        and  is_ever_eats::int = 0

limit 5--in prod this would pull all of these folks of course, but here we limit in interest of quey run times 

UNION 

SELECT a.box_user_id
        ,'eats'
        ,CASE 
            WHEN RAND()<.5 THEN 0 
            ELSE 1 
        END as variant 
        ,1
        , 53 + (10 - (10 *RAND()) )
FROM common.onebark_customers a
where(total_active_classic_subscriptions+total_active_bright_subscriptions + total_active_superchewer_subscriptions ) > 1
        and  is_ever_eats::int = 0

limit 5--in prod this would pull all of these folks of course, but here we limit in interest of quey run times 

*/