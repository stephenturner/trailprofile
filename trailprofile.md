# Charlottesville Area Trail Profiles

This repo has data and R code for plotting the elevation and distance profiles of some of my favorite trail runs around Charlottesville. If you want to add any to this list, please [email me](http://stephenturner.us/email.html) with the stats, or preferably submit a [pull request](https://help.github.com/articles/using-pull-requests).

This README was compiled using [knitr](http://yihui.name/knitr/). See the [Makefile](Makefile) for details.

## Code

This R code reads in the [data](./trailprofile.csv), computes the *Pain 'n Gain* score as the elevation changed normalized by distance (the higher the number, the more net elevation change per mile on average), and creates the plot further below.


```r
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

ID | Route | Link | Elevation | Distance | PainNGain
--- | --- | --- | --- | ---
32493109 | Rivanna Trail | http://app.strava.com/activities/32493109 | 1116 | 19.8 |  56.36
67987751 | UVA/RT loop w/ Lewis Mtn segment | http://app.strava.com/activities/67987751 |  817 |  8.8 |  92.84
70205315 | Walnut Creek | http://app.strava.com/activities/70205315 | 1412 | 11.7 | 120.68
56684464 | Sugar Hollow / Blackrock | http://app.strava.com/activities/56684464 | 2393 | 13.8 | 173.41
70913996 | Rockfish to Humpback Rocks parking lot | http://app.strava.com/activities/70913996 | 2898 | 14.4 | 201.25
58992224 | Jarman's Gap | http://app.strava.com/activities/58992224 | 3449 | 14.4 | 239.51
28118499 | Jarman's Gap w/ Turk Mtn Spur | http://app.strava.com/activities/28118499 | 4159 | 16.6 | 250.54
62558977 | Turk Gap / Riprap | http://app.strava.com/activities/62558977 | 2921 | 13.5 | 216.37
30484879 | Three ridges | http://app.strava.com/activities/30484879 | 4313 | 13.7 | 314.82


## Figure

The plot shows the elevation change vs. total mileage, with the size and color of the point increasing and becomming redder as the run becomes harder (more elevation change per mile).

![plot of chunk scatterplot](figure/scatterplot.png) 


## Maps

### Functions to build maps


```r
library(RCurl)
```

```
## Loading required package: bitops
```

```r
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

```
## Skipping geojson/32493109.geojson because it already exists. Add
## "rebuild=TRUE" to override. Skipping geojson/67987751.geojson because it
## already exists. Add "rebuild=TRUE" to override. Skipping
## geojson/70205315.geojson because it already exists. Add "rebuild=TRUE" to
## override. Skipping geojson/56684464.geojson because it already exists. Add
## "rebuild=TRUE" to override. Skipping geojson/70913996.geojson because it
## already exists. Add "rebuild=TRUE" to override. Skipping
## geojson/58992224.geojson because it already exists. Add "rebuild=TRUE" to
## override. Skipping geojson/28118499.geojson because it already exists. Add
## "rebuild=TRUE" to override. Skipping geojson/62558977.geojson because it
## already exists. Add "rebuild=TRUE" to override. Skipping
## geojson/30484879.geojson because it already exists. Add "rebuild=TRUE" to
## override.
```


### Display Maps

32493109: Rivanna Trail (http://app.strava.com/activities/32493109)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/jsonrmd/geojson/32493109.geojson"></script>

67987751: UVA/RT loop w/ Lewis Mtn segment (http://app.strava.com/activities/67987751)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/jsonrmd/geojson/67987751.geojson"></script>

70205315: Walnut Creek (http://app.strava.com/activities/70205315)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/jsonrmd/geojson/70205315.geojson"></script>

56684464: Sugar Hollow / Blackrock (http://app.strava.com/activities/56684464)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/jsonrmd/geojson/56684464.geojson"></script>

70913996: Rockfish to Humpback Rocks parking lot (http://app.strava.com/activities/70913996)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/jsonrmd/geojson/70913996.geojson"></script>

58992224: Jarman's Gap (http://app.strava.com/activities/58992224)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/jsonrmd/geojson/58992224.geojson"></script>

28118499: Jarman's Gap w/ Turk Mtn Spur (http://app.strava.com/activities/28118499)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/jsonrmd/geojson/28118499.geojson"></script>

62558977: Turk Gap / Riprap (http://app.strava.com/activities/62558977)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/jsonrmd/geojson/62558977.geojson"></script>

30484879: Three ridges (http://app.strava.com/activities/30484879)

<script src="https://embed.github.com/view/geojson/stephenturner/trailprofile/jsonrmd/geojson/30484879.geojson"></script>

