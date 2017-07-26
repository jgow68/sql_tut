# install.packages("RPostgreSQL")
require("RPostgreSQL")
# https://cran.r-project.org/web/packages/RPostgreSQL/RPostgreSQL.pdf
# https://www.postgresql.org/docs/9.6/static/index.html

# connect to PostgreSQL ---------------------------------------------------

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, dbname = 'postgres',
                 host = "localhost", port = '5432',
                 user = "postgres", password = '123456') # not recommended to show pw here

# check for the cartable
dbExistsTable(con, "cartable")


# write and load data onto PostgreSQL -------------------------------------

# list tables in database
dbListTables(con) # none for now

# creates df, a data.frame with the necessary columns
data(mtcars)
df <- data.frame(carname = rownames(mtcars), 
                 mtcars, 
                 row.names = NULL)
df$carname <- as.character(df$carname)
rm(mtcars)

# writes df to the PostgreSQL database "postgres", table "cartable" 
dbWriteTable(con, 'cartable' , df, row.names=FALSE) # options: overwrite=T / append=T

dbListTables(con) # now shows database 'cartable'
dbListFields(con, 'cartable') # list columns names of databases
dbDataType(con, 'cartable')

# query the data from postgreSQL 
df_postgres <- dbGetQuery(con, "SELECT * from cartable")

# compares the two data.frames
identical(df, df_postgres)
# TRUE

summary(df_postgres)

# extract part of the data
dbGetQuery(con, "SELECT carname, mpg
           FROM cartable
           WHERE mpg > 20")


# Basic Graph of the Data
require(ggplot2)
ggplot(df_postgres, aes(x = as.factor(cyl), y = mpg, fill = as.factor(cyl))) + 
  geom_boxplot() + theme_bw()

# remove table from database
dbGetQuery(con, "drop table cartable")

# commit the change
dbCommit(con)


# close connection --------------------------------------------------------

# disconnect from database
dbDisconnect(con)

#unload database driver
dbUnloadDriver(drv)