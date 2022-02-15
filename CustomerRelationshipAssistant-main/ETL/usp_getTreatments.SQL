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
/*
    This a procedure as I will add a log to insert at some point 
*/
CREATE OR REPLACE PROCEDURE collinw.usp_getTreatments(
        id IN int,
        id_type in varchar(255),
        source_system in varchar(255),
        product in varchar(255),
        num_treatments in int,
        JSON OUT varchar(2555)
        )
AS $$
DECLARE
  min_val int;
BEGIN

        SELECT INTO JSON
         Chr(91)  || CHR(123) ||
         LISTAGG( '"' || a.treatment_code|| '"'|| ':' || CHR(123) || 
                    '"product"'|| ':' || '"' || a.product || '", ' || 
                    '"variant"'|| ':' || '"' || a.variant || '",' || 
                     '"treatment_text"'|| ':' || '"' || a.treatment_text || '",' || 
                      '"treatment_title"'|| ':' || '"' || a.treatment_title || '",' || 
                     '"id"'|| ':' || '"' || a.id || '",' || 
                      '"id_type"'|| ':' || '"' || a.id_type || '"' || 
                Chr(125), ',') ||Chr(93)
            from  collinw.current_treatments a
            WHERE a.id = id 
                AND a.product  =  product
                AND a.source_system ilike '%' || source_system || '%'
                AND a.id_type = id_type
            ;           
END;
$$ LANGUAGE plpgsql;

CALL collinw.usp_gettreatments(62310,'dog','BarkRails','eats',0);

SELECT *
FROM collinw.current_treatments

