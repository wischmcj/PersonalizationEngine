from barkutils.helpers.config_helpers import write_db_setting

from barkutils.sql.sql_conns import sql_to_pandas

from barkutils.sql.sql_conns import get_redshift_dw_conn

#import os

#print(os.getenv('AWS_ACCESS_KEY_ID_BARK', 'Token Not found'))
#print(os.getenv('AWS_ACCESS_KEY_ID_BARK', 'Token Not found'))

connection_name='redshift'
username='cwischmeyer'
#password=<yourpassword>
password=''
host='mydata.<some_guid_here>.us-east-1.redshift.amazonaws.com'
port=5439
dbname='mydata'
write_db_setting(connection_name=connection_name
                    ,username=username
                    ,password=password
                    ,host=host
                    ,port=port
                    ,dbname=dbname)


conn = get_redshift_dw_conn()
df  = sql_to_pandas("select * from common.retention_orders limit 1").to_json(orient="split")
print(type(df))


