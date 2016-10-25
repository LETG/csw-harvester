# csw-harvester

##Synopsis

This is a python script that harvests metadata from CSW web services and saves some information from these metadata in a postgreSQL database.

##Motivation

This script is used to analyze Spatial Data Infrastructures for the GEOBS research project : https://www-iuem.univ-brest.fr/pops/projects/geobs.

##Dependencies

- psycopg2 : PostgreSQL database adapter for Python, https://pypi.python.org/pypi/psycopg2
- OWSlib : Python package for client programming with Open Geospatial Consortium (OGC) web service (hence OWS) interface standards, https://github.com/geopython/OWSLib
- OWSlib requires elementtree (standard in 2.5 as xml.etree) or lxml
- PostgreSQL

##How to run

The PostgreSQL database must first be created. A database dump is provided with csw_harvester.sql

The host, port, database name, schema, user and password must be set in csw-harvester.py.

The list of CSW is read from a CSV file ; an example is provided with sources-csw.csv

You can then run the python script csw-harvester.py with the following options :

- -f OUTPUTSCHEMA, --outputschema=OUTPUTSCHEMA outputschema : default = http://www.isotc211.org/2005/gmd
  
- -s SOURCES, --sources=SOURCES CSV file, 7 fields separated by comma: num_idg, name_idg, begin_record, end_record, MAXR, url, url_idg
  
- -l LOG_FILE, --log-file=LOG_FILE LOG file
  
- -c, --completion      completion mode
  
- -d DATE, --date=DATE  Extraction date

The completion mode (true by default) allows you to run another iteration of the script without overwriting the data already stored in the database. It's useful if for example one CSW stopped working after a given record and you want to start again from this record.

The date option allows you to force the extraction date stored in the database, if for example you're using the completion mode and want the extraction date to be the same for all metadata.

##License

This project is published under the General Public License v3.


