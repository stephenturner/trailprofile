library(RCurl)
library(rjson)

# returns a list with components: (each the same length)
#   $distance: numeric vector
#   $altitude: numeric vector
#   $latlng: a list of numeric vectors of length 2
get.strava.data <- function(strava.id) {
  url <- sprintf("http://app.strava.com/stream/%s?streams[]=latlng,distance,altitude", strava.id)
  strava.json <- getURL(url)
  parser <- newJSONParser()
  parser$addData(strava.json)
  parser$getObject() # slow
}

get.geojson <- function(strava.data) {
  shell <- "{\"type\": \"FeatureCollection\", \"features\": [{ \"type\": \"Feature\", \"geometry\": {\"type\": \"LineString\", \"coordinates\":\n [%s]\n}}]}";
  df <- cbind(do.call(rbind, strava.data$latlng), strava.data$altitude)
  coord.string <- paste(apply(df, 1, function(r) {
    sprintf("[%s]", paste(c(r[2],r[1],r[3]), collapse=","))
  }), collapse=",\n")
  sprintf(shell, coord.string)
}

# pass result of read.csv('trailprofile.csv')$Link
# along with directory name to write to (if it doesn't exist, it will be created)
populate.geojson.dir <- function(strava.urls, base.dir) {
  if (!file.exists(base.dir)) {
    dir.create(base.dir)
  }
  if (!file.info(base.dir)$isdir) {
    stop("Target location exists, but is not a directory")
  }
  strava.ids <- gsub("^http://app.strava.com/activities/", "", strava.urls)
  for (strava.id in strava.ids) {
    cat('Processing', strava.id, '\n')
    sink(file.path(base.dir, paste(strava.id, "geojson", sep=".")))
    cat(get.geojson(get.strava.data(strava.id)))
    sink(NULL)
  }
}