# Charlottesville Area Trail Profiles

This repo has data and R code for plotting the elevation and distance profiles of some of my favorite trail runs around Charlottesville. If you want to add any to this list, please [email me](http://stephenturner.us/email.html) with the stats, or preferably submit a pull request.

This README was compiled using [knitr](http://yihui.name/knitr/). See the Makefile for details.

## Code

This R code reads in the [data](./trailprofile.csv), computes the *Pain 'n Gain* score as the elevation changed normalized by distance (the higher the number, the more net elevation change per mile on average), and creates the plot further below.


```S
library(ggplot2)

trailprofile <- read.csv("trailprofile.csv", header = TRUE, stringsAsFactors = FALSE)
trailprofile <- transform(trailprofile, PainNGain = Elevation/Distance)

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


