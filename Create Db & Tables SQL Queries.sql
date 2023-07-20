CREATE DATABASE "Olympic_History"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	
	
CREATE TABLE athlete_events (
    ID INTEGER,
    Name VARCHAR(255),
    Sex CHAR(1),
    Age INTEGER,
    Height INTEGER,
    Weight FLOAT,
    Team VARCHAR(255),
    NOC CHAR(3),
    Games VARCHAR(255),
    Year INTEGER,
    Season VARCHAR(10),
    City VARCHAR(255),
    Sport VARCHAR(255),
    Event VARCHAR(255),
    Medal VARCHAR(10)
);


CREATE TABLE noc_region (
    NOC CHAR(3),
    "Country name" VARCHAR(255),
    Notes VARCHAR(255)
);

select * from athlete_events;
select * from noc_region;