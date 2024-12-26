
# postgresql 的常用命令行操作

------------------------------------

### 连接

连接到命令行界面
```
# 不进入数据库
psql -h 127.0.0.1 -p 5432 -U postgres

# 直接进入某个数据库
psql -h 127.0.0.1 -p 5432 -U postgres -d test

```

------------------------------------

### 导入/导出

```

# 导出
pg_dump -h localhost -p 5432 -U postgres  -d test  -f ./test.dmp

# 导入
psql -h localhost -p 5432 -U postgres -d test -f /test.dmp


# 说明
-h: postgresql服务器地址
-p: 端口
-U: 用户
-d: 数据库
-f: 文件的路径


```

------------------------------------

### 常用命令

```

# 删除数据库
DROP DATABASE test;

# 将字段改为主键
ALTER TABLE hs_disease ADD PRIMARY KEY (id);

```


------------------------------------

### 其他命令

```
\l      列出所有数据库
\dt   列出连接数据库中所有表
\di   列出连接数据库中所有index
\dv  列出连接数据库中所有view
\h    sql命令帮助
\?    \ 所有命令帮助
\q   退出连接
\d tablename  列出指定tablename的表结构

\help         // 获取SQL命令的帮助,同 \h
\quit         // 退出,同 \q
\password dlf // 重新设置用户dlf的密码,然后需要 \q退出后才生效
c:\>psql exampledb < user.sql  // 将user.sql文件导入到exampled数据库中
\h select   // 精细显示SQL命令中的select命令的使用方法
\l          // 显示所有数据库
\dt         // 显示当前数据库中的所有表
\d [table_name]  // 显示当前数据库的指定表的表结构
\c [database_name]  // 切换到指定数据库,相当于use
\du                 // 显示所有用户
\conninfo           // 显示当前数据库和连接信息
\e   // 进入记事本sql脚本编辑状态(输入批命令后关闭将自动在命令行中执行)
\di  // 查看索引(要建立关联)
\prompt [文本] 名称    // 提示用户设定内部变数
\encoding [字元编码名称]  // 显示或设定用户端字元编码
*可以将存储过程写在文本文件中aaa.sql,然后在psql状态下:
\i aaa.sql    // 将aaa.sql导入(到当前数据库)
\df           // 查看所有存储过程（函数）
\df+ name     // 查看某一存储过程
select version();            // 获取版本信息
select usename from pg_user; // 获取系统用户信息
drop User 用户名             // 删除用户
```


------------------------------------


### 通过存储过程删除视图，修改字段长度，再重新创建视图

```
-- 开始事务
begin;
-- 设置锁超时
set local lock_timeout = '2s';

-- 删除依赖视图  
drop view view_super_depart, view_org_count, view_user_permission_bsiness, view_patient_statistics, parent_business_view, view_user_patient, view_patient_user, view_user_business, view_user_medical, view_recipel_item, view_report;  

-- 修改字段长度
ALTER TABLE hs_disease ALTER COLUMN dict_name TYPE varchar(100);

-- 重新创建视图
CREATE VIEW view_user_permission_bsiness AS SELECT DISTINCT sbt.id,
    sbt.parent_id,
    sbt.name,
    sbt.item,
    sbt.type,
    sbt.source_item,
    sbt.version,
    sbt.code,
    srp.permission_id,
    sur.user_id,
    srp.target_app
   FROM ((((sys_business_type sbt
     LEFT JOIN sys_business_type_permission sbtp ON (((sbt.id)::text = (sbtp.business_id)::text)))
     LEFT JOIN sys_role_permission srp ON ((((srp.id)::text = (sbtp.target_id)::text) AND ((sbtp.target_type)::text = 'roleApp'::text))))
     LEFT JOIN sys_role sr ON (((sr.id)::text = (srp.role_id)::text)))
     LEFT JOIN sys_user_role sur ON (((sur.role_id)::text = (sr.id)::text)));


CREATE VIEW view_patient_statistics AS SELECT hp.id,
    hp.person_name,
        CASE
            WHEN (hp.birth_date IS NULL) THEN (hi.age)::numeric
            ELSE EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, hp.birth_date))
        END AS age,
    hp.gender,
        CASE
            WHEN ((hi.height IS NOT NULL) AND (hi.weight IS NOT NULL)) THEN round((((hi.weight / (hi.height)::numeric) / (hi.height)::numeric) * (10000)::numeric), 1)
            ELSE (0)::numeric
        END AS bmi,
    hi.org_id,
    sd.org_code,
    sd.area_code,
    hd.dict_name AS disease
   FROM (((hs_person hp
     LEFT JOIN hs_inpatient hi ON (((hp.id)::text = (hi.person_id)::text)))
     LEFT JOIN hs_disease hd ON ((((hd.patient_id)::text = (hi.id)::text) AND (hd.type = 0))))
     LEFT JOIN sys_depart sd ON (((sd.id)::text = (hi.org_id)::text)))
  WHERE (hi.org_id IS NOT NULL);


CREATE VIEW parent_business_view AS SELECT sbt.id,
    sbt.create_by,
    sbt.create_time,
    sbt.update_by,
    sbt.update_time,
    sbt.org_id,
    sbt.name,
    sbt.item,
    sbt.source_item,
    sbt.url,
    sbt.scenario,
    sbt.classify,
    sbt.status,
    sbt.version,
    sbt.parent_id,
    sbt.leaf,
    sbt.type,
    sbt.code,
    pbt.item AS parentitem,
    pbt.name AS parentname,
    rbt.item AS rootitem,
    pbt.name AS rootname
   FROM ((sys_business_type sbt
     LEFT JOIN sys_business_type pbt ON (((sbt.parent_id)::text = (pbt.id)::text)))
     LEFT JOIN sys_business_type rbt ON (((rbt.code)::text = substr((sbt.code)::text, 0, 4))));


CREATE VIEW view_report  AS SELECT hri.id,
  hri.item,
  hri.org_id,
   CASE
    WHEN (hri.start_time IS NOT NULL) THEN to_char(date_trunc('day'::text, hri.start_time), 'YYYY-MM'::text)
    ELSE to_char(date_trunc('day'::text, hri.create_time), 'YYYY-MM'::text)
   END AS monthchar,
  pbv.parentitem,
  pbv.rootitem,
  pbv.name,
  pbv.parentname,
  pbv.rootname,
  pbv.source_item,
  pbv.type
   FROM (hs_report_task hri
     LEFT JOIN parent_business_view pbv ON (((pbv.item)::text = (hri.item)::text)))
  WHERE ((hri.status)::text = ANY (ARRAY[('FINISH'::character varying)::text, ('CONFIRM'::character varying)::text]));


CREATE VIEW view_org_count AS WITH orgcount AS (
         SELECT vps.org_id,
            count(DISTINCT vps.id) AS patientvalue,
            0 AS sleepvalue,
            0 AS trainvalue,
            0 AS assessmentvalue
           FROM view_patient_statistics vps
          GROUP BY vps.org_id
        UNION
         SELECT vr.org_id,
            0 AS patientvalue,
            count(vr.id) AS sleepvalue,
            0 AS trainvalue,
            0 AS assessmentvalue
           FROM view_report vr
          WHERE ((vr.item)::text = 'sleepStageAhi'::text)
          GROUP BY vr.org_id
        UNION
         SELECT vr.org_id,
            0 AS patientvalue,
            0 AS sleepvalue,
            0 AS trainvalue,
            count(vr.id) AS assessmentvalue
           FROM view_report vr
          WHERE ((vr.type)::text = ANY (ARRAY[('quesAnswer'::character varying)::text, ('question'::character varying)::text]))
          GROUP BY vr.org_id
        UNION
         SELECT vr.org_id,
            0 AS patientvalue,
            0 AS sleepvalue,
            count(vr.id) AS trainvalue,
            0 AS assessmentvalue
           FROM view_report vr
          WHERE ((vr.source_item)::text = 'sportRecory'::text)
          GROUP BY vr.org_id
        )
 SELECT orgcount.org_id,
    max(orgcount.patientvalue) AS patientvalue,
    max(orgcount.sleepvalue) AS sleepvalue,
    max(orgcount.trainvalue) AS trainvalue,
    max(orgcount.assessmentvalue) AS assessmentvalue
   FROM orgcount
  GROUP BY orgcount.org_id;


CREATE VIEW view_user_patient AS SELECT hi.id,
    hi.create_by,
    hi.create_time,
    hi.update_by,
    hi.update_time,
    hi.adm_date_time,
    hi.admission_date_time,
    hi.anaphylaxis,
    hi.bed_num,
    hi.bed_shownum,
    hi.charge_type,
    hi.diagnosis,
    hi.doctor_in_charge,
    hi.drink,
    hi.height,
    hi.his_dept_code,
    hi.his_dept_name,
    hi.his_id,
    hi.his_ward_code,
    hi.his_ward_name,
    hi.inp_no,
    hi.leave_date_time,
    hi.nurse_in_charge,
    hi.nursing_level_code,
    hi.order_no,
    hi.org_id,
    hi.other_diagnosis,
    hi.patient_condition,
    hi.person_id,
    hi.prepayments,
    hi.smoke,
    hi.source_type,
    hi.status,
    hi.total_charges,
    hi.total_costs,
    hi.visit_id,
    hi.weight,
    hi.drink_age,
    hi.drink_day,
    hi.drink_quit,
    hi.smoke_age,
    hi.smoke_day,
    hi.smoke_quit,
    hi.age,
    hi.bmi,
    hi.stage,
    hi.expire_level,
    hdp.user_id
   FROM (hs_inpatient hi
     LEFT JOIN hs_doc_pat hdp ON (((hi.id)::text = (hdp.target_id)::text)))
  WHERE ((hdp.status = 0) AND ((hdp.target_type)::text = 'patient'::text));


CREATE VIEW view_patient_user AS SELECT hi.id,
    hi.create_by,
    hi.create_time,
    hi.update_by,
    hi.update_time,
    hi.adm_date_time,
    hi.admission_date_time,
    hi.anaphylaxis,
    hi.bed_num,
    hi.bed_shownum,
    hi.charge_type,
    hi.diagnosis,
    hi.doctor_in_charge,
    hi.drink,
    hi.height,
    hi.his_dept_code,
    hi.his_dept_name,
    hi.his_id,
    hi.his_ward_code,
    hi.his_ward_name,
    hi.inp_no,
    hi.leave_date_time,
    hi.nurse_in_charge,
    hi.nursing_level_code,
    hi.order_no,
    hi.org_id,
    hi.other_diagnosis,
    hi.patient_condition,
    hi.person_id,
    hi.prepayments,
    hi.smoke,
    hi.source_type,
    hi.status,
    hi.total_charges,
    hi.total_costs,
    hi.visit_id,
    hi.weight,
    hi.drink_age,
    hi.drink_day,
    hi.drink_quit,
    hi.smoke_age,
    hi.smoke_day,
    hi.smoke_quit,
    hi.age,
    hi.bmi,
    hi.stage,
    hi.expire_level,
    hdp.user_id
   FROM (hs_inpatient hi
     LEFT JOIN hs_doc_pat hdp ON ((((hi.id)::text = (hdp.target_id)::text) AND (hdp.status = 0) AND ((hdp.target_type)::text = 'patient'::text))));


CREATE VIEW view_user_medical AS SELECT hmc.name,
    hms.org_id,
    hmc.org_id AS admin_org,
    hms.item,
    orgnames(hms.org_id) AS org_name
   FROM (hs_medical_subordinate hms
     LEFT JOIN hs_medical_consortium hmc ON (((hmc.id)::text = (hms.consortium_id)::text)));


CREATE VIEW view_super_depart AS SELECT scd.id,
    scd.parent_id,
    scd.depart_name,
    scd.depart_name_en,
    scd.depart_name_abbr,
    scd.depart_order,
    scd.description,
    scd.org_category,
    scd.org_type,
    scd.org_code,
    scd.mobile,
    scd.fax,
    scd.address,
    scd.memo,
    scd.status,
    scd.del_flag,
    scd.qywx_identifier,
    scd.create_by,
    scd.create_time,
    scd.update_by,
    scd.update_time,
    scd.area_code,
    scd.expires,
    scd.expires_day,
    scd.code,
    scd.longitude,
    scd.latitude,
    scd.alias_name,
    spd.id AS superid,
    spd.area_code AS super_area_code
   FROM (sys_depart scd
     LEFT JOIN sys_depart spd ON (((scd.org_code)::text ~~ concat(spd.org_code, '%'))));


CREATE VIEW view_recipel_item AS SELECT hri.id,
    hri.item,
    hri.org_id,
        CASE
            WHEN (hri.start_time IS NOT NULL) THEN to_char(date_trunc('day'::text, hri.start_time), 'YYYY-MM'::text)
            ELSE to_char(date_trunc('day'::text, hri.create_time), 'YYYY-MM'::text)
        END AS monthchar,
    pbv.parentitem,
    pbv.rootitem,
    pbv.name,
    pbv.parentname,
    pbv.rootname,
    pbv.source_item,
    pbv.type
   FROM (hs_recipel_item hri
     LEFT JOIN parent_business_view pbv ON (((pbv.item)::text = (hri.item)::text)))
  WHERE ((hri.status)::text = 'finish'::text);


CREATE VIEW view_user_business AS SELECT a.business_id,
    a.user_id,
    sbt.id,
    sbt.create_by,
    sbt.create_time,
    sbt.update_by,
    sbt.update_time,
    sbt.org_id,
    sbt.name,
    sbt.item,
    sbt.type,
    sbt.source_item,
    sbt.url,
    sbt.scenario,
    sbt.status,
    sbt.classify,
    sbt.version,
    sbt.parent_id,
    sbt.code,
    sbt.leaf
   FROM (( SELECT btp.id,
            btp.create_by,
            btp.create_time,
            btp.update_by,
            btp.update_time,
            btp.sys_org_code,
            btp.business_id,
            btp.target_id,
            btp.target_type,
            sur.user_id
           FROM ((sys_business_type_permission btp
             LEFT JOIN sys_role sr ON (((btp.target_id)::text = (sr.id)::text)))
             LEFT JOIN sys_user_role sur ON (((sr.id)::text = (sur.role_id)::text)))
          WHERE ((btp.target_type)::text = 'role'::text)
        UNION
         SELECT btp.id,
            btp.create_by,
            btp.create_time,
            btp.update_by,
            btp.update_time,
            btp.sys_org_code,
            btp.business_id,
            btp.target_id,
            btp.target_type,
            sud.user_id
           FROM ((sys_business_type_permission btp
             LEFT JOIN sys_depart sd ON (((btp.target_id)::text = (sd.id)::text)))
             LEFT JOIN sys_user_depart sud ON (((sd.id)::text = (sud.dep_id)::text)))
          WHERE ((btp.target_type)::text = 'dept'::text)) a
     LEFT JOIN sys_business_type sbt ON (((a.business_id)::text = (sbt.id)::text)));
-- 结束事务
end;

```
