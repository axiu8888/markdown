# PostgreSQL 操作


### 查询机构和子机构

```
-- 查询机构和子机构
WITH 
sdp AS ( SELECT * FROM sys_depart WHERE id = '520f71f716ef43dda38d9bc8b9295ca1' ORDER BY org_code ASC )
-- sdp AS ( SELECT * FROM sys_depart WHERE id = '520f71f716ef43dda38d9bc8b9295ca1' ORDER BY org_code ASC )
-- sdp AS ( SELECT * FROM sys_depart WHERE id = 'd4394b634a924b2a820a15f50dbdd175' ORDER BY org_code ASC )
SELECT sd.*
FROM sys_depart AS sd
	LEFT JOIN sdp ON 1=1
WHERE sdp.org_code IS NOT NULL 
-- 	AND sd.org_code LIKE concat(sdp.org_code, '%')
	AND ( sd.id = sdp.id OR sd.parent_id = sdp.id )-- OR sd.org_code LIKE concat(sdp.org_code, '%'))
-- 	AND sd.org_category IN( 'hospital', 'distributor' )
ORDER BY sd.org_code ASC
```


### 统计——BMI统计

```
WITH 
-- sdr AS (SELECT * FROM sys_depart WHERE id = '520f71f716ef43dda38d9bc8b9295ca1')  
sdp AS (
	SELECT sd.id AS id, sd.org_code AS org_code FROM sys_depart AS sd WHERE sd.id = '520f71f716ef43dda38d9bc8b9295ca1' 
	UNION ALL
	SELECT hso.id AS id, hso.org_code AS org_code FROM hs_statistics_org AS hso WHERE hso.id = '520f71f716ef43dda38d9bc8b9295ca1'
)
, sdr AS ( SELECT * FROM sdp LIMIT 1 )
, sd AS ( 
	(
		SELECT DISTINCT(sd.id) AS id 
		FROM sys_depart AS sd 
		LEFT JOIN sdr ON 1=1 
		WHERE sdr.id IS NOT NULL AND sd.del_flag = 0 AND sd.org_code LIKE concat(sdr.org_code, '%')
	) 
	UNION ALL
	(
		SELECT DISTINCT(hso.id) AS id
		FROM hs_statistics_org AS hso
			LEFT JOIN sdr ON 1=1
		WHERE sdr.id IS NOT NULL AND (hso.parent_id = sdr.id OR hso.id = sdr.id)
	)
) 
, pbmi AS (
	SELECT MAX(hi.bmi) AS bmi
	FROM hs_inpatient hi 
		LEFT JOIN sd ON 1=1 
	WHERE sd.id IS NOT NULL AND hi.org_id IN( sd.id )
	GROUP BY hi.person_id
),
bmi_list AS ( 
 SELECT
	CASE 
	 WHEN bmi < 18.5 THEN 'underweight' 
	 WHEN bmi >= 18.5 AND bmi < 24 THEN 'normal' 
	 WHEN bmi >= 24 AND bmi < 28 THEN 'overweight' 
	 WHEN bmi >= 28 AND bmi < 35 THEN 'obesity' 
	 WHEN bmi >= 35 THEN 'severe_obesity' 
	 ELSE 'other' 
	END AS bmi_value, COUNT(*) val  
 FROM pbmi  
 GROUP BY 
	CASE 
	 WHEN bmi < 18.5 THEN 'underweight' 
	 WHEN bmi >= 18.5 AND bmi < 24 THEN 'normal' 
	 WHEN bmi >= 24 AND bmi < 28 THEN 'overweight' 
	 WHEN bmi >= 28 AND bmi < 35 THEN 'obesity' 
	 WHEN bmi >= 35 THEN 'severe_obesity' 
	 ELSE 'other' 
	END 
)
, bmi_new AS (
	SELECT 1 AS a, 
	 MAX(CASE WHEN bmi_value = 'underweight' THEN val END) AS underweight, 
	 MAX(CASE WHEN bmi_value = 'normal' THEN val END) AS normal, 
	 MAX(CASE WHEN bmi_value = 'overweight' THEN val END) AS overweight, 
	 MAX(CASE WHEN bmi_value = 'obesity' THEN val END) AS obesity, 
	 MAX(CASE WHEN bmi_value = 'severe_obesity' THEN val END) AS severe_obesity 
	FROM bmi_list
	GROUP BY a
)
, bmi_group AS (
	(
		SELECT bn.underweight AS underweight, bn.normal AS normal, bn.overweight AS overweight, bn.obesity AS obesity, bn.severe_obesity AS severe_obesity 
		FROM bmi_new AS bn
	)
	UNION ALL
	(
		SELECT hsi.bmi_underweight AS underweight, hsi.bmi_normal AS normal, hsi.bmi_overweight AS overweight, hsi.bmi_obesity AS obesity, hsi.bmi_severe_obesity AS severe_obesity
		FROM hs_statistics_inpatient AS hsi 
			LEFT JOIN sd ON 1=1
		WHERE sd.id IS NOT NULL AND (hsi.znsx_org_id IN(sd.id) OR hsi.support_org_id IN(sd.id))
		GROUP BY hsi.id
	)
)

SELECT "sum"(bg.underweight) AS underweight, "sum"(bg.normal) AS normal, "sum"(bg.overweight) AS overweight, "sum"(bg.obesity) AS obesity, "sum"(bg.severe_obesity) AS severe_obesity
FROM bmi_group AS bg

```


### 统计——根据item分类，统计报告数量

```


WITH
-- sdr AS (SELECT * FROM sys_depart WHERE id = '520f71f716ef43dda38d9bc8b9295ca1')  
sdp AS (
	SELECT sd.id AS id, sd.org_code AS org_code FROM sys_depart AS sd WHERE sd.id = '520f71f716ef43dda38d9bc8b9295ca1' 
	UNION ALL
	SELECT hso.id AS id, hso.org_code AS org_code FROM hs_statistics_org AS hso WHERE hso.id = '520f71f716ef43dda38d9bc8b9295ca1'
)
, sdr AS ( SELECT * FROM sdp LIMIT 1 )
, sd AS ( 
	(
		SELECT DISTINCT(sd.id) AS id 
		FROM sys_depart AS sd 
		LEFT JOIN sdr ON 1=1 
		WHERE sdr.id IS NOT NULL AND sd.del_flag = 0 AND sd.org_code LIKE concat(sdr.org_code, '%')
	) 
	UNION ALL
	(
		SELECT DISTINCT(hso.id) AS id
		FROM hs_statistics_org AS hso
			LEFT JOIN sdr ON 1=1
		WHERE sdr.id IS NOT NULL AND (hso.parent_id = sdr.id OR hso.id = sdr.id)
	)
) 
, hrt as ( 
	SELECT sbt.name, hrt.id AS id, hrt.item AS item
	FROM hs_report_task AS hrt 
		LEFT JOIN sys_business_type AS sbt ON sbt.item = hrt.item 
		LEFT JOIN hs_inpatient AS hi ON hi.id = hrt.patient_id 
		LEFT JOIN sd ON 1=1
	WHERE sd.id IS NOT NULL 
		AND hi.org_id IN( sd.id ) 
		AND hrt.status IN('FINISH', 'CONFIRM') 
)
, report_sum AS (
	(
		SELECT MAX(DISTINCT(hrt.name)) AS name, hrt.item AS key, count(hrt.id) AS value
		FROM hrt 
		WHERE 1=1
			AND hrt.item IN ('smwt')
		GROUP BY hrt.item 
	)
	UNION ALL
	(
		SELECT MAX(sbt.name) AS name, hsr.type AS key, "sum"(hsr.count) AS value
		FROM hs_statistics_report AS hsr
			LEFT JOIN sd ON 1=1
			LEFT JOIN sys_business_type AS sbt ON sbt.item = hsr.type
		WHERE sd.id IS NOT NULL
			AND (hsr.support_org_id IN( sd.id ) OR hsr.znsx_org_id IN( sd.id ))
			AND hsr.type IN ('smwt')
		GROUP BY hsr.type
	)
)

SELECT MAX(rs.name) AS name, rs.key AS key, "sum"(rs.value) AS value
FROM report_sum AS rs
GROUP BY key
ORDER BY value DESC


```


### 统计——患者统计

```

WITH 
sdr AS (SELECT * FROM sys_depart WHERE id = '520f71f716ef43dda38d9bc8b9295ca1') 
, sd AS (
	(
		SELECT DISTINCT(sd.id) AS id 
		FROM sys_depart AS sd 
		LEFT JOIN sdr ON 1=1 
		WHERE sdr.id IS NOT NULL AND sd.del_flag = 0 AND sd.org_code LIKE concat(sdr.org_code, '%')
	) 
	UNION ALL
	(
		SELECT DISTINCT(hso.id) AS id
		FROM hs_statistics_org AS hso
			LEFT JOIN sdr ON 1=1
		WHERE sdr.id IS NOT NULL AND (hso.parent_id = sdr.id OR hso.id = sdr.id)
	)
 )
, hp AS ( 
	SELECT DISTINCT(hi.id) AS id
	FROM hs_inpatient hi 
	LEFT JOIN sd ON 1=1
	WHERE hi.org_id IN( sd.id )
)
, t AS (
	SELECT '_0_0_' AS id, COUNT(DISTINCT(hp.id)) AS count FROM hp
	UNION ALL
	SELECT hsi.id, hsi.count AS count
	FROM hs_statistics_inpatient AS hsi 
		LEFT JOIN sd ON 1=1
	WHERE hsi.support_org_id IN(sd.id) OR hsi.znsx_org_id IN(sd.id)
	GROUP BY hsi.id
)

SELECT "sum"(t.count) AS total
FROM t

```


### 统计——年龄分布

```

WITH 
sdr AS (SELECT * FROM sys_depart WHERE id = '520f71f716ef43dda38d9bc8b9295ca1') 
, sd AS (
	SELECT DISTINCT(sd.*)
	FROM sys_depart AS sd
		LEFT JOIN sdr ON 1=1
	WHERE sdr.id IS NOT NULL AND sd.del_flag = 0 AND sd.org_code LIKE concat(sdr.org_code, '%')
)
, person_age AS (
	SELECT org_id, COALESCE(date_part('year', age(CURRENT_DATE, hp.birth_date)), hp.age) age 
	FROM hs_person hp 
		LEFT JOIN hs_inpatient hi on hi.person_id = hp.id 
		LEFT JOIN sd ON 1=1
	WHERE sd.id IS NOT NULL AND hi.org_id IN( sd.id ) 
)
, age_list as (
SELECT
	CASE 
	 WHEN age <= 6 THEN 'age06' 
	 WHEN age<=17 THEN 'age717' 
	 WHEN age<=40 THEN 'age1840' 
	 WHEN age <=65 THEN 'age4165' 
	 WHEN age>=66 THEN 'age66up' 
	 ELSE 'other'
	END AS age, count(*) val
FROM person_age 
GROUP BY 
	CASE 
		when age <= 6 THEN 'age06' 
		when age<=17 THEN 'age717' 
		when age<=40 THEN 'age1840' 
		when age <=65 THEN 'age4165' 
		when age>=66 THEN 'age66up' 
		ELSE 'other'
	END
)
, age_group AS (
	(
		SELECT 
			max(CASE WHEN age='age06' THEN val END) as age06,
			max(CASE WHEN age = 'age717' THEN val END) AS age717,
			max(CASE WHEN age = 'age1840' THEN val END) AS age1840,
			max(CASE WHEN age = 'age4165' THEN val END) AS age4165,
			max(CASE WHEN age = 'age66up' THEN val END) AS age66up,
			max(CASE WHEN age = 'other' THEN val END) AS other
		FROM age_list 
	)
	UNION ALL
	(
		SELECT hsi.age_0_6 AS age06, hsi.age_7_17 AS age717, hsi.age_18_40 AS age1840, hsi.age_41_65 AS age4165, hsi.age_66_ AS age66up, 0 AS other
		FROM hs_statistics_inpatient AS hsi
			LEFT JOIN sd ON 1=1
		WHERE sd.id IS NOT NULL AND ( hsi.support_org_id IN(sd.id) OR hsi.znsx_org_id IN(sd.id) )
		GROUP BY hsi.id
	)
)

SELECT "sum"(ag.age06) AS age06, "sum"(ag.age717) AS age717, "sum"(ag.age1840) AS age1840, "sum"(ag.age4165) AS age4165, "sum"(ag.age66up) AS age66up
FROM age_group AS ag

```


### 统计——性别分布

```

WITH
sdr AS (SELECT * FROM sys_depart WHERE id = '520f71f716ef43dda38d9bc8b9295ca1') 
, sd AS (
	(
		SELECT DISTINCT(sd.id) AS id 
		FROM sys_depart AS sd 
		LEFT JOIN sdr ON 1=1 
		WHERE sdr.id IS NOT NULL AND sd.del_flag = 0 AND sd.org_code LIKE concat(sdr.org_code, '%')
	) 
	UNION ALL
	(
		SELECT DISTINCT(hso.id) AS id
		FROM hs_statistics_org AS hso
			LEFT JOIN sdr ON 1=1
		WHERE sdr.id IS NOT NULL AND hso.parent_id = sdr.id
	)
)
, gender_table AS (
	SELECT gender, count(DISTINCT hp.id) val 
	FROM hs_person AS hp
		LEFT JOIN hs_inpatient hi ON hi.person_id = hp.id  
		LEFT JOIN sd ON 1=1
	WHERE sd.id IS NOT NULL 
		AND hi.org_id IN( sd.id )
		AND gender IS NOT NULL  
	GROUP BY gender
)
, gender_sum AS (
	(
		SELECT
			sum(case gender WHEN '男' then val else 0 end ) male, 
			sum(case gender WHEN '女' then val else 0 end ) female 
		FROM gender_table
	)
	UNION ALL
	(
		SELECT hsi.gender_male AS male, hsi.gender_female AS female
		FROM hs_statistics_inpatient AS hsi
			LEFT JOIN sd ON 1=1
		WHERE sd.id IS NOT NULL AND ( hsi.support_org_id IN(sd.id) OR hsi.znsx_org_id IN(sd.id) )
		GROUP BY hsi.id
	)
)

SELECT "sum"(gs.male) AS male, "sum"(gs.female) AS female
FROM gender_sum AS gs

```


### 统计——统计每天的报告数

```
-- 2、统计每日的报告数

WITH 
sbtp AS (SELECT * FROM sys_business_type WHERE item IN( 'cfa' ) )
-- sbtp AS ( SELECT * FROM sys_business_type WHERE type IN( 'quesAnswer', 'question' ) )
, sbt AS (
	SELECT sbt1.* 
	FROM sys_business_type AS sbt1
		LEFT JOIN sbtp ON 1=1
	WHERE sbtp.code IS NOT NULL AND sbt1.code LIKE concat(sbtp.code, '%') 
	ORDER BY sbt1.code ASC 
)

SELECT MAX(hrt.org_id) AS org_id, MAX(sd.depart_name) AS org_name, MAX(sd.org_code) AS org_code, MAX(hrt.report_date) AS report_date, COUNT(hrt.id) AS count
FROM hs_report_task AS hrt
	LEFT JOIN sys_depart AS sd ON sd.id = hrt.org_id
	LEFT JOIN sbt ON 1=1
WHERE 1=1
	AND sbt.item IS NOT NULL
	AND TO_DATE(hrt.report_date, 'YYYY-MM-DD') >= date('2020-01-01')
	AND hrt.status IN( 'FINISH', 'CONFIRM' )
	AND hrt.item IN (sbt.item)
GROUP BY hrt.org_id, hrt.report_date
ORDER BY hrt.report_date DESC, hrt.org_id DESC

```

