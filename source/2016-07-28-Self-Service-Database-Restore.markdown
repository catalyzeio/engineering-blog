---
title: Self Service Database Restore
date: 2016-07-28
author: heath
author_full: Heath Skarlupka
author_alt: Co-author - Vince Kenney
tags: database, postgresql, mysql, mongodb, stratum, 2.1.0
---
### Self Service Database Restore

I was recently involved in a couple of production database restores for customer environments in Stratum.  As engineers, we have all been there.  Maybe you deployed a development branch to production with breaking schema changes or maybe you fat fingered a SQL command and deleted all of the rows in a table.  This is why Catalyze stores 30 days of nightly backups for each database in your environment.

Historically a database restore required a support ticket and a Catalyze engineer.  I set out to see if the CLI enhancements in Stratum 2.1 allowed database restores without the help of a Catalyze engineer.  For this example, I’ll use a PostgreSQL database service called database-1 with a database called catalyzeDB and a single code service called code-1.

1. Stop all code services that connect to the database.  This step is important because open connections will cause conflicts when restoring the database from a backup.

`$ catalyze services stop code-1`

2. List the latest database backups and download the appropriate one.  For this example, I want to find the newest one.

`$ catalyze db list database-1`

`$ catalyze db download database-1 <UUID FROM BACKUP LIST> ./recover.sql`

3. Access the database console, connect to the postgres database, DROP the bad database, and CREATE an empty one.  It's important that you connect to the postgres database before running the DROP operation because PostgreSQL will throw an error when dropping a database with open connections.

```
$ catalyze console database-1
> \connect postgres
> DROP DATABASE "catalyzeDB";
> CREATE DATABASE "catalyzeDB";
> \q
```

4. Import the downloaded SQL dump into the newly created database.

`$ catalyze db import database-1 ./recover.sql`

5. Restart any code services that were stopped in step 1.

`$ catalyze redeploy code-1`

6. Finally review the database import by connecting to the database via the console and accessing the app with your favorite browser.

## MySQL

For those using MySQL steps 3 and 4 will be slightly different.

3. Access the database console, connect to the msql database, DROP the bad database, and CREATE an empty one.  It's important that you connect to the msql database before running the DROP operation because MySQL will throw an error when dropping a database with open connections.

```
catalyze console database-1
>use mysql;
> DROP DATABASE "catalyzeDB";
> CREATE DATABASE "catalyzeDB";
> exit
```

4. Import the downloaded SQL dump into the newly created database.

`catalyze db import database-1 ./recover.sql`

## MongoDB

Finally let’s look at MongoDB.  The major difference being that we need to connect directly to the database being dropped.

3. Access the database console, connect to the catatlyzeDB database, DROP the bad database, and CREATE an empty one.  By default, the use command will create a new database if it doesn’t exist.

```
catalyze console database-1
>use catalyzeDB
>db.dropDatabase()
>use catalyzeDB
> exit
```

4. Import the downloaded dump file into the newly created database.  This dump file is a compressed tarball.  I suggest using the name recover.tar.gz instead of recover.sql in step 2 for mongo databases.

`catalyze db import database-1 ./recover.tar.gz`

If you run into any issues while recovering a database, don’t hesitate to submit a ticket via the product dashboard, product.catalyze.io.
