
/* 
    Date: 
    - 02-10-2022
    Author, Department: 
    - Collin Wischmeyer, Eats BI
    Sponsor, Department: 
    - None, None
    Treatment, description: 
    - DogBirthday, A treatment to let consultants and customers know that a dog has a birthday comming up
                    - Also to present a survey to customers on how our service was 
    Desired population:
    - dogs with birthdays in the next 60 days
    Testing split:
    - 33/33/33, test/variant1/variant2
    - variants differ by including current name or not
    Exclusions:
    - N/A - add a note about business logic
    Ect:
    - 
    - N/A - add any addn'l relevant info
*/

/********   ********   ********   ********   ********   ********   ********   ********/
/********   Dev pull, need to filer on age                          *******/
/********   ********   ********   ********   ********   ********   ********   ********/
D
BEGIN TRY  

INSERT INTO collinw.treatment_dogBirthday (              
        dog_id ,                
        product ,  
        variant ,    
        current ,      
        days_till_birthday,
        birthday_num,
        dog_name
        )  
/*A random set of ten */

SELECT dog_id
        ,product_line
        ,CASE 
            WHEN RAND()<.33 THEN 0 
            WHEN RAND()<.66 THEN 1
            ELSE 2
        END as variant 
        ,1
        ,datediff('day' ,date_add('day', ISNULL(dog_birthday_day,1), date_add('month', ISNULL(dog_birthday_month,1),CAST(ISNULL(dog_birthday_year,2020) ::varchar(10)|| '01' || '01' as date) )) , GETDATE()) 
        ,CASE WHEN MOD(dog_age,10) = 1 then dog_age    ::varchar(10) + 'st' 
                WHEN  MOD(dog_age,10) = 2 then dog_Age ::varchar(10)+ 'nd'
                WHEN  MOD(dog_age,10) = 3 then dog_Age ::varchar(10)+ 'rd'
              ELSE  dog_Age ::varchar(10) + 'th'
              end as dog_Age
        ,dog_name
FROM common.onebark_subscriptions 
where --datediff('day' ,date_add('day', ISNULL(dog_birthday_day,1), date_add('month', ISNULL(dog_birthday_month,1),CAST(ISNULL(dog_birthday_year,2020) ::varchar(10)|| '01' || '01' as date) )) , GETDATE()) <30 and 
         dog_birthday_year  > 2000 and  dog_birthday_year<2022 and dog_id is not null
ORDER BY 5 asc
limit 10

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

--in prod this would pull all of these folks of course, but here we limit in interest of quey run times 
