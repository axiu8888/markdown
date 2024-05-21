
# influxdb 操作


## 查询


查询表 `SHOW MEASUREMENTS ON 数据库名`
```
如: SHOW measurements ON test
```



## 删除操作

1、删除数据

```

DELETE 
FROM guard_info, hs_alarm, hs_all_rates, hs_arrhythmia_alarm, hs_base_package, hs_blood, hs_darma_mattress, hs_ecg_wave, hs_iew_alarm, hs_location, hs_loss_package, hs_mattress_package, hs_offline_algo, hs_patient_alarm, hs_realtime_alarm_record, hs_resp_alarm, hs_resp_filter, hs_resp_xyz_wave, hs_routines_alarm, hs_spo2_wave, hs_sport_point, hs_svm_wave, hs_teleecg_wave_package, hs_teleecg_wave_point, hs_temperature, hs_tidal_volume, hs_tidal_volume_wave, hs_trend_rates, hs_wave_package, hs_wave_point, hs_wit_point, trend_back_data
WHERE time > '2024-05-08T07:00:00Z' AND time < '2024-05-08T07:40:00Z' AND device_id = '12345678'

```

