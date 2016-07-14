# Introduction

The purpose of this repository is to both store and demonstrate the work performed as a project submission for "The Data Incubator" Fellowship program.

This page contains background information on the project, as well as, code samples and visualizations


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

As part of the importing process, the Excel files were first converted to the CSV format and imported into Oracle using SQL Developer's data import interface.

A screenshot of the uploaded data in SQL Developer is shown below:

![CMSDATATABLE] (https://cloud.githubusercontent.com/assets/7533177/16855634/68dc720c-49d3-11e6-870f-301bbdff7a8c.JPG)

A quick check to ensure that we uploaded all the data:

```SQL
SELECT COUNT(*) 
FROM CMSMEDICAREDATA
```
