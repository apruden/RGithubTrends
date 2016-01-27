library(shiny)
library(httr)
library(ggplot2)
library(parallel)
library(reshape2)

source('config-prod.R')

loadData <- function() {
    message('Loading git data ...')
    tryCatch({
        req <- GET('https://api.github.com/search/repositories?q=language:R&sort=stars&order=desc&per_page=20', authenticate(githubUser, githubToken))
        stop_for_status(req)
        repos <- content(req)$items
        ncores <- detectCores()
        message(paste('Cluster on', ncores, 'nodes.'))
        cl <- makeCluster(ncores)
        data <- parSapply(cl, repos, function(repo) {
                          library(httr)
                          source('config-prod.R')
                          req <- GET(paste0(repo$url, '/stats/participation'), authenticate(githubUser, githubToken))
                          stop_for_status(req)
                          tmp <- content(req)
                          c(repo$name, tmp$all)
})
        stopCluster(cl)
        df <- as.data.frame(matrix(as.numeric(data[2:nrow(data),]), nrow(data)-1, ncol(data)))
        colnames(df) <- data[1,]
        melt(cbind(data.frame(Week=1:52), df),
             id.vars='Week',
             variable.name='Repository')
    }, warning=function(warn) {
        message(str(warn))
        return(read.csv('GitData.csv'))
    }, error= function(err) {
        message(str(err))
        return(read.csv('GitData.csv'))
    })
}

GitData <- NULL

shinyServer(function(input, output) {
            output$repoSelect <- renderUI({
                progress <- shiny::Progress$new()
                on.exit(progress$close())
                progress$set(message='Loading..', value=0)

                if (is.null(GitData)) {
                    GitData <<- loadData()
                }

                progress$inc(1, detail='done.')

                if (!is.null(GitData)) {
                    selectizeInput('repos', 'Repositories:', choices=as.character(unique(GitData$Repository)), multiple=T)
                } else {
                    withTags(div(class="alert alert-danger",role="alert", span('Error loading data.'), a(onclick='javascript:window.location.reload();', href='','Refresh page.')))
                }
            })
            output$plot1 <- renderPlot({
                if (is.null(GitData)) {
                    message('No data to plot.')
                    return(ggplot())
                }

                tmp <- GitData[GitData$Repository %in% input$repos,]
                ggplot(tmp,
                       aes(Week, value, group=Repository, colour=Repository)) +
                geom_point() +
                stat_smooth(aes(fill=Repository),
                            method='glm',
                            method.args=list(family=poisson(link='log')),
                            alpha=0.3) +
                ylab('Number of commits')
            })
})
