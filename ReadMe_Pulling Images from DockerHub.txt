to pull and run images from ducker Hub:
   docker pull hdsali/wf_engine:latest

get the docker-compose.yaml and init.sql files; from that location path run this commands along side with docker-compose.yaml:
   docker-compose down -v   # Stops containers and removes volumes
   docker-compose up -d     # SQL Server runs init.sql

to create and seed DB,tables with data:
   sqlcmd -S 127.0.0.1,1437 -U sa -P Password123 -i C:\"YourFilesLocation"\init.sql

