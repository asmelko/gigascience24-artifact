library(ggplot2)
library(cowplot)
library(sitools)
library(dplyr)


W=4.804
H=2
S=1
point_size=0.8
line_size=0.5
linecolors=scale_color_brewer(palette="Set2")
theme = theme_cowplot(font_size=7)

sisec=Vectorize(function(t)if(is.na(t))NA else sitools::f2si(t / 10^6, 's'))

average <- function(data)
{
    data["total"] = data["compilation"] + data["visualization"] + data["simulation"]
    data <- subset(data, select = -X)

    data_s <- split(data, paste0(data$max_time, data$nodes, data$formula_size, data$sample_count, data$threads, data$mpi_nodes, data$algorithm))
    data <- NULL
    for (i in 1:length(data_s)){
        tmp = subset(data_s[[i]], !(total %in% boxplot(data_s[[i]]$total, plot = FALSE)$out))
        data <- rbind(data, tmp)
    }

    data = data.frame(data %>% group_by_at(names(data)[-grep("(total)|(compilation)|(visualization)|(simulation)", names(data))]) %>% summarise(total = mean(total), compilation = mean(compilation), visualization = mean(visualization), simulation = mean(simulation)))
}

data_gpu_real = read.csv('results/gpu_out_real_ktt.csv', header=T, sep=';')
data_gpu_real = average(data_gpu_real)

data_cpu_real = read.csv('results/cpu_out_real_ktt.csv', header=T, sep=';')
names(data_cpu_real)[names(data_cpu_real) == "parsing"] <- "compilation"
data_cpu_real = subset(data_cpu_real, threads == 64) # modify here, which thread count to plot
data_cpu_real = subset(data_cpu_real, select = -threads)
data_cpu_real = average(data_cpu_real)

data_cpu_real["type"] = "CPU"
data_gpu_real["type"] = "GPU"
data_real = rbind(data_cpu_real, data_gpu_real)

{
    data_c = data_real

    data_c = subset(data_c, name != "metastasis")

    norms = data_c[c("total", "type", "name")]

    data_c["nn"] = 0
    data_c["diff"] = 0
    data_c["speedup"] = 0

    for (n in c("cellcycle", "Montagud", "sizek"))
    {
        norm = as.numeric(norms[norms$type == "CPU" & norms$name == n, ]["total"])
        data_c <- transform(data_c, nn = ifelse(norms$name == n, norm, nn))
        data_c <- transform(data_c, diff = ifelse(norms$name == n, total - norm, diff))
        data_c <- transform(data_c, speedup = ifelse(norms$name == n, norm / total, speedup))
    }

    ggsave("plots/real.pdf", device='pdf', units="in", scale=S, width=W, height=H,
        ggplot(data_c, aes(x=type, y=total, fill=type)) +
        geom_bar(stat="identity", position=position_dodge()) +
        geom_errorbar(aes(ymin=total, ymax=(total - diff)), width=.1) + 
        geom_text(aes(label=ifelse(speedup == 1, sitools::f2si(round(total / 10^6, digits=2), 's'), paste0('-',round(speedup, digits=0),'x')), y=total), size=2, vjust=0.5*3) + 
        geom_hline(aes(yintercept=nn), linewidth=.3) +
        xlab("")+
        ylab("Wall time (sqrt-scale)")+
        labs(color="Machine", shape="Machine", fill="Machine") +
        scale_fill_brewer(palette="Set2") +
        scale_y_continuous(trans=scales::trans_new('my_sqrt', function (x) x ^ (1/4), function (x) x^4), labels = sisec, breaks=c(100 * 10^6, 10 * 10^6, 100 * 10^3, 500 * 10^3)) +
        facet_wrap(~name, ncol=4, scales="free_y") +
        theme + background_grid() + theme(legend.position="bottom", axis.title.x=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank())
    )
}