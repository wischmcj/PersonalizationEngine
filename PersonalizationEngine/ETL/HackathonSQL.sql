/*CREATE SCHEMA collinw */

/*
        Sales Pitch:

                We want to be our customer's one-stop-shop for pet care needs. We can't do this if our customers are seeing various
                product lines as different destinations. After all, the average customer our only converses with us **5-6** times 
                during our relationship. Spread that across product lines and we're suddenly a small part of their needs.

                However, if we share every experience across product lines, we'll capitalize on these rar to impress our 
                customers and keep them coming back.

                This project is about leveraging each moment to its full potential and unifying the customer experience. For every major event that happens in our relationship.
                


        Description:

                This flask API takes a source_system, product, customer_id and subscription_id and returns a list of 'treatments'.
                Treatments represent bark level experience that should inform what/where/when is presented to the customer. 
                I may also put together an Angular app to display these via user request

        Example Source Systems and Use Cases:        

                Happy Interations
                        Happy is interacting with a customer. To inform their interaction they give the UI the customer, product  (optional) and sub_id (optional)
                                Admin, a chome plug-in or a stand-alone app would act as their UI
                                The UI they are using returns the customer treatment info. They can then use the related info to improve their interaction.
                                        "I see you recently talked with us recently ", happy birthday, looks like we need payment/address info, React to NPS scores

                Customer Dashboard Visits 
                        A customer signs into BARK and views their dashboard (either or both eats and play)
                                The ruby app calls the api and the api returns all treatments. 
                                The ruby app then decides which of these to use and in what way.
                                        Offer xsell, prompt information update, happy birthday message, BARK content suggestions
                                        React to NPS scores 

                Mobile App
                        A customer signs into their bark app. 
                                The app calls the api just the same as the ruby app, decides how to use response 
                                Options are similar to the above, and can be coordiated with the above                       

        Functionality overview:        
                - API is fully parameterized, as data driven as possible 
                - API calls sp_getTreatments which returns the needed JSON
                - sp_getTreatments runs off the current_treatments table, querying based of passed params 
                - current_treatments table is loaded daily after source_[treatmentName] tables are loaded 
                - Source tables are loaded daily at 1,2,3, etc. AM
                        - Populated via any way we like: sp reading from various tables, python jobs, model output tables, etc.
        
        Ideal State:
                - VWO A/B Test analytics
                        - VWO's API allows for the creation and editing of campaigns
                        - We can investigate sending this data through them and anaalyzing results through them 
                        - Might involve accessing event info on treatment views
                - To injest data from rudderstack and update treatments in near real time 
                        - Redshift would deal with organizing the date (customer activity table)
                                - This process would read every X minutes (call it 15, but this will depend on volume and SQL run time)
                        - treatment_details_real_time
                                - Would severly limit the customization options for times sake
                        - current_treatments_real_time
                                - A subset of all the treatments
                                - A seperate table since it is operational
                        - sp_getTreatments_real_time
                                - Read from the last X minutes of activity data 
                                - Update current_treatments_realTime
                - **push** data to passive sites
                        -EX. Zen Desk
                                - API allows ticket creation via post request
                                - We can add this and create tickets off of these rules that *align with all other products initiatives*
                - Pull data direct from third party sites 
                        -EX. Zen Desk
                                - Not all is avaialable in redshift, but there is an API that we can call to pll that information here 
                                - Event data comes through redshift, Other data can be pulled via simple python

         Table Details:
                See below and see figma here: https://www.figma.com/file/<file no longer available>

*/

/* This will serve as the master load table, containing current states 
        In the end we will have a table for each treatment, with a 'current' ind on each row 
                In this way we will store historical data 
        We will also have a history load : customer +sub ids, treatment codes and start ans stop dates
                THis will show who say what a what given time 


        Production ready needs
        Production double checks 
                Compare assignments to presentation event data (We're the events properly displayed )
        */
/** toDelete
CREATE TABLE collinw.PilotDim (
        pilotDim_id int IDENTITY(1,1),  
        product varchar(255) not null,
        customer_id int not null,
        subscription_id int ,
        eats_xsell int not NULL,
        box_xsell int not NUll,
        dog_birthday int not NUll
);*/

/** Current Tables **/

CREATE TABLE collinw.load_log ( -- A template for what should be included in each treatment table 
        load_log_id     int IDENTITY(1,1),                 
        source_table    varchar(255) not null,                 
        dest_table      varchar(255) not null,             
        successful      boolean DEFAULT 1,                  
        load_dt_utd     datetime DEFAULT GETDATE(),
        ErrorNumber     varchar(255) not null,      
        ErrorSeverity   varchar(255) not null,       
        ErrorState      varchar(255) not null,      
        ErrorProcedure  varchar(255) not null,      
        ErrorLine       varchar(255) not null,      
        ErrorMessage    varchar(255) not null       
);
/*DROP TABLE  collinw.load_log  */

CREATE TABLE collinw.current_treatments (--One row per treatment, product, source system and variant quadrupple. kept simple as it is 'exposed' 
        current_treatment_id int IDENTITY(1,1),         -- Primary key
        treatment_code varchar(6) not NULL,                      -- Foreign key to dim_treatments and treatment_details
        product varchar(255) not null,                  -- One per row, potentially 
        source_system varchar(255) not null,            -- One per row, potentially 
        variant varchar(255) not null,                  -- One per row. 1, 0 for test and control, 2,3.... for multi-variant tests
        treatment_text varchar(255) not null,           -- The text specific to this row *with inputs inserted*
        treatment_title varchar(255) not null,          -- The title specific to this row *with inputs inserted*
        id int not null,                                -- The customer, user, subscription ... the treatment applies to
        id_type varchar(255) not null,                  -- The type of the above id
        insert_dt_utc datetime  DEFAULT GETDATE()       -- Self explanatory
) sortkey("id");
/*DROP TABLE  collinw.current_treatments  */

CREATE TABLE collinw.historical_treatments (--One row per treatment, product, source system and variant quadrupple. kept simple as it is 'exposed' 
        historical_treatment_id int IDENTITY(1,1),         -- Primary key
        variant varchar(255) not null,                  -- One per row. 1, 0 for test and control, 2,3.... for multi-variant tests
        id int not null,                                -- The customer, user, subscription ... the treatment applies to
        id_type varchar(255) not null,                  -- The type of the above id
        start_dt_utc datetime  DEFAULT GETDATE(),       -- Cut for time, date when treatment first applied 
        end_dt_utc datetime  DEFAULT GETDATE(),         -- Cut for time, date when treatment last applied 
        insert_dt_utc datetime  DEFAULT GETDATE()       -- Self explanatory
);
/* DROP TABLE  collinw.historical_treatments  */

CREATE TABLE collinw.dim_treatments ( -- At a treatment level granularily, variant stored in treatment_varient
        treatment_id int IDENTITY(1,1),                         -- Primary key
        products varchar(255) not null,                         -- Products recieving the treatment. alphabetical, pipe delimiated 
        treatment_name varchar(255) not NULL UNIQUE,          -- full name of treatment
        treatment_description varchar(255) not NULL UNIQUE,   -- description of treatment
        treatment_code varchar(255) not NULL UNIQUE,             -- 3-4 letters represnting the treatment
        id_type varchar(255) NOT NULL,                                  -- The type of the id in the source table 
        num_variants int not null,                              -- for just a control group with a test groupthis will be 1 variant , else greater
        source_table varchar(255) not null,                     -- For example the treatment eats xsell comes from collinw.treatment_eatsxsell 
        insert_dt_utc datetime  DEFAULT GETDATE(),              -- Self explanatory
        current boolean DEFAULT 1                               -- These tables should not be changed. Current defaults to 1 and changes when a new row replaces an old one 
);
/*DROP TABLE  collinw.dim_treatments  */

CREATE TABLE collinw.treatment_details (-- Each treatment having as many as one row per source system, product, and variant, as little as 1
        treatment_detail_id int IDENTITY(1,1),          -- Primary key 
        source_systems varchar(255) not null,           -- One row may have multiple. alphabetical, pipe delimiated (Ruby|MoblieApp|Admin|...)
        product varchar(255) not null,                  -- One row may have multiple. alphabetical, pipe delimiated (Eats|Classic|...)
        treatment_code varchar(10) not NULL UNIQUE,     -- 3-4 letters represnting the treatment (EXS, PXS, DBS ...)
        variants varchar(255)  not null,                          -- One row may have multiple. ascending order, pipe delimiated (0|1|2|...)
        -- For the below, think C++ printf. treatment_text/title = "First input goes here {0}, and the second goes here  {1} and on and on {3} ..."
        treatment_text varchar(255) not null,                   -- The portions of the text to be displayed with place holders for inputs. 
                                                                        --"First input goes here {0}, and the second goes here  {1} and on and on {3} ..."
        treatment_text_input_fields varchar(255) not null,      -- Fields from source table. *in order of appearance* (see above), pipe delimiated. ex. inputs = value1|value2|value3|....
        treatment_title varchar(255) not null,                  -- The portions of the text to be displayed with place holders for inputs. 
                                                                        --"First input goes here {0}, and the second goes here  {1} and on and on {3} ..."
        treatment_title_input_fields varchar(255) not null,     -- Fields from source table. *in order of appearance* (see above), pipe delimiated. ex. inputs = value1|value2|value3|....
        insert_dt_utc datetime  DEFAULT GETDATE(),           -- See below. If configs change, rows shouldn't be updated, a new row should be entered
        current boolean DEFAULT 1                               -- These tables should not be changed. Current defaults to 1 and changes when a new row replaces an old one 
);
/*DROP TABLE  collinw.treatment_details */


/*****Template *****/
CREATE TABLE collinw.treatment_template ( -- A template for what should be included in each treatment table 
        template_ind int IDENTITY(1,1),                 -- Primary key, may not be needed but its convenient
        *_id int not null,                              -- May be customer, user, subscription ... depending what the treatment applies to
        product varchar(255) not null,                  -- product associated with the customer, sub, ...
        variant varchar(255) not null,                  -- The variant the customer, sub, ... should recieve (0,1,2,...)
        current boolean DEFAULT 1,                      -- These tables should not be changed. Current defaults to 1 and changes when a new row replaces an old one 
        /*** Treatment and text input columns ***/      -- Columns specific to the treatment. Listed in treatment_details.treatment_text_input_fields
        date_added_utc datetime DEFAULT GETUTCDATE(),   -- To track when configs changed 
        updated_dt_utc datetime DEFAULT GETUTCDATE()    -- For when updates have to happen. Should be rare.
);
/*DROP TABLE  collinw.treatment_template  */

/*example treatment tables*/
/*change this to dunning warning*/
CREATE TABLE collinw.treatment_dunningWarning(          -- Customer level example 
        dunningWarning_id int IDENTITY(1,1),            -- Primary key, may not be needed but its convenient
        subscription_id int not null,                   -- The subscription that is going to 'dun' soon
        product varchar(255) not null,                  -- product associated with the customer
        variant varchar(255) not null,                  -- The variant the subscription should recieve
        current boolean DEFAULT 1,                      -- Current defaults to 1 and changes when a new row replaces an old one 
        
        days_till_expiration numeric(10,2),            -- Used to flex treatment text 
        dog_name varchar(255) not null,                 -- Used to flex treatment text 
          
        date_added_utc datetime DEFAULT GETDATE(),   -- To track when configs changed 
        updated_dt_utc datetime DEFAULT GETDATE()   -- For when updates have to happen. 
);
/*DROP TABLE  collinw.treatment_eatsXsell  */

CREATE TABLE collinw.treatment_dogBirthday (            -- dog level example 
        dogBirthday_id int IDENTITY(1,1),               -- Primary key, may not be needed but its convenient
        dog_id int not null,                            -- The id of a dog with an upcomming birthday
        product varchar(255) not null,                  -- product associated with the dog (multiple rows per dog possible)
        variant varchar(255) not null,                  -- The variant the dog should recieve
        current boolean DEFAULT 1,                      -- These tables should not be changed. Current defaults to 1 and changes when a new row replaces an old one 
       
        days_till_birthday numeric(10,2),               -- Used to flex treatment text 
        birthday_num varchar(255),               -- Used to flex treatment text 
        dog_name  varchar(255),               -- Used to flex treatment text 
        --product_suggestion varchar(255) Not NULL,     -- Example of possible improvements
            
        date_added_utc datetime DEFAULT GETDATE(),   -- To track when configs changed 
        updated_dt_utc datetime DEFAULT GETDATE()   -- For when updates have to happen. 
);
/*DROP TABLE  collinw.treatment_dogBirthday  */

CREATE TABLE collinw.treatment_recentContact ( --Subscription level example 
        subscriptionAnniversary_id int IDENTITY(1,1),   -- Primary key, may not be needed but its convenient
        user_id int not null,                           -- The id of a user that recently contacted us
        product varchar(255) not null,                  -- product associated with the subscription (multiple rows per dog possible)
        variant varchar(255) not null,                  -- The variant the subscription should recieve
        current boolean DEFAULT 1,                      -- These tables should not be changed. Current defaults to 1 and changes when a new row replaces an old one 
        
        days_since_contact numeric(10,2),            -- Used to flex treatment text 
        convo_type varchar(255) not null,  
        who_started_convo varchar(255) not null,            -- Used to flex treatment text 
        --product_suggestion varchar(255) Not NULL,     -- Example of possible improvements
        
        date_added_utc datetime DEFAULT GETDATE(),   -- To track when configs changed 
        updated_dt_utc datetime DEFAULT GETDATE()   -- For when updates have to happen. 
);
/*DROP TABLE  collinw.treatment_recentContact  */

/*truncate table collinw.dim_treatments*/
/*Inserting data*/
INSERT INTO  collinw.dim_treatments ( -- At a treatment level granularily, variant stored in treatment_varient
        products                        
        ,treatment_code       
        ,treatment_name   
        ,treatment_description        
        ,id_type                         
        ,num_variants                    
        ,source_table        
)   
VALUES 
/*Note that these fist two stem from an experience a customer has with bark
        As this is an important experience, we want sieze this opportunity to interact with our customer*/
        ( 
        'bright|classic|sc'                                 
        ,'RHC'       
        ,'Recent Happy Contact'   
        ,'To let consultants know that customers recently contacted.'        
        ,'user'                         
        ,2                   
        ,'treatment_recentContact'       
),( 
       'bright|classic|sc|eats'                        
        ,'DBR'       
        ,'Dog Birthday Reminder'   
        ,'To let consultants and customers know that a dog has a birthday coming up'        
        ,'dog'                         
        ,2                    
        ,'treatment_dogBirthday'          
),
( 
        'bright|classic|sc'                       
        ,'SDW'       
        ,'Subscription Dunning Warning'   
        ,' A treatment to go to folks on Play and bright products that are set to expire soon'        
        ,'subscription'                         
        ,1                    
        ,'treatment_dunningWarning'       
)
/* truncate TABLE  collinw.dim_treatments  */
/* SELECT * FROM collinw.dim_treatments  */

/* truncate TABLE  collinw.treatment_details  */

INSERT INTO collinw.treatment_details (
        source_systems  -- Admin|BarkPost|BarkRails|CRA|EatsRails|MLPE|MNA|Other|Simon|VWO|ZenDesk
        ,product 
        ,treatment_code 
        ,variants
        ,treatment_text              
        ,treatment_text_input_fields    
        ,treatment_title          
        ,treatment_title_input_fields                           
)
/* Notice that this represents a bark *experience*, bringing our interation to all areas of the business
        */
VALUES /*customer vaiant*/
        ('BarkPost|BarkRails|MLPE|EatsRails|MNA|Simon|VWO' 
        ,'bright|classic|sc|eats'  
        ,'RHC' 
        ,'2'
        ,'We see you contacted us via {0} recently, <a href="url">let us know how it went</a> '              
        ,'convo_type'        
        ,'Recent Customer Service interaction'            
        ,''       )
                ,
        ('Admin|CRA|ZenDesk|MLPE' 
        ,'bright|classic|sc|eats'  
        ,'RHC' 
        ,'0|1'
        ,'We recently contacted this customer recently via {0},  <a href="url">let us know how it went</a> ?'         /*IDK how we would */     
        ,'convo_type'    
        ,'Recent Customer interaction'          
        ,''       )
/*We can use this data structucture to test out different approaches to messaging - do we just interact, or do we upsell?*/
        ,('BarkPost|BarkRails|EatsRails|MLPE|MNA|Simon|VWO'
        ,'bright|classic|sc|eats' 
        ,'DBR' 
        ,'0|1'
        ,'Looks like {0} has a birthday coming up, wish him a happy {1} for us!'           
        ,'dog_name|curr_age'    
        ,'{0}''s Birthday'          
        ,  'dog_name'      )
        ,('BarkPost|BarkRails|EatsRails|MLPE|MNA|Simon|VWO'
        ,'bright|classic|sc|eats' 
        ,'DBR' 
        ,'2'
        ,'Looks like {0} has a birthday coming up, make it a special one with  <a href="url">Bark Shop</a>.'           
        ,'dog_name|curr_age'    
        ,'{0}''s Birthday'          
        ,  'dog_name'      )
        ,('Admin|CRA|ZenDesk|MLPE' 
        ,'bright|classic|sc|eats' 
        ,'DBR' 
        ,'0|1'
        ,'Looks like {0} has a birthday coming up in {1} day(s). Be sure to wish him a happy {2}!'           
        ,'dog_name|days_till_birthday|curr_age'    
        ,'{0}''s Birthday'          
        ,  'dog_name'      )
        
, ('BarkPost|BarkRails|MLPE|MNA|Simon|VWO'
        ,'bright|classic|sc|eats' 
        ,'SDW' 
        ,'1|0'
        ,'{0}''s scubscription will expire in {1} day(s). Renew Now'              
        ,'dog_name|days_till_expiration'    
        ,'Subscription Expiring Soon'          
        ,''            ),
        ('Admin|CRA|ZenDesk|MLPE' 
        ,'bright|classic|sc|eats' 
        ,'SDW' 
        ,'1|0'
        ,'{0}''s scubscription will expire in {1} day(s). Ask if they plan to renew'              
        ,'dog_name|days_till_expiration'    
        ,'Subscription Expiring Soon'          
        ,'' )



/*Functions */

/*
select * from pg_proc where proname ilike '%f_sql_greater%'

create function collinw.udf_tes(float, float)
  returns float
stable
as $$
  select case when $1 > $2 then $1
    else $2
  end
$$ language sql;*/


/*Procedures*/

CREATE OR REPLACE PROCEDURE usp_LogLoad(
         source_table varchar(255)
         , dest_table varchar(255)
        )
AS $$
BEGIN
       
INSERT INTO collinw.load_log  (  
source_table    
,dest_table      
,successful  /*    
,ErrorNumber     
,ErrorSeverity   
,ErrorState      
,ErrorProcedure  
,ErrorLine       
,ErrorMessage */   
)
        SELECT      
        source_table    
        ,dest_table      
        ,successful   /*,
          ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,SQLERRM AS ErrorMessage */
END;
$$ LANGUAGE plpgsql;
