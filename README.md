# Introduction

The purpose of this repository is to both store and demonstrate the work performed towards visualizing Medicare charges data on a United States map at county level.

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

CMS provides data in two formats: as a single tab delimited file (to be imported into SAS or other statistical software packages) and as Microsoft Excel files. Given that I am not a SAS User (although it is in my plans to learn in the near future), I decided to utilize the Excel files in order to import them into a local Oracle database instance.

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

The first attempts were to map the ZIP code data from the CMS dataset to their respective FIPS codes by using some different means, such as this [County Cross Reference File] (http://wonder.cdc.gov/wonder/sci_data/codes/fips/type_txt/cntyxref.asp) from the Centers for Disease Control (CDC). However, the issue with this sort of mapping is that in some areas, 5-dgiti ZIP codes cross county lines, meaning that a ZIP code could have 2 different FIPS codes. Unable to find any freely available datasets which could map 9-digit ZIP codes to FIPS codes, it was time to pursue another route.

Upon further research, a solution was found on the [North American Association of Central Cancer Registries] (http://www.naaccr.org/research/gisresources.aspx) website which has Geocoded National Provider Identifier data available for public use. This dataset contains address and FIPS code data for medical providers.

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

Given that I am not the only in need of updating millions of records in an Oracle table, I sought to find a different approach which would enable me to update the data a lot faster. My search led me to this solution: [How to update millions of records in a table] (https://asktom.oracle.com/pls/asktom/f?p=100:11:0::NO::P11_QUESTION_ID:6407993912330).

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

Now, we have the FIPS county code and State codes available in the same data table:

![image_5 - merged_data with fips](https://cloud.githubusercontent.com/assets/7533177/16888088/174e8e20-4a9b-11e6-9dec-ababcd3f6090.JPG)

One last step I had to do was making the charges data usable. The data provided by CMS is provided as string values, however, I had to convert it into decimal numbers so that I would be able to make computations on the data.

So, I ran a new query as follows:

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

##Data Analysis

Now that our data is in "usable" form, it is time to do some data analysis.

My first thought was to determine which were the most common procedures:

```SQL
SELECT HCPCS_CODE, HCPCS_DESCRIPTION, COUNT(*)
FROM CMSMEDICAREFINAL
GROUP BY HCPCS_CODE, HCPCS_DESCRIPTION
ORDER BY COUNT(*) DESC
```

The list of the top 25 most common procedures was as follows:

![image_7 - top 25 procedures](https://cloud.githubusercontent.com/assets/7533177/16889290/883f3ad8-4aa2-11e6-9e7b-15cdaddb800a.JPG)

Given that office visits may be a bit subjective, as some doctors may charge more than others according to their specialty, I decided to focus on the Flu vaccine procedure. It is a simple procedure that most of us are familiar with and, thus, we can have a better sense of what should be a "reasonable" charge for this service.

In order to have the data ready for visualization, I decided to create a new table with the Median of the average charges for the Flu Vaccine procedure on a county basis:

```SQL
CREATE TABLE FLUCHARGES AS
SELECT NPPES_PROVIDER_STATE, FIPS_CO, MEDIAN(AVG_SUBMIT_CHARGES) AS MEDIAN_CHARGES
FROM CMSMEDICAREFINAL
WHERE HCPCS_CODE = 'G0008'
GROUP BY NPPES_PROVIDER_STATE, FIPS_CO
ORDER BY NPPES_PROVIDER_STATE ASC, FIPS_CO ASC;
```

A sample of the data looked as follows:

![image_8 - median flu charges](https://cloud.githubusercontent.com/assets/7533177/16889793/55851bfe-4aa6-11e6-99ec-e2628a43c710.JPG)

Let's take a further look, and see if we have any outlier values:
```SQL
SELECT DISTINCT(MEDIAN_CHARGES),COUNT(*)
FROM FLUCHARGES
GROUP BY MEDIAN_CHARGES
ORDER BY COUNT(*)DESC
```
![image_9 - frequency of flu charges](https://cloud.githubusercontent.com/assets/7533177/16890219/d86d6e7e-4aa9-11e6-9abc-41f295f8b4a1.JPG)

By taking a quick look at the data, we can see that the average charges range somewhere between 10 and 40 dollars. Just to confirm, we run another simple query:

```SQL
SELECT MAX(MEDIAN_CHARGES), MIN(MEDIAN_CHARGES), MEDIAN(MEDIAN_CHARGES)  FROM FLUCHARGES
```

And we get the following:

![image_10 - max_min_median_flu_charges](https://cloud.githubusercontent.com/assets/7533177/16890273/4ad3ec0e-4aaa-11e6-8bc8-7c2ab9d287d1.JPG)

Running our query again to get the frequency of Median charges and now ordering the values from low to high we get the following:

![image_11 - low_2_high_flu_charges](https://cloud.githubusercontent.com/assets/7533177/16890349/c1afee86-4aaa-11e6-8e72-05a552141988.JPG)

And from high to low:

![image_12 - high_2_low_flu_charges](https://cloud.githubusercontent.com/assets/7533177/16890351/c88ded98-4aaa-11e6-9b92-82c7bdbd8ed6.JPG)

Given that the $0.01 and $489.71 values occur only once in the dataset, it is probably best to remove them in order not to skew the remaining values. 

```SQL
DELETE FROM FLUCHARGES 
WHERE MEDIAN_CHARGES = 489.71

DELETE FROM FLUCHARGES 
WHERE MEDIAN_CHARGES = 0.01
```

Now, the data is ready to be visualized.

##Data Visualization

The next step in the whole process was to finally visualize the data. A cloropeth of the United States with county subdivision was deemed the most appropriate choice.

My first attempt at making a cloropeth was using the [Bokeh] (http://bokeh.pydata.org/en/latest/) libray for Python. The map looked like this:


![bokeh_plot](https://cloud.githubusercontent.com/assets/7533177/16897950/85ecea48-4b81-11e6-844d-38281418e854.png)

Although it was a good exercise, I was not particularly impressed with the quality of the map. However, the exercise also served to better adjust the color intervals, as some of the very high charge costs were a bit away from the remaining values. I therefore decided also to remove the values above $80.075, in order for the cloropeth to more accurately represent the variation in charges between counties.

An alternative way to do the cloropeth was found [here] (http://flowingdata.com/2009/11/12/how-to-make-a-us-county-thematic-map-using-free-tools/), and it produced a much better quality map:

![flu_charges_map with legend](https://cloud.githubusercontent.com/assets/7533177/16905195/973f5662-4c5f-11e6-9644-2f8e070b8cd2.png)

A quick look at the cloropeth and we can conclude that the average charges across the country are between $20 and $35. We can identify some areas with higher charges in some metro areas (Raleigh-Durham and Charlotte in NC, for example), however we also see some above average charges in what appear to be rural areas. Higher charges in metropolitan areas can be related to higher cost of living, however, in rural areas, higher costs could mean lack of competition due to fewer doctors in some areas. In order to draw some accurate conclusions, it would be necessary to cross-reference this data with cost of living data or map the number of providers per county using the NPI dataset.


Lastly, a similar visualization was performed on another common procedure, Collection of Blood Sample. The cloropeth looks as follows:

![blood_sample_charges_map with legend](https://cloud.githubusercontent.com/assets/7533177/16905853/eae3573c-4c69-11e6-8336-3332f08611b4.png)


Again, we find a similar pattern, in that we are able to identify higher charges in both some metropolitan areas and in rural areas, as well. 

## Conclusions

This work served as a good exercise into dealing with a large dataset and being able to visualize it as a cloropeth. As part of a future Data Incubator project, it would serve as a great starting point in order to be enriched with other relevant data, such as cost-of-living data, provider data, additional mapping of metropolitan areas. By cross-referecing additional datasets, it would then be possible to infer some causes which could explain the wide range of charges for common medical procedures in the United States.
