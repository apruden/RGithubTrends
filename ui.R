library(shiny)
library(markdown)

shinyUI(fluidPage(
                  verticalLayout(
                                 titlePanel('RGithubTrends'),
                                 helpText('Visualize trends in commits for the top 20 starred R repositories.'),
                                 uiOutput('repoSelect'),
                                 plotOutput('plot1', width=640, height=640),
                                 includeMarkdown('documentation.md')
                                 )
                  )
)
