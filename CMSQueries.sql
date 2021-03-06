SELECT COUNT(*) 
FROM NPIGEODATA 

/***********************************************/

DELETE FROM CMSMEDICAREDATA WHERE NPI IS NULL;

/*DATA CLEANUP*/

SELECT COUNT(*) FROM CMSMEDICAREDATA



DROP TABLE CMSMEDICARENEW;
CREATE TABLE CMSMEDICARENEW AS 
SELECT CMSMEDICAREDATA.NPI, CMSMEDICAREDATA.NPPES_PROVIDER_LAST_ORG_NAME, CMSMEDICAREDATA.NPPES_PROVIDER_FIRST_NAME, CMSMEDICAREDATA.NPPES_PROVIDER_MI, 
CMSMEDICAREDATA.NPPES_CREDENTIALS, CMSMEDICAREDATA.NPPES_PROVIDER_GENDER, CMSMEDICAREDATA.NPPES_ENTITY_CODE, CMSMEDICAREDATA.NPPES_PROVIDER_STREET1, 
CMSMEDICAREDATA.NPPES_PROVIDER_STREET2, CMSMEDICAREDATA.NPPES_PROVIDER_CITY, CMSMEDICAREDATA.NPPES_PROVIDER_ZIP, CMSMEDICAREDATA.NPPES_PROVIDER_STATE, 
CMSMEDICAREDATA.NPPES_PROVIDER_COUNTRY, CMSMEDICAREDATA.PROVIDER_TYPE, CMSMEDICAREDATA.MEDICARE_PARTICIP_INDICATOR, CMSMEDICAREDATA.PLACE_OF_SERVICE, 
CMSMEDICAREDATA.HCPCS_CODE, CMSMEDICAREDATA.HCPCS_DESCRIPTION, CMSMEDICAREDATA.HCPCS_DRUG_INDICATOR, CMSMEDICAREDATA.LINE_SRVC_CNT, CMSMEDICAREDATA.BENE_UNIQUE_CNT, 
CMSMEDICAREDATA.BENE_DAY_SRVC_CNT, CMSMEDICAREDATA.AVERAGE_MEDICARE_ALLOWED_AMT, CMSMEDICAREDATA.STDEV_MEDICARE_ALLOWED_AMT, CMSMEDICAREDATA.AVERAGE_SUBMITTED_CHRG_AMT, 
CMSMEDICAREDATA.STDEV_SUBMITTED_CHRG_AMT, CMSMEDICAREDATA.AVERAGE_MEDICARE_PAYMENT_AMT, CMSMEDICAREDATA.STDEV_MEDICARE_PAYMENT_AMT, CMSMEDICAREDATA.ZIPCODE5, NPIGEODATA.FIPS_CO
FROM CMSMEDICAREDATA, NPIGEODATA
WHERE NPIGEODATA.NPI = CMSMEDICAREDATA.NPI
AND CMSMEDICAREDATA.NPPES_PROVIDER_COUNTRY = 'US';

SELECT * FROM CMSMEDICARENEW

SELECT COUNT(*) FROM CMSMEDICARENEW


SELECT CMSMEDICARENEW.NPI, CMSMEDICARENEW.AVERAGE_SUBMITTED_CHRG_AMT,  TO_NUMBER(SUBSTR(CMSMEDICARENEW.AVERAGE_SUBMITTED_CHRG_AMT,2), '999999.99') AS TEMP_CHARGES
FROM CMSMEDICARENEW

DROP TABLE CMSMEDICAREFINAL;
CREATE TABLE CMSMEDICAREFINAL AS
SELECT CMSMEDICARENEW.NPI, CMSMEDICARENEW.NPPES_PROVIDER_LAST_ORG_NAME, CMSMEDICARENEW.NPPES_PROVIDER_FIRST_NAME, CMSMEDICARENEW.NPPES_PROVIDER_MI, 
CMSMEDICARENEW.NPPES_CREDENTIALS, CMSMEDICARENEW.NPPES_PROVIDER_GENDER, CMSMEDICARENEW.NPPES_ENTITY_CODE, CMSMEDICARENEW.NPPES_PROVIDER_STREET1, 
CMSMEDICARENEW.NPPES_PROVIDER_STREET2, CMSMEDICARENEW.NPPES_PROVIDER_CITY, CMSMEDICARENEW.NPPES_PROVIDER_ZIP, CMSMEDICARENEW.NPPES_PROVIDER_STATE, 
CMSMEDICARENEW.NPPES_PROVIDER_COUNTRY, CMSMEDICARENEW.PROVIDER_TYPE, CMSMEDICARENEW.MEDICARE_PARTICIP_INDICATOR, CMSMEDICARENEW.PLACE_OF_SERVICE, 
CMSMEDICARENEW.HCPCS_CODE, CMSMEDICARENEW.HCPCS_DESCRIPTION, CMSMEDICARENEW.HCPCS_DRUG_INDICATOR, CMSMEDICARENEW.LINE_SRVC_CNT, CMSMEDICARENEW.BENE_UNIQUE_CNT, 
CMSMEDICARENEW.BENE_DAY_SRVC_CNT, CMSMEDICARENEW.AVERAGE_MEDICARE_ALLOWED_AMT, CMSMEDICARENEW.STDEV_MEDICARE_ALLOWED_AMT, CMSMEDICARENEW.AVERAGE_SUBMITTED_CHRG_AMT, 
CMSMEDICARENEW.STDEV_SUBMITTED_CHRG_AMT, CMSMEDICARENEW.AVERAGE_MEDICARE_PAYMENT_AMT, CMSMEDICARENEW.STDEV_MEDICARE_PAYMENT_AMT, CMSMEDICARENEW.ZIPCODE5, CMSMEDICARENEW.FIPS_CO, TO_NUMBER(SUBSTR(CMSMEDICARENEW.AVERAGE_SUBMITTED_CHRG_AMT,2), '999999.99')  AVG_SUBMIT_CHARGES
FROM CMSMEDICARENEW;


SELECT COUNT(*) FROM CMSMEDICAREFINAL

SELECT * FROM CMSMEDICAREFINAL
WHERE NPI = '1871709147'


/*BOTH QUERIES MERGED - FINAL v2*/
DROP TABLE CMSMEDICAREFINAL;
CREATE TABLE CMSMEDICAREFINAL AS 
SELECT CMSMEDICAREDATA.NPI, CMSMEDICAREDATA.NPPES_PROVIDER_LAST_ORG_NAME, CMSMEDICAREDATA.NPPES_PROVIDER_FIRST_NAME, CMSMEDICAREDATA.NPPES_PROVIDER_MI, 
CMSMEDICAREDATA.NPPES_CREDENTIALS, CMSMEDICAREDATA.NPPES_PROVIDER_GENDER, CMSMEDICAREDATA.NPPES_ENTITY_CODE, CMSMEDICAREDATA.NPPES_PROVIDER_STREET1, 
CMSMEDICAREDATA.NPPES_PROVIDER_STREET2, CMSMEDICAREDATA.NPPES_PROVIDER_CITY, CMSMEDICAREDATA.NPPES_PROVIDER_ZIP, CMSMEDICAREDATA.NPPES_PROVIDER_STATE, 
CMSMEDICAREDATA.NPPES_PROVIDER_COUNTRY, CMSMEDICAREDATA.PROVIDER_TYPE, CMSMEDICAREDATA.MEDICARE_PARTICIP_INDICATOR, CMSMEDICAREDATA.PLACE_OF_SERVICE, 
CMSMEDICAREDATA.HCPCS_CODE, CMSMEDICAREDATA.HCPCS_DESCRIPTION, CMSMEDICAREDATA.HCPCS_DRUG_INDICATOR, CMSMEDICAREDATA.LINE_SRVC_CNT, CMSMEDICAREDATA.BENE_UNIQUE_CNT, 
CMSMEDICAREDATA.BENE_DAY_SRVC_CNT, CMSMEDICAREDATA.AVERAGE_MEDICARE_ALLOWED_AMT, CMSMEDICAREDATA.STDEV_MEDICARE_ALLOWED_AMT, TO_NUMBER(SUBSTR(CMSMEDICAREDATA.AVERAGE_SUBMITTED_CHRG_AMT,2), '999999.99')  AVG_SUBMIT_CHARGES, 
CMSMEDICAREDATA.STDEV_SUBMITTED_CHRG_AMT, CMSMEDICAREDATA.AVERAGE_MEDICARE_PAYMENT_AMT, CMSMEDICAREDATA.STDEV_MEDICARE_PAYMENT_AMT, CMSMEDICAREDATA.ZIPCODE5, NPIGEODATA.FIPS_CO
FROM CMSMEDICAREDATA, NPIGEODATA
WHERE NPIGEODATA.NPI = CMSMEDICAREDATA.NPI
AND CMSMEDICAREDATA.NPPES_PROVIDER_COUNTRY = 'US';


/*DATA ANALYSIS*/

SELECT HCPCS_CODE, HCPCS_DESCRIPTION, COUNT(*)
FROM CMSMEDICAREFINAL
GROUP BY HCPCS_CODE, HCPCS_DESCRIPTION
ORDER BY COUNT(*) DESC



/*FLU CHARGES*/
/*G0008	Administration of influenza virus vaccine	141667*/


DROP TABLE FLUCHARGES;
CREATE TABLE FLUCHARGES AS
SELECT NPPES_PROVIDER_STATE, FIPS_CO, MEDIAN(AVG_SUBMIT_CHARGES) AS MEDIAN_CHARGES
FROM CMSMEDICAREFINAL
WHERE HCPCS_CODE = 'G0008'
GROUP BY NPPES_PROVIDER_STATE, FIPS_CO
ORDER BY NPPES_PROVIDER_STATE ASC, FIPS_CO ASC;





SELECT * FROM FLUCHARGES

SELECT COUNT(*)
FROM FLUCHARGES

SELECT * FROM FLUCHARGES

/*REMOVE STATES THAT WILL NOT APPEAR IN THE MAP*/
DELETE FROM FLUCHARGES
WHERE NPPES_PROVIDER_STATE IN ( 'PR', 'GU', 'VI', 'MP','AS');

ALTER TABLE FLUCHARGES ADD FIPS_STATE_STRING VARCHAR(3);

/*FOR CODE WITH STATE NUMBER AS STRING*/
UPDATE FLUCHARGES SET FIPS_STATE_STRING = (SELECT DISTINCT(STATE_FIPS_CODE)
FROM FIPS_CODES_REF_STRING
WHERE FLUCHARGES.NPPES_PROVIDER_STATE = FIPS_CODES_REF_STRING.STATE_ABBREVIATION);


DELETE FROM FLUCHARGES WHERE FIPS_CO IS NULL;
DELETE FROM FLUCHARGES WHERE FIPS_STATE_STRING IS NULL;




SELECT * FROM FLUCHARGES
WHERE FIPS_STATE_STRING IS NULL

SELECT FIPS_STATE_STRING,FIPS_CO,MEDIAN_CHARGES FROM FLUCHARGES


/*DETECT OUTLIER DATA/ERRORS*/

SELECT DISTINCT(MEDIAN_CHARGES),COUNT(*)
FROM FLUCHARGES
GROUP BY MEDIAN_CHARGES
ORDER BY COUNT(*)DESC

SELECT MAX(MEDIAN_CHARGES), MIN(MEDIAN_CHARGES), MEDIAN(MEDIAN_CHARGES)  FROM FLUCHARGES

SELECT MIN(MEDIAN_CHARGES) FROM FLUCHARGES
SELECT MEDIAN(MEDIAN_CHARGES) FROM FLUCHARGES


SELECT COUNT(*) 
FROM FLUCHARGES
WHERE MEDIAN_CHARGES =0.01

/*DELETE OUTLIER VALUES*/

DELETE FROM FLUCHARGES 
WHERE MEDIAN_CHARGES = 489.71

DELETE FROM FLUCHARGES 
WHERE MEDIAN_CHARGES >= 92

DELETE FROM FLUCHARGES 
WHERE MEDIAN_CHARGES = 0.01

/*2ND EXAMPLE - BLOOD SAMPLE COLLECTION CHARGES */
36415	Insertion of needle into vein for collection of blood sample	102491

DROP TABLE BLOODSAMPLECHARGES;
CREATE TABLE BLOODSAMPLECHARGES AS
SELECT NPPES_PROVIDER_STATE, FIPS_CO, MEDIAN(AVG_SUBMIT_CHARGES) AS MEDIAN_CHARGES
FROM CMSMEDICAREFINAL
WHERE HCPCS_CODE = '36415'
GROUP BY NPPES_PROVIDER_STATE, FIPS_CO
ORDER BY NPPES_PROVIDER_STATE ASC, FIPS_CO ASC;

ALTER TABLE BLOODSAMPLECHARGES ADD FIPS_STATE NUMBER(4);

ALTER TABLE BLOODSAMPLECHARGES ADD FIPS_STATE_STRING VARCHAR(3);

SELECT COUNT(*)
FROM BLOODSAMPLECHARGES

/*REMOVE STATES THAT WILL NOT APPEAR IN THE MAP*/
DELETE FROM BLOODSAMPLECHARGES
WHERE NPPES_PROVIDER_STATE IN ('PR', 'GU', 'VI', 'MP','AS');



/*FOR CODE WITH STATE NUMBER AS NUMBER*/
UPDATE BLOODSAMPLECHARGES SET FIPS_STATE = (SELECT DISTINCT(STATE_FIPS_CODE)
FROM FIPS_CODES_REF
WHERE BLOODSAMPLECHARGES.NPPES_PROVIDER_STATE = FIPS_CODES_REF.STATE_ABBREVIATION)


/*FOR CODE WITH STATE NUMBER AS STRING*/
UPDATE BLOODSAMPLECHARGES SET FIPS_STATE_STRING = (SELECT DISTINCT(STATE_FIPS_CODE)
FROM FIPS_CODES_REF_STRING
WHERE BLOODSAMPLECHARGES.NPPES_PROVIDER_STATE = FIPS_CODES_REF_STRING.STATE_ABBREVIATION);

SELECT * FROM BLOODSAMPLECHARGES

DELETE FROM BLOODSAMPLECHARGES WHERE FIPS_CO IS NULL;
DELETE FROM BLOODSAMPLECHARGES WHERE FIPS_STATE_STRING IS NULL;


SELECT * FROM BLOODSAMPLECHARGES
WHERE FIPS_STATE_STRING IS NULL

SELECT FIPS_STATE_STRING,FIPS_CO,MEDIAN_CHARGES FROM BLOODSAMPLECHARGES


SELECT DISTINCT (NPPES_PROVIDER_STATE), FIPS_STATE
FROM BLOODSAMPLECHARGES
ORDER BY NPPES_PROVIDER_STATE

SELECT DISTINCT (NPPES_PROVIDER_STATE), FIPS_STATE_STRING
FROM BLOODSAMPLECHARGES
ORDER BY NPPES_PROVIDER_STATE



SELECT FIPS_STATE_STRING,FIPS_CO,MEDIAN_CHARGES FROM BLOODSAMPLECHARGES

/*DETECT OUTLIER DATA/ERRORS*/



SELECT DISTINCT(MEDIAN_CHARGES),COUNT(*)
FROM BLOODSAMPLECHARGES
GROUP BY MEDIAN_CHARGES
ORDER BY COUNT(*)DESC

SELECT MAX(MEDIAN_CHARGES) FROM BLOODSAMPLECHARGES
SELECT MIN(MEDIAN_CHARGES) FROM BLOODSAMPLECHARGES

SELECT MEDIAN(MEDIAN_CHARGES) FROM BLOODSAMPLECHARGES



