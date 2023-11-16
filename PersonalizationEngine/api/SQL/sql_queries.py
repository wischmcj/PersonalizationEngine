

def queryBuild (cols, schema, table, filters = '', limit = ''):
    ret = ''
    if (filters):
        ret= 'SELECT ' + cols + ' FROM ' + schema + current_treatments_table + limit
    else:
        ret= 'SELECT ' + cols + ' FROM ' + schema + current_treatments_table + ' WHERE ' + filters + limit
    return ret
schema = 'collinw.'
limit = ' limit 1'

#TA. - BLES.!
current_treatments_table = 'current_treatments'
dim_treatments_table =  'dim_treatments'
treatment_details_table = 'treatment_details'

#Field Lists 
all_curr_treatments = 'current_treatment_id, treatment_code, product, source_system, variant , treatment_text, treatment_title, id, id_type, insert_dt_utc'


#Queries
get_all_current_treatments = queryBuild(all_curr_treatments,schema,current_treatments_table,limit)
get_dim_treatments = queryBuild(all_curr_treatments,schema,dim_treatments_table,limit)
get_treatment_details = queryBuild(all_curr_treatments,schema,treatment_details_table,limit)



print(get_all_current_treatments)
