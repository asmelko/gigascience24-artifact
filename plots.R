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

data_gpu = read.csv('results/gpu_out_synth.csv', header=T, sep=';')
data_gpu = average(data_gpu)

data_cpu = read.csv('results/cpu_out_synth.csv', header=T, sep=';')
names(data_cpu)[names(data_cpu) == "parsing"] <- "compilation"
data_cpu = subset(data_cpu, select = -threads)
data_cpu = average(data_cpu)

data_cpu["type"] = "CPU"
data_gpu["type"] = "GPU"
data = rbind(data_cpu, data_gpu)

data_gpu_real = read.csv('results/gpu_out_real.csv', header=T, sep=';')
data_gpu_real = average(data_gpu_real)

data_cpu_real = read.csv('results/cpu_out_real.csv', header=T, sep=';')
names(data_cpu_real)[names(data_cpu_real) == "parsing"] <- "compilation"
data_cpu_real = subset(data_cpu_real, threads == 64) # modify here, which thread count to plot
data_cpu_real = subset(data_cpu_real, select = -threads)
data_cpu_real = average(data_cpu_real)

data_cpu_real["type"] = "CPU"
data_gpu_real["type"] = "GPU"
data_real = rbind(data_cpu_real, data_gpu_real)

{
    data_c = data

    data_c = subset(data_c, max_time == 100)
    # data_c = subset(data_c, nodes <= 100)
    data_c = subset(data_c, formula_size == 4)
    data_c = subset(data_c, sample_count == 1000000)

    data_x = data_c
    data_y = data_c
    data_x["total"] = data_x["simulation"]
    data_x["desc"] = "Simulation"
    data_y["total"] = data_y["compilation"] + data_y["simulation"]
    data_y["desc"] = "Simulation + Runtime Compilation"

    data_c = rbind(data_x, data_y)

    ggsave("results/nodes.pdf", device='pdf', units="in", scale=S, width=W, height=H,
        ggplot(data_c, aes(x=nodes,y=total, color=factor(type), shape=factor(type))) +
        geom_point(size=point_size) +
        geom_line(linewidth=line_size) +
        xlab("Nodes count (log-scale)")+
        ylab("Wall time (log-scale)")+
        labs(color="Machine", shape="Machine") +
        linecolors +
        scale_y_log10(labels = sisec) +
        scale_x_log10(breaks=c(0, 10, 20, 40, 100, 200, 400, 1000)) +
        facet_wrap(~desc) +
        theme + background_grid() + theme(legend.position="bottom")
    )
}

{
    data_c = data

    data_c = subset(data_c, max_time == 100)
    data_c = subset(data_c, nodes %in% c(200, 400, 600, 800, 1000))
    data_c = subset(data_c, formula_size %in% c(4, 9, 24, 49))
    data_c = subset(data_c, sample_count %in% c(4*10^6, 6*10^6, 8*10^6, 10*10^6))

    data_c["total"] = data_c["compilation"] + data_c["simulation"]
    data_c["ratio"] = data_c["compilation"] / data_c["total"]

    data_c["formula_size"] =  2 * (data_c["formula_size"] + 1)

    data_c$sample_count = factor(c("4M", "6M", "8M", "10M"), levels=c("4M", "6M", "8M", "10M"))

    ggsave("results/nodes-compilation-big.pdf", device='pdf', units="in", scale=S, width=W, height=H,
        ggplot(data_c, aes(x=nodes,y=ratio, color=sample_count, shape=sample_count)) +
        geom_point(size=point_size) +
        geom_line(linewidth=line_size) +
        xlab("Nodes count (log-scale)")+
        ylab("% of total time compiling (log-scale)")+
        labs(color="Sample Count", shape="Sample Count") +
        #scale_color_manual(values=RColorBrewer::brewer.pal(9,'YlGnBu')[2:9]) +
        linecolors +
        scale_y_log10(labels = scales::percent) +
        scale_x_continuous(breaks=c(200, 400, 600, 800, 1000)) +
        facet_wrap(~formula_size, ncol=4, labeller=labeller(formula_size=Vectorize(function(x) paste0("Formula size: ", x)))) +
        theme + background_grid() + theme(legend.position="bottom", axis.text.x = element_text(angle = -25, vjust=0.05))
    )
}

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

    ggsave("results/real.pdf", device='pdf', units="in", scale=S, width=W, height=H,
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

data_mpi = read.csv('results/mpi_out_real.csv', header=T, sep=';')
names(data_mpi)[names(data_mpi) == "parsing"] <- "compilation"
data_mpi = average(data_mpi)

data_mpi["algorithm"] = "MPI"

ggsave("results/sizek_mpi.pdf", units="in", width=7, height=5,
ggplot(data_mpi, aes(threads * mpi_nodes, total, color=algorithm, shape=algorithm, group=algorithm)) +
  geom_point() +
  stat_smooth(geom='line', method='lm') +
  scale_x_log10("Cores (log-scale)") +
  scale_y_log10("Wall time (log-scale)") +
  scale_color_brewer("Software", palette='Dark2') +
  scale_shape("Software") +
  theme_cowplot(font_size=9) +
  theme(
    panel.grid.major=element_line(size=.2, color='#cccccc'),
  )
)

data_mpi = read.csv('results/mpi_out_synth.csv', header=T, sep=';')
names(data_mpi)[names(data_mpi) == "parsing"] <- "compilation"
data_mpi = average(data_mpi)

data_mpi["algorithm"] = "MPI"

ggsave("results/synth_mpi.pdf", units="in", width=7, height=5,
ggplot(data_mpi, aes(threads * mpi_nodes, total, color=algorithm, shape=algorithm, group=algorithm)) +
  geom_point() +
  stat_smooth(geom='line', method='lm') +
  scale_x_log10("Cores (log-scale)") +
  scale_y_log10("Wall time (log-scale)") +
  scale_color_brewer("Software", palette='Dark2') +
  scale_shape("Software") +
  theme_cowplot(font_size=9) +
  theme(
    panel.grid.major=element_line(size=.2, color='#cccccc'),
  )
)

data_mpi["cpus"] = data_mpi["threads"] * data_mpi["mpi_nodes"]
min_cpus = min(data_mpi["cpus"])
min_cpus_time = data_mpi[data_mpi["cpus"] == min_cpus, "total"]

ggsave("results/synth_mpi_speedup.pdf", units="in", width=7, height=5,
ggplot(data_mpi, aes(cpus, min_cpus *(min_cpus_time / total), color=algorithm, shape=algorithm, group=algorithm)) +
  geom_point() +
  stat_smooth(geom='line', method='lm') +
  scale_x_log10("Cores (log-scale)") +
  scale_y_log10("Speedup (log-scale)", labels = function (x) paste0(x,"x")) +
  scale_color_brewer("Software", palette='Dark2') +
  scale_shape("Software") +
  theme_cowplot(font_size=9) +
  theme(
    panel.grid.major=element_line(size=.2, color='#cccccc'),
  )
)