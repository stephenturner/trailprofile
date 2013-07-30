library(ggplot2)
# library(scales)

setwd("~/github/trailprofile")

trailprofile <- read.csv("trailprofile.csv", header=TRUE, stringsAsFactors=FALSE)
trailprofile <- transform(trailprofile, PainNGain=Elevation/Distance)
str(trailprofile)

qplot(Distance, Elevation, data=trailprofile, size=PainNGain2, color=PainNGain, ylim=c(600, 4500), label=Route) + scale_size(range=c(3,20)) + scale_colour_continuous(low="blue4", high="red2")


p <- ggplot(data=trailprofile, aes(Distance, Elevation, label=Route)) + 
    geom_point(aes(colour=PainNGain, size=PainNGain)) + 
    scale_size(range=c(3,25)) + 
    scale_colour_continuous(low="blue4", high="red2")
p <- p+geom_text(size=4, angle=45, vjust=2, hjust=.1, colour="gray20")
p <- p + scale_x_continuous(limits=c(8, 23)) + scale_y_continuous(limits=c(700,5200))
p <- p + labs(title="Charlottesville Area Trail Profiles")

print(p)
ggsave(filename="trailprofile.png")