# Function for plotting decompositions of mutational profiles over different signatures
# Requires: ggplot2, reshape2
# Arguments: decomposition - matrix of fractions, samples x signatures
#            mm - matrix of mutational counts of different types, samples x 96 (or 104) mutation types
#            intnames - character vector of names of samples to plot (should be present in decomposition and mm's rownames)
#            col - vector of colours to use for signatures
#            circle - TRUE or FALSE, make it a circular barplot ('nautilus-plot') or a normal one
#            size - regulates the size of x-axis text (sample names)
#            axis.size - regulates the size og legend text and y-axis text (signature names and numbers on y scale)

plot_decomposition <- function(decomposition, mm, intnames, col,circle=F,size=6,axis.size=10) {
  for (i in 1:nrow(decomposition))
    decomposition[i,] = decomposition[i,] / sum(decomposition[i,])
  new.cont.mat <- t(decomposition[intnames,])
  for (y in colnames(new.cont.mat)) {
    new.cont.mat[,y] = new.cont.mat[,y] * rowSums(mm)[y]
  }
  m.new.cont.mat <- melt(new.cont.mat)
  colnames(m.new.cont.mat) = c("Signature","Sample","Contribution")
  order(rowSums(mm),decreasing = F) -> sampleorder
  names(sampleorder) <- row.names(mm)[sampleorder]
  plot = ggplot(m.new.cont.mat, aes(x = factor(Sample,levels=names(sampleorder)), 
                                    y = Contribution, fill = factor(Signature,levels=colnames(decomposition)), order = Sample)) + 
    geom_bar(stat = "identity", colour = "black") + 
    labs(x = "", y = "Absolute contribution \n (no. mutations)") + 
    theme_bw() + 
    scale_fill_manual(name="",values=col) + 
    theme(panel.grid.minor.x = element_blank(), panel.grid.major.x = element_blank()) + 
    theme(panel.grid.minor.y = element_blank(), panel.grid.major.y = element_blank()) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1,size=size),
          axis.text.y = element_text(size=axis.size),
          legend.text=element_text(size=axis.size))
  if (circle) {
    new.cont.mat <- t(decomposition[intnames,])
    for (y in colnames(new.cont.mat)) {
      new.cont.mat[,y] = new.cont.mat[,y] * log10(rowSums(mm)[y])
    }
    m.new.cont.mat <- melt(new.cont.mat)
    colnames(m.new.cont.mat) = c("Signature","Sample","Contribution")
    plot = ggplot(m.new.cont.mat, aes(x = factor(Sample,levels=names(sampleorder)), 
                                                y = Contribution, fill = factor(Signature,levels=colnames(decomposition)), order = Sample)) + 
    geom_bar(stat = "identity", colour = "black") + 
    theme_bw() + 
    scale_fill_manual(name="",values=col) + 
    theme(panel.grid.minor.x = element_blank(), panel.grid.major.x = element_blank()) + 
    theme(panel.grid.minor.y = element_blank(), panel.grid.major.y = element_blank()) +
    theme(axis.text.x = element_text(size=size),
          axis.text.y = element_text(size=axis.size),
          legend.text=element_text(size=axis.size)) + 
    coord_polar() + 
    labs(x = "", y = "Absolute contribution \n (no. mutations, log10)")
  }
  plot
}

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}