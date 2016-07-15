# Introduction

The purpose of this repository is to both store and demonstrate the work performed as a project submission for "The Data Incubator" Fellowship program. The goal is to visualize Medicare charges data on United States map at county level.

This page contains background information on the project, as well as, code samples and final visualizations.


# Background

The topic of healthcare costs is one that I am interested in for two major reasons: first, I work as Data Analyst in a
healthcare organization. Second, as user of healthcare services and health insurance, I am often surprised by the
increasingly high cost of medical care in the United States. Although the quality of care is undeniable, one often wonders
if the prices charged to patients are reasonable, especially when one compares the the prices charged in other countries which also have high-quality healthcare. As stated by The Commonwealth Fund:

> "Despite spending more on health care, Americans had poor health outcomes, including shorter life expectancy and greater prevalence of chronic conditions." 

The following chart illustrates this point:

![Healthcare spending per capita](http://www.commonwealthfund.org/~/media/images/publications/issue-brief/2015/oct/squires_oecd_exhibit_02.png?la=en)

(Image source: ['U.S. Health Care from a Global Perspective'] (http://www.commonwealthfund.org/publications/issue-briefs/2015/oct/us-health-care-from-a-global-perspective), The Commonwealth Fund)

In light of this, I sought to analyze existing public data related to healthcare costs and charges as a starting point for a possible project on this subject.

# Data Gathering

The [Centers for Medicare & Medicaid Services] (https://www.cms.gov/) (CMS) is the federal agency in charge of administering Medicare, Medicaid, Children’s Health Insurance Program (CHIP), and the Health Insurance Marketplace. The agency is a part of the Department of Health and Human Services (HHS).

As part of its mandate to "make our healthcare system more transparent, affordable, and accountable" , CMS has begun making several data sets public based on the data that it collects from physicians and healthcare facilities from all over the United States. Amongst the many data sets which are made available by CMS, we can find data related to [Medicare payments] (https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/index.html) in several categories, such as data on Physician charges (i.e. doctor's appointments, medical procedures, etc.), Inpatient charges (i.e.: hospital admissions), Outpatient charges (i.e.: emergency services, outpatient surgery, etc.) and Part D charges (Medicare's drug prescription program).

The focus of this analysis was on the [Physician] (https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/Physician-and-Other-Supplier.html) dataset, because it not only focused on the most common medical costs (such as doctor's visits, medical exams, etc.) but it also provided a quite large dataset (around 1.7GB and over 9 million records). The analysis was focused on the [2013] (https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/Physician-and-Other-Supplier2013.html) dataset.

CMS provides data in two formats: as a single tab delimited file (to be imported into SAS or other statistical software packages) and as Microsoft Excel files. Given that I am not a SAS User (although it is in my plans to learn in the near future), I decided to utilized the Excel files in order to import them into a local Oracle database instance.

As part of the importing process, the Excel files were first converted to the CSV format and imported into Oracle using SQL Developer's data import interface. From experience, SQL developer is able to process CSV files much better than Excel files, as importing large Excel files with SQL Developer is often prone to errors.

A screenshot of the uploaded data in SQL Developer is shown below:

![CMSDATATABLE] (https://cloud.githubusercontent.com/assets/7533177/16855634/68dc720c-49d3-11e6-870f-301bbdff7a8c.JPG)

A quick check to ensure that we uploaded all the data:

```SQL
SELECT COUNT(*) 
FROM CMSMEDICAREDATA
```
![CMSMEDICAREDATACOUNT] (https://cloud.githubusercontent.com/assets/7533177/16856161/edb670b6-49d5-11e6-9ae2-aaecba08c587.JPG)

Good! The upload process went well and we now have access to almost 9.3 million rows of Medicare Charges data. 

## Dataset explanation

The dataset contains data such as:
* Provider information such as National Provider Identification (NPI),name, street, address, ZIP code, provider's medical specialty
* Procedure information such as HCPCS codes (also known as CPT codes), procedure description, number of beneficiaries per provider that benefited from each specific procedure, and procedure financial information, such as average amounts allowed by Medicare, average charges submitted by the provider, among other fields.

A complete description of the data fields contained in the data set is available [here] (https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/Downloads/Medicare-Physician-and-Other-Supplier-PUF-Methodology.pdf).

## Mapping data to geographic locations

Once the dataset with charges information was gathered, the next step consisted of finding the means to correctly map it for visualization.

The CMS dataset contains address information, including ZIP+4 codes. However, the standard practice for map visualizations is to use Federal Information Processing Standards (FIPS) codes. These codes identify geographical areas at various level, such as [State, County and even County Subdivision] (https://www.census.gov/geo/reference/codes/cousub.html) levels. A reference map from the United States Census website is available [here] (https://www2.census.gov/geo/maps/general_ref/us_base/stco2010/USstcou2010_wallmap.pdf).

The first attempts were to map the ZIP code data from the CMS dataset to their respective FIPS codes by using some different means, such as this [County Cross Reference File] (http://wonder.cdc.gov/wonder/sci_data/codes/fips/type_txt/cntyxref.asp) from the Centers for Disease Control (CDC). However, the issue with this sort of mapping is that in some areas, 5-dgiti ZIP codes cross county lines, meaning that a ZIP code could have 2 different FIPS codes. Unable to find any freely available datasets which could map 9-digit ZIP codes to FIPS codes, it was time to purse another route.

Upon further research, a solution was found on the [North American Association of Central Cancer Registries] (http://www.naaccr.org/research/gisresources.aspx) website which has available for public use Geocoded National Provider Identifier data, which contains address and FIPS code data for medical providers.

The dataset for 2015 was downloaded and imported into our database. An example of the NPI and the respective FIPS data is shown below:

![NPI_GEO] (https://cloud.githubusercontent.com/assets/7533177/16885049/f957ed82-4a89-11e6-837f-a059ea137971.JPG)

Now it was time to finally merge the two datasets together. However, before doing so, it would be appropriate to check the number of records in the NPI geocoding dataset:

```SQL
SELECT COUNT(*) 
FROM NPIGEODATA 
```

The above query returned the following result:

![image_4 - npi_geodata_count](https://cloud.githubusercontent.com/assets/7533177/16886378/25c5d724-4a91-11e6-8f5c-652ea9152af9.JPG)

Now we have the task of merging these two datasets together. My first logic approach was to update the CMS dataset by adding a new column to store the FIPS code from the NPI dataset. Although, I knew it would probably take sometime to update millions of records, I did not quite expect that it would take literally 3 days (left the query running over the weekend) to update a column.

Given that this is a common issue in a variety of applications, I sought to find a different approach which would enable me to update the data a lot faster. My search led me to this solution: [How to update millions of records in a table] (https://asktom.oracle.com/pls/asktom/f?p=100:11:0::NO::P11_QUESTION_ID:6407993912330).

The code to create a new table which included the FIPS code from the NPI dataset was:

```SQL
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
```

Now, have the FIPS county code and State codes available in the same data table:

![image_5 - merged_data with fips](https://cloud.githubusercontent.com/assets/7533177/16888088/174e8e20-4a9b-11e6-9dec-ababcd3f6090.JPG)

One last step we have to do has to do with making the charges data usable. The data provided by CMS is provided as string values, however, so that we may be able to make computations on the data, we must convert into decimal numbers.

So, we run a new query as follows:

```SQL
CREATE TABLE CMSMEDICAREFINAL AS
SELECT CMSMEDICARENEW.NPI, CMSMEDICARENEW.NPPES_PROVIDER_LAST_ORG_NAME, CMSMEDICARENEW.NPPES_PROVIDER_FIRST_NAME, CMSMEDICARENEW.NPPES_PROVIDER_MI, 
CMSMEDICARENEW.NPPES_CREDENTIALS, CMSMEDICARENEW.NPPES_PROVIDER_GENDER, CMSMEDICARENEW.NPPES_ENTITY_CODE, CMSMEDICARENEW.NPPES_PROVIDER_STREET1, 
CMSMEDICARENEW.NPPES_PROVIDER_STREET2, CMSMEDICARENEW.NPPES_PROVIDER_CITY, CMSMEDICARENEW.NPPES_PROVIDER_ZIP, CMSMEDICARENEW.NPPES_PROVIDER_STATE, 
CMSMEDICARENEW.NPPES_PROVIDER_COUNTRY, CMSMEDICARENEW.PROVIDER_TYPE, CMSMEDICARENEW.MEDICARE_PARTICIP_INDICATOR, CMSMEDICARENEW.PLACE_OF_SERVICE, 
CMSMEDICARENEW.HCPCS_CODE, CMSMEDICARENEW.HCPCS_DESCRIPTION, CMSMEDICARENEW.HCPCS_DRUG_INDICATOR, CMSMEDICARENEW.LINE_SRVC_CNT, CMSMEDICARENEW.BENE_UNIQUE_CNT, 
CMSMEDICARENEW.BENE_DAY_SRVC_CNT, CMSMEDICARENEW.AVERAGE_MEDICARE_ALLOWED_AMT, CMSMEDICARENEW.STDEV_MEDICARE_ALLOWED_AMT, CMSMEDICARENEW.AVERAGE_SUBMITTED_CHRG_AMT, 
CMSMEDICARENEW.STDEV_SUBMITTED_CHRG_AMT, CMSMEDICARENEW.AVERAGE_MEDICARE_PAYMENT_AMT, CMSMEDICARENEW.STDEV_MEDICARE_PAYMENT_AMT, CMSMEDICARENEW.ZIPCODE5, CMSMEDICARENEW.FIPS_CO, TO_NUMBER(SUBSTR(CMSMEDICARENEW.AVERAGE_SUBMITTED_CHRG_AMT,2), '999999.99')  AVG_SUBMIT_CHARGES
FROM CMSMEDICARENEW;
```

And we now have the charges data as decimal numbers:

![image_6 - charge_data](https://cloud.githubusercontent.com/assets/7533177/16888677/d80de5ae-4a9e-11e6-8b2a-7a74801f8704.JPG)

Doing the two queries is unnecessary, as you can combine both update statements into a single query as follows:

```SQL
/*BOTH QUERIES MERGED - FINAL v2*/
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
```




