#!/bin/sh
#sql1='select time, warning_flag_field, status_field, latitude, longitude, altitude, satellite_speed, direction, acc_status, flow_id, sum_mileage_type, total_mileage, oil_consumption, vehicle_voltage, total_run_time, add_total_mileage, engine_speed, vehicle_speed, air_flow, inlet_temperature, inlet_pressure, fault_code_num, coolant_temperature, vehicle_env_temperature, fuel_pressure, atmosphere_pressure, accelerator_pedal_position, remaining_oil, engine_load, team_id from '
sql1='select * from '
sql2=' where _c0<1684994002000 '
db=db01
user=root
pass=taosdata
taos=taos

num=1
for tb in $(${taos} -u${user} -p${pass} -s "show ${db}.tables"|grep '|'|grep -v 'table_name'|awk '{print $1}' )
do
sql=$(echo "$sql1 ${db}.${tb} $sql2 >>${tb}.csv;")
${taos} -u${user} -p${pass} -s "$sql" 1>/dev/null 2>/dev/null

echo "$num ${tb} dump out done!"
num=$(($num+1))
done