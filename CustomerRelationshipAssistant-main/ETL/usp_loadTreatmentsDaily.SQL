/* 
    Date: 
    - 02-10-2022
    Author, Department: 
    - Collin Wischmeyer, Eats BI
    Sponsor, Department: 
    - None, None
    Description: 
    - This ETL calculatates all of the treatment text and product for folks that should have 
        each treatment and inserts the result into the current_treatments table
    - It also dumps the previous contents of the table to the history table
    Desired population:
    - dogs with birthdays in the next 60 days
    Testing split:
    - 33/33/33, test/variant1/variant2
    - variants differ by including current name or not
    Exclusions:
    - N/A - add a note about business logic
    - 
    - N/A - add any addn'l relevant info
*/

/********   ********   ********   ********   ********   ********   ********   ********/
/********   Dev pull, need to filer on age                          *******/
/********   ********   ********   ********   ********   ********   ********   ********/
/*Also need to evaluate the structure here, I have 30 folks total on 3 treatments right now
    and the instert is inserting 188 rows due to the product and variant split
*/
CREATE OR REPLACE PROCEDURE collinw.load_treatments()
AS $$
DECLARE
  min_val int;
BEGIN

INSERT INTO collinw.current_treatments  (  
        treatment_code                 
        ,product                       
        ,source_system               
        ,variant          
        ,treatment_text
        ,treatment_title               
        ,id                            
        ,id_type                       
)
with split as (
    SELECT 1  as n 
        union 
    select 2 
        union 
    select 3 
        union 
    select 4 
        union 
    select 5
),treatment_info as (
    SELECT a.treatment_code
            ,a.id_type
            ,b.product
            ,b.source_systems
            ,b.variants
            ,b.treatment_text
            ,b.treatment_text_input_fields
            ,b.treatment_title
            ,b.treatment_title_input_fields
            ,b.treatment_detail_id
    FROM collinw.dim_treatments a 
        LEFT JOIN collinw.treatment_details b on a.treatment_code = b.treatment_code
)
,products_split as ( 
    
        select n, TRIM(SPLIT_PART(b.product, '|', n)) AS val, 'products' as col, treatment_code, treatment_detail_id
        from treatment_info b
            CROSS JOIN  split a
)    
,variants_split as (
    select n, TRIM(SPLIT_PART(b.variants, '|', n)) AS val, 'variants' as col, treatment_code, treatment_detail_id
    from treatment_info b
        CROSS JOIN  split a
)
,treatment_info_split as (
    SELECT DISTINCT a.treatment_code
            ,a.id_type
            ,a.product as product_list
            ,c.val as product 
            ,b.val as variant
            ,a.source_systems
            ,a.treatment_text
            ,a.treatment_text_input_fields
            ,a.treatment_title
            ,a.treatment_title_input_fields
            
    FROM treatment_info a
        LEFT JOIN variants_split b on b.treatment_detail_id = a.treatment_detail_id 
        LEFT JOIN products_split c on c.treatment_detail_id = a.treatment_detail_id  
    WHERE TRIM(b.val) <> '' and TRIM(c.val) <> '' 
) 
/*recentContact*/
        SELECT DISTINCT b.treatment_code  
        ,CASE 
            WHEN b.product_list <> ''
                THEN b.product
            ELSE 'All'
        END as product -- an attempt to reduct unecessary rows
        ,b.source_systems
        ,b.variant
        ,REPLACE(treatment_text,'{0}', convo_type) as treatment_text
             --Hard coded, need to be functionalized
        ,treatment_title    
        ,a.user_id as id           
        ,'user' as id_type      
        FROM collinw.treatment_recentContact a 
            LEFT JOIN treatment_info_split b on a.variant =b.variant

                                            --AND  a.product=b.product  Not joining on this 
                                              --  as the product the customer was brought in omn
                                              --  might not be their only product
        WHERE b.treatment_code =  'RHC'

UNION
/*dunningWarning*/

  SELECT   DISTINCT b.treatment_code  
        ,CASE 
            WHEN b.product_list <> ''
                THEN b.product
            ELSE 'All'
        END as product -- an attempt to reduct unecessary rows
        ,b.source_systems
        ,b.variant
        ,REPLACE(REPLACE(treatment_text,'{0}', dog_name), '{1}', days_till_expiration::int) as treatment_text
             --Hard coded, need to be functionalized
        ,treatment_title    
        ,a.subscription_id as id           
        ,'subscription' as id_type      
        FROM collinw.treatment_dunningWarning a
              LEFT JOIN treatment_info_split b ON a.variant =b.variant 
                                            --AND  a.product=b.product  Not joining on this 
                                              --  as the product the customer was brought in omn
                                              --  might not be their only product
        WHERE b.treatment_code =  'SDW'
UNION
/*dogBirthday*/
SELECT    DISTINCT b.treatment_code  
        ,CASE 
            WHEN b.product_list <> ''
                THEN b.product
            ELSE 'All'
        END as product -- an attempt to reduct unecessary rows
        ,b.source_systems
        ,b.variant
        ,REPLACE(REPLACE(treatment_text,'{0}', dog_name), '{1}', birthday_num) as treatment_text
             --Hard coded, need to be functionalized
        ,REPLACE(treatment_title  ,'{0}', dog_name) as treatment_title 
        ,a.dog_id as id           
        ,'dog' as id_type     
        FROM collinw.treatment_dogbirthday a
              LEFT JOIN treatment_info_split b on a.variant =b.variant
                                            --AND  a.product=b.product  Not joining on this 
                                              --  as the product the customer was brought in omn
                                              --  might not be their only product
        WHERE b.treatment_code =   'DBR'

/*
END TRY  
BEGIN CATCH  
      EXECUTE   
      WITH   SELECT  
    ERROR_NUMBER() AS       ErrorNumber  
    ,ERROR_SEVERITY() AS    ErrorSeverity  
    ,ERROR_STATE() AS       ErrorState  
    ,ERROR_PROCEDURE() AS   ErrorProcedure  
    ,ERROR_LINE() AS        ErrorLine  
    ,ERROR_MESSAGE() AS     ErrorMessage;  
END CATCH */
;
END;
$$ LANGUAGE plpgsql;
