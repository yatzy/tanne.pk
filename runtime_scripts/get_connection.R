getConnection <- function(driver , host , user , password, dbname ) {
  
  if (!exists('.connection', where=.GlobalEnv)) {
    .connection <<- dbConnect( driver , host , user , password , dbname  )
  } else if (class(try(dbGetQuery(.connection, "SELECT 1"))) == "try-error") {
    dbDisconnect(.connection)
    .connection <<- dbConnect(driver , host , user , password , dbname)
  }
  return(.connection)
}