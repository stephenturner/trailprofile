# Charlottesville Area Trail Profiles

This repo has data and R code for plotting the elevation and distance profiles of some of my favorite trail runs around Charlottesville. If you want to add any to this list, please [email me](http://stephenturner.us/email.html) with the stats, or preferably submit a [pull request](https://help.github.com/articles/using-pull-requests).

This README was compiled using [knitr](http://yihui.name/knitr/). See the [Makefile](Makefile) for details.

## Code

This R code reads in the [data](./trailprofile.csv), computes the *Pain 'n Gain* score as the elevation changed normalized by distance (the higher the number, the more net elevation change per mile on average), and creates the plot further below.


```S
library(ggplot2)

trailprofile <- read.csv("trailprofile.csv", header = TRUE, stringsAsFactors = FALSE)
trailprofile <- transform(trailprofile, PainNGain = Elevation/Distance)
trailprofile <- transform(trailprofile, ID = as.integer(gsub("^http://app.strava.com/activities/", 
    "", Link)))
trailprofile <- data.frame(ID = trailprofile$ID, trailprofile[, -which(names(trailprofile) == 
    "ID")], stringsAsFactors = FALSE)

p <- ggplot(data = trailprofile, aes(Distance, Elevation, label = Route)) + 
    geom_point(aes(colour = PainNGain, size = PainNGain)) + scale_size(range = c(3, 
    25)) + scale_colour_continuous(low = "blue4", high = "red2")
p <- p + geom_text(size = 5, angle = 51, vjust = 2, hjust = 0.1, colour = "gray20")
p <- p + scale_x_continuous(limits = c(8, 23))
p <- p + scale_y_continuous(limits = c(700, 5200))
p <- p + labs(title = "Charlottesville Area Trail Profiles")
```





## Data

The file [trailprofile.csv](./trailprofile.csv) has the raw data (route name, link, elevation, distance). The *Pain 'n Gain* score is the elevation changed normalized by distance - the higher the number, the more net elevation change per mile on average.

Route | Link | Elevation | Distance | PainNGain
--- | --- | --- | --- | ---
Rivanna Trail | http://app.strava.com/activities/32493109 | 1116 | 19.8 |  56.36
UVA/RT loop w/ Lewis Mtn segment | http://app.strava.com/activities/67987751 |  817 |  8.8 |  92.84
Walnut Creek | http://app.strava.com/activities/70205315 | 1412 | 11.7 | 120.68
Sugar Hollow / Blackrock | http://app.strava.com/activities/56684464 | 2393 | 13.8 | 173.41
Rockfish to Humpback Rocks parking lot | http://app.strava.com/activities/70913996 | 2898 | 14.4 | 201.25
Jarman's Gap | http://app.strava.com/activities/58992224 | 3449 | 14.4 | 239.51
Jarman's Gap w/ Turk Mtn Spur | http://app.strava.com/activities/28118499 | 4159 | 16.6 | 250.54
Turk Gap / Riprap | http://app.strava.com/activities/62558977 | 2921 | 13.5 | 216.37
Three ridges | http://app.strava.com/activities/30484879 | 4313 | 13.7 | 314.82


## Figure

The plot shows the elevation change vs. total mileage, with the size and color of the point increasing and becomming redder as the run becomes harder (more elevation change per mile).

![plot of chunk scatterplot](figure/scatterplot.png) 


## Maps

### Functions to build maps

The R functions below are used to generate [GitHub-compatible maps in geoJSON format](https://help.github.com/articles/mapping-geojson-files-on-github). The `get.strava.data()` function takes a Strava ID and returns a list of components to be parsed by `get.geojson()`. The `populate.geojson.dir()` function takes a vector of Strava IDs, a base directory, and builds maps using the filename convention `<base.dir>/<ID>.geojson`. 


```S
library(RCurl)
library(rjson)

## Takes strava ID as input (See URL parser) Returns a list with components
## (each the same length) to be parsed by get.geojson(): $distance: numeric
## vector $altitude: numeric vector $latlng: a list of numeric vectors of
## length 2
get.strava.data <- function(strava.id) {
    url <- sprintf("http://app.strava.com/stream/%s?streams[]=latlng,distance,altitude", 
        strava.id)
    strava.json <- getURL(url)
    parser <- newJSONParser()
    parser$addData(strava.json)
    parser$getObject()  # slow
}

## Parse strava data to github-flavored geojson
get.geojson <- function(strava.data) {
    shell <- "{\"type\": \"FeatureCollection\", \"features\": [{ \"type\": \"Feature\", \"geometry\": {\"type\": \"LineString\", \"coordinates\":\n [%s]\n}}]}"
    df <- cbind(do.call(rbind, strava.data$latlng), strava.data$altitude)
    coord.string <- paste(apply(df, 1, function(r) {
        sprintf("[%s]", paste(c(r[2], r[1], r[3]), collapse = ","))
    }), collapse = ",\n")
    sprintf(shell, coord.string)
}

## Function to loop through vector of Strava IDs and create 'ID.geojson' file
## in a base directory that will be created if it doesn't already exist. Add
## option rebuild=TRUE to force rebuild existing geojson files.
populate.geojson.dir <- function(strava.ids = NULL, base.dir = "geojson", rebuild = FALSE) {
    if (!file.exists(base.dir)) 
        dir.create(base.dir)  # create geojson directory if it doesn't exist
    if (!file.info(base.dir)$isdir) 
        stop("Target location exists, but is not a directory")
    for (id in strava.ids) {
        filename <- file.path(base.dir, paste(id, "geojson", sep = "."))
        if (!file.exists(filename) | rebuild) {
            message(paste("Processing strava ID", id, "into path:", filename))
            sink(filename)  # write to file
            cat(get.geojson(get.strava.data(id)))
            sink(NULL)
        } else {
            message(paste("Skipping", filename, "because it already exists. Add \"rebuild=TRUE\" to override."))
        }
    }
}

base.dir <- "geojson"
populate.geojson.dir(trailprofile$ID, base.dir = base.dir)
```


### Display Maps

Clicking any of the links below takes you to the geoJSON map hosted on GitHub.

[Rivanna Trail (32493109)](geojson/32493109.geojson)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/master/geojson/32493109.geojson"></script>

[UVA/RT loop w/ Lewis Mtn segment (67987751)](geojson/67987751.geojson)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/master/geojson/67987751.geojson"></script>

[Walnut Creek (70205315)](geojson/70205315.geojson)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/master/geojson/70205315.geojson"></script>

[Sugar Hollow / Blackrock (56684464)](geojson/56684464.geojson)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/master/geojson/56684464.geojson"></script>

[Rockfish to Humpback Rocks parking lot (70913996)](geojson/70913996.geojson)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/master/geojson/70913996.geojson"></script>

[Jarman's Gap (58992224)](geojson/58992224.geojson)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/master/geojson/58992224.geojson"></script>

[Jarman's Gap w/ Turk Mtn Spur (28118499)](geojson/28118499.geojson)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/master/geojson/28118499.geojson"></script>

[Turk Gap / Riprap (62558977)](geojson/62558977.geojson)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/master/geojson/62558977.geojson"></script>

[Three ridges (30484879)](geojson/30484879.geojson)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/master/geojson/30484879.geojson"></script>

