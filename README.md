# HR data analysis (part 1)

This is not a project with a story or a business task. I have specifically searched for an HR dataset to showcase my ability in mySQL and Tableau. I wanted to create a dynamic dashboard from scratch using an unknown __[dataset](https://data.world/markbradbourne/rwfd-real-world-fake-data/workspace/file?filename=Human+Resources.csv)__. Including getting familiar with the file, searching ways to explore and of cource, checking the logic and the consistency. Good thing on this topic is that everyone has a basic knowledge on gender distribution, race representation, work experience and other workplace characteristics - so we can concentrate on the main things.

### About the data

Data has been downloaded and stored locally and uploaded into Google Drive as a back-up.

As usual, we will treat this dataset as it's ROCCC:
- Reliable, Original and Cited: complete time series, which are accurate and non-bias. We will treat them as second-party datasets from a reliable organization.
- Current and Comprehensive: we consider them as regularly refreshed datasets, which are appropriate and will enable us to answer the business questions. 

We have the following columns:
- __id:__ unique employee id used as primary key
- __first_name:__ employee's first name
- __last_name:__ employee's last name
- __birthdate:__ the date of birth
- __gender:__ only categorical variable representing two genders: male or female
- __race:__ employee diversity
- __department:__ company's various divisions
- __jobtitle:__ employee's current jobtitle (including role level if applicable)
- __location:__ location type of work: remote or headquarter
- __hire_date:__ the date when the employee was hired
- __termdate:__ the date when the employee was let go 
- __location_city:__ the city of work
- __location_state:__ the state of work

Based on the location data we can already see that the company is based in the US.

### Setting up a business task

My goal is to create meaningful insights out of this company dataset.

1. What are the company values?
2. How they represent diversity and inclusion?
3. Is this an "equal opportunity" company?

#### Feedback, bug reports, and comments are not only welcome, but strongly encouraged!
