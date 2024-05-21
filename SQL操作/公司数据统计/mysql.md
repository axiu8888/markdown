# MySQL 操作


### 查询医联体机构

```

SELECT ho.*
FROM HS_ORG AS ho
WHERE 1=1
	AND ho.auto_code LIKE CONCAT((SELECT auto_code FROM HS_ORG WHERE zid = 'gSzICa4AED'), '%')
	AND ho.org_type IN ( 'hospital', 'distributor' )
ORDER BY ho.auto_code ASC

```


### 统计——总数、年龄分布、BMI分布、性别分布

```

-- (hi.weight / (hi.height / 100.0) / (hi.height / 100.0)) AS bmi


-- 统计总数
SELECT COUNT(DISTINCT t.zid) AS total
FROM (
	SELECT hp.zid, (hi.weight / (hi.height / 100.0) / (hi.height / 100.0)) AS bmi, TIMESTAMPDIFF(YEAR, hp.birth_date, CURDATE()) AS age, hp.gender
	FROM HS_INPATIENT AS hi
		LEFT JOIN HS_PERSON AS hp ON hp.zid = hi.person_zid
		LEFT JOIN (SELECT * FROM HS_ORG WHERE auto_code LIKE CONCAT((SELECT auto_code FROM HS_ORG WHERE zid IN( '120' )), '%')) AS ho ON ho.zid = hi.org_zid
	WHERE 1=1
		AND ho.zid IS NOT NULL
) AS t



-- 统计年龄
SELECT 
	COUNT(case 1 WHEN t.age <= 6 THEN 'age_0_6' ELSE NULL end) AS age_0_6,
	COUNT(case 1 WHEN t.age >= 7 AND t.age <= 17 THEN 'age_7_17' ELSE NULL end) AS age_7_17,
	COUNT(case 1 WHEN t.age >= 18 AND t.age <= 40 THEN 'age_18_40' ELSE NULL end) AS age_18_40,
	COUNT(case 1 WHEN t.age >= 41 AND t.age <= 65 THEN 'age_41_65' ELSE NULL end) AS age_41_65,
	COUNT(case 1 WHEN t.age >= 66 THEN 'age_66_' ELSE NULL end) AS age_66_
FROM (
	SELECT ho.org_name, hp.person_name, (hi.weight / (hi.height / 100.0) / (hi.height / 100.0)) AS bmi, TIMESTAMPDIFF(YEAR, hp.birth_date, CURDATE()) AS age, hi.*
	FROM HS_INPATIENT AS hi
		LEFT JOIN HS_PERSON AS hp ON hp.zid = hi.person_zid
		LEFT JOIN (SELECT * FROM HS_ORG WHERE auto_code LIKE CONCAT((SELECT auto_code FROM HS_ORG WHERE zid IN( '120' )), '%')) AS ho ON ho.zid = hi.org_zid
	WHERE 1=1
		AND ho.zid IS NOT NULL
) AS t



-- 统计bmi
SELECT 
	COUNT(case 1 WHEN t.bmi < 18.5 THEN 'underweight' ELSE NULL end) AS underweight,
	COUNT(case 1 WHEN t.bmi >= 18.5 AND t.bmi < 24 THEN 'normal' ELSE NULL end) AS normal,
	COUNT(case 1 WHEN t.bmi >= 24 AND t.bmi < 28 THEN 'overweight' ELSE NULL end) AS overweight,
	COUNT(case 1 WHEN t.bmi >= 28 AND t.bmi < 35 THEN 'obesity' ELSE NULL end) AS obesity,
	COUNT(case 1 WHEN t.bmi >= 35 THEN 'severe_obesity' ELSE NULL end) AS severe_obesity
FROM (
	SELECT hp.zid, (hi.weight / (hi.height / 100.0) / (hi.height / 100.0)) AS bmi, TIMESTAMPDIFF(YEAR, hp.birth_date, CURDATE()) AS age, hp.gender
	FROM HS_INPATIENT AS hi
		LEFT JOIN HS_PERSON AS hp ON hp.zid = hi.person_zid
		LEFT JOIN (SELECT * FROM HS_ORG WHERE auto_code LIKE CONCAT((SELECT auto_code FROM HS_ORG WHERE zid IN( '120' )), '%')) AS ho ON ho.zid = hi.org_zid
	WHERE 1=1
		AND ho.zid IS NOT NULL
) AS t



-- 统计性别分布
SELECT 
	COUNT(case 1 WHEN t.gender = 0 THEN 'male' ELSE NULL end) AS male,
	COUNT(case 1 WHEN t.gender = 1 THEN 'female' ELSE NULL end) AS female
FROM (
	SELECT hp.zid, (hi.weight / (hi.height / 100.0) / (hi.height / 100.0)) AS bmi, TIMESTAMPDIFF(YEAR, hp.birth_date, CURDATE()) AS age, hp.gender
	FROM HS_INPATIENT AS hi
		LEFT JOIN HS_PERSON AS hp ON hp.zid = hi.person_zid
		LEFT JOIN (SELECT * FROM HS_ORG WHERE auto_code LIKE CONCAT((SELECT auto_code FROM HS_ORG WHERE zid IN( '120' )), '%')) AS ho ON ho.zid = hi.org_zid
	WHERE 1=1
		AND ho.zid IS NOT NULL
) AS t



```


### 统计——每日报告(新版&旧版)

```

-- 统计新版的报告

SELECT COUNT(r.id) as count, r.report_date
FROM (
	SELECT hrt.zid AS id, hrt.report_date
	FROM HS_REPORT_TASK AS hrt
		LEFT JOIN (SELECT * FROM HS_ORG WHERE auto_code LIKE CONCAT((SELECT auto_code FROM HS_ORG WHERE zid = '120'), '%')) AS ho ON ho.zid = hrt.org_zid
	WHERE 1=1
		AND hrt.org_zid IS NOT NULL
		AND ho.org_name IS NOT NULL
		AND hrt.`status` IN ('FINISH', 'CONFIRM')
		AND hrt.type IN( 'smwt', 'smst' )
	ORDER BY hrt.create_time DESC
	) AS r

GROUP BY r.report_date
ORDER BY r.report_date DESC


-- 统计旧版的报告

SELECT COUNT(r.id) as count, r.report_date
FROM (
	SELECT hrc.zid AS id, hrc.report_date
	FROM HS_REPORT_CHECK AS hrc
		LEFT JOIN (SELECT * FROM HS_ORG WHERE auto_code LIKE CONCAT((SELECT auto_code FROM HS_ORG WHERE zid = '120'), '%')) AS ho ON ho.zid = hrc.org_zid
	WHERE 1=1
		AND hrc.org_zid IS NOT NULL
		AND ho.org_name IS NOT NULL
		AND hrc.report_status = 1
		AND hrc.report_type IN ('SMWT', 'SMST')
	ORDER BY hrc.create_datetime DESC
	) AS r
GROUP BY r.report_date
ORDER BY r.report_date DESC

```


### 查询——机构和子机构下的报告

```

SELECT COUNT(DISTINCT r.id) AS count, r.report_date
FROM (
	(
	SELECT hrt.zid AS id, hrt.report_date, hrt.type AS type
	FROM HS_REPORT_TASK AS hrt
		LEFT JOIN (SELECT * FROM HS_ORG WHERE auto_code LIKE CONCAT((SELECT auto_code FROM HS_ORG WHERE zid = '120'), '%')) AS ho ON ho.zid = hrt.org_zid
	WHERE 1=1
		AND hrt.org_zid IS NOT NULL
		AND ho.org_name IS NOT NULL
		AND hrt.`status` IN ('FINISH', 'CONFIRM')
	ORDER BY hrt.create_time DESC
	)

	UNION ALL

	(
	SELECT hrc.zid AS id, hrc.report_date, hrc.report_type AS type
	FROM HS_REPORT_CHECK AS hrc
		LEFT JOIN (SELECT * FROM HS_ORG WHERE auto_code LIKE CONCAT((SELECT auto_code FROM HS_ORG WHERE zid = '120'), '%')) AS ho ON ho.zid = hrc.org_zid
	WHERE 1=1
		AND hrc.org_zid IS NOT NULL
		AND ho.org_name IS NOT NULL
		AND hrc.report_status = 1
	ORDER BY hrc.create_datetime DESC
	)
) AS r

WHERE 1=1
	AND r.type IN( 'smwt', 'smst', 'SMWT', 'SMST' )
-- 	AND STR_TO_DATE(r.report_date, '%Y-%m-%d') >= '2019-01-01'
-- 	AND STR_TO_DATE(r.report_date, '%Y-%m-%d') <= '2024-05-20'

GROUP BY r.report_date

```
