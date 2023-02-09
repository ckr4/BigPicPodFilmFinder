library(shiny)
library(pins)
library(stringr)

# register github board to retreive pinned data
board_register_github(repo="ckr4/BigPicPodFilmFinder", token="")

# retrieve dictionaries from github pin
ep_name_dict <- pin_get("ep-name-dict", board="github")
ep_movie_dict <- pin_get('ep-movie-dict', board='github')
ep_title_dict <- pin_get('ep-title-dict', board='github')
ep_link_dict <- pin_get('ep-link-dict', board='github')
ep_ad_dict <- pin_get('ep-ad-dict', board='github')

# create sorted lists for drop down selections
ep_title_list <- sort(names(ep_title_dict))
ep_ad_list <- sort(names(ep_ad_dict))

# create label/value pairs for drop down selections
# ---> needed to set in server instead of UI 
# ---> setting in server due to size of m and ad lists
m_choices <- data.frame(label=c("", ep_title_list), 
                      value=c("", ep_title_list))
ad_choices <- data.frame(label=c("", ep_ad_list),
                         value=c("", ep_ad_list))
ep_choices <- data.frame(label=c('Movie Draft', 'Movie Auction', 'Hall of Fame'),
                         value=c('Movie Draft', 'Movie Auction', 'Hall of Fame'))

matches = c()

ui <- fluidPage(
          
          tags$head(
            tags$style(HTML("
              @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;700&display=swap');
              
              * {
                margin: 4;
                padding: 4;
                box-sizing: border-box;
                font-family: 'Poppins', sans-serif;
                #color: #deece7;
                background-color: #0b2f21;
              }
            "))
          ),
          tags$style(HTML("
            .filmstrip {
              --background: rgba(0, 0, 0, .35);
              --size: 10px;
              background-image:
                linear-gradient(to right, var(--background) var(--size), transparent var(--size)),
                linear-gradient(to bottom, var(--background) var(--size), transparent var(--size)),
                linear-gradient(to right, var(--background) var(--size), transparent var(--size)),
                linear-gradient(to bottom, var(--background) var(--size), transparent var(--size)),
                linear-gradient(to bottom, transparent var(--size), var(--background) var(--size));
                background-size: calc(var(--size) * 2) var(--size), calc(var(--size) * 2) var(--size), calc(var(--size) * 2) var(--size), calc(var(--size) * 2) var(--size), 100% calc(100% - var(--size) * 3);
                background-repeat: repeat-x;
                background-position: 0 var(--size), top left, 0 calc(100% - var(--size)), bottom left, 0 var(--size);
                padding: calc(var(--size) * 3) calc(var(--size) * 2.5);
                box-sizing: border-box;
            }

            h1 {
              margin: 0;
              padding: 8px 0px;
              line-height: 1;
              text-align: center;
              font-size: 1.15em;
              color: #efd047;
              background-color: transparent;
            }      
        
            h3 {
              margin: 0;
              padding: 5px 0px;
              line-height: 1;
              text-align: center;
              font-size: .7em;
              #color: #deece7;
              background-color: transparent;
            }
          ")),
          titlePanel(HTML("<div class='filmstrip'><h1>The Big Picture Podcast Film Finder</h1><h3>Search and filter every* episode of your favorite podcast</h3></div>"),
                     windowTitle = 'The Big Picture Podcast Film Finder'),
          fluidRow( 
            column(6, align='right',
              wellPanel(id="wp_left",
                tags$style(HTML("
                  #wp_left {
                    border-width: 0px;
                    background-color: #0b2f21;
                    text-align: center;
                    max-width: 400px;
                    margin-right: 5%;
                  }
                  h4 {
                    margin: 0px 0px 00px 0px;
                    padding: 0px 0px 0px 0px;
                    line-height: 1;
                    text-align: center;
                    font-size: 1.3em;
                    #color: #deece7;
                    background-color: transparent;
                  }
                ")),
                htmlOutput("cat_txt"),
                selectInput("cat_sel",
                            "",
                            choices=c('Movie', 'Actor/Director', 'Episode Type')
                ),
                tags$style(HTML("
                      div {
                        height: 1 vh;
                        color: #deece7;
                      }
                  ")
                )
              )
            ),
            column(6, align='left',
              wellPanel(id="wp_right",
                tags$style(HTML("
                  #wp_right {
                    border-width: 0px;
                    background-color: #0b2f21;
                    text-align: center;
                    max-width: 400px;
                    margin-left: 5%;
                  }
                  h4 {
                    margin: 0;
                    padding: 0px 0px 0px 0px;
                    line-height: 1;
                    text-align: center;
                    font-size: 1.3em;
                    #color: #deece7;
                    background-color: transparent;
                  }
                ")),
                htmlOutput("tip"),
                tags$style(HTML("
                    .circle {
                      border-radius: 50%;
                      width: 34px;
                      height: 34px;
                      padding: 5px 10px 10px 10px;
                      margin-top: 0px;
                      background: #071f16;
                      border: 2px solid #efd047;
                      color: #efd047;
                      text-align: center;
                      font-weight: bold;
                      font-size: 20px;
                      position: relative;
                      display: inline-block;
                    }         
      
                    /* Tooltip text */
                    .circle .tooltiptext {
                        visibility: hidden;
                        width: 225px;
                        background-color: #efd047;
                        color: #071f16;
                        text-align: center;
                        font-weight: normal;
                        font-size: 16px;
                        padding: 5px 0;
                        border-radius: 6px;
                        top: -160%;
                        right: -350%;
                        padding: 4px;
                        
         
                    /* Position the tooltip text */
                        position: absolute;
                        z-index: 1;
                        }
        
                    /* Show the tooltip text when you mouse over the tooltip container */
                    .circle:hover .tooltiptext {
                        visibility: visible;
                        }
                    ")),
                selectizeInput("search_sel",
                               "",
                               choices=NULL
                ),
                tags$style(HTML("
                      div {
                        height: 1 vh;
                        color: #deece7;
                      }
                      .selectize-dropdown-content .option {
                        color: black;
                        background-color: white;
                        height: 22px;
                        line-height: 1;
                        font-size: 16px;
                        text-align: left;
                      }
                      .selectize-dropdown .active {
                        background-color: white;
                        color: black;
                      }
                      .selectize-dropdown-content .option:hover {
                        background: #0b2f21;
                        color: white;
                      }
                      .selectize-input {
                        height: 22px;
                        text-align: left;
                        font-size: 17px;
                        margin: 0px 10px 0px 0px;
                        padding-top: 7px;
                        padding-bottom: 0px;
                      }
                      .selectize-dropdown [data-selectable] .highlight {
                        background: #efd047; 
                        color: black;
                      }
                      .selectize-dropdown .active:not(.selected){
                        background: #efd047;
                        color: black;
                      }
                    ")
                    )
                )
              )
            ),
            fluidRow(id="frBottom",
              column(1),
              column(2, align='center',
                htmlOutput("mats"),
              ),
              column(6, align='center',
                tags$style(HTML("
                  table {
                    border-collapse: separate;
                    border-spacing: 12px 0px;
                    font-size: 16px;
                    }
                  a{
                    color: #efd047;
                    }
                  a:visited {
                    color: #b69814;
                    }
                  a:hover {
                    color: white;
                    }
                ")),
                htmlOutput("res")
              ),
              tags$style(HTML("
                #frBottom {
                  font-size: 16px;
                }
              "))
            ),
            br(),
            htmlOutput("thru"),
            tags$style(HTML("
                #thru {
                  text-align: center;
                  font-size: 1em;
                  color: #efd047;
                }
            "))
            
)

server <- function(input, output, session) {
  
  showModal(modalDialog(title = "An unofficial guide to an unofficial tool",
                        size="m",
                        fade=TRUE,
                        footer=NULL,
                        easyClose = TRUE,
                        tags$style(HTML("
                          .modal-header {
                            color: #efd047 !important;
                            font-size: 1.5em;
                          }
                        ")),
                        HTML("<p>The Big Picture Podcast Film Finder is not affiliated with 
                                  The Big Picture, The Ringer, Spotify or any other organization,
                                  corporation, association, institution, syndicate, concern,
                                  company, sewing circle or book club.</p>"),
                        HTML("<p>This tool uses simple text matching to find the titles of
                                  movies or names of actors and directors in the transcripts of The 
                                  Big Picture podcast that are available on Spotify. Movie titles
                                  are taken from Wikipedia's list of films, which is extensive, 
                                  yet incomplete. The transcripts, though very good, are not 
                                  perfect. The list of actors and directors is taken from
                                  Wikipedia's lists of actors and directors who have been nominated
                                  for an Academy Award, and is thus limited to a small subset of all
                                  actors. </p>"),
                        HTML("<p>Note: Movie titles that consist of common words are likely to give 
                                  inaccurate results (e.g. 'The One'), as will titles that are 
                                  contained in other movie titles (e.g. 'Twelve', which will produce 
                                  results for 'Twelve Months', 'Twelve Monkeys' and 'Ocean's Twelve')."),
                        HTML("<p>Any other issues that arise are almost certainly my fault, and well, 
                                  sorry I guess?</p>"),
                        hr(),
                        fluidRow(id="frmb",
                          column(3),
                          column(6, align='center',
                            actionButton("close_mod", "Got it", width='100%')
                          ),
                          column(3),
                          tags$style(HTML("
                            #frmb {
                              width: 100%;
                              margin: auto;
                            }                
                          "))
                        )
    )
  )
  
  observeEvent(input$close_mod, {
    removeModal()
  })
  
  updateSelectizeInput(session, "search_sel", choices=m_choices, server=TRUE, selected=character(0)) 
  
  observeEvent(input$cat_sel, {
    if (input$cat_sel == 'Episode Type') {
      updateSelectizeInput(session, "search_sel", choices=ep_choices, server=TRUE, selected=character(0))
    } else if (input$cat_sel == 'Movie') {
      updateSelectizeInput(session, "search_sel", choices=m_choices, server=TRUE, selected=character(0))
    } else if (input$cat_sel == 'Actor/Director') {
      updateSelectizeInput(session, "search_sel", choices=ad_choices, server=TRUE, selected=character(0))
    }
  })
  
  output$cat_txt <- renderUI({
    HTML(paste0("<h4>Choose a category&nbsp&nbsp<div class='circle'>i<span class='tooltiptext'>",
                "Lists may take a moment to load. Please be patient.</span></div></h4>"))
  })
  
  output$tip <- renderUI({
    HTML(paste0("<h4>Type to search&nbsp&nbsp<div class='circle'>i<span class='tooltiptext'>",
                "Lists exclude choices that produce no results</span></div></h4>"))
  })
  
  output$thru <- renderUI({
    HTML(paste0("<div style=color:#efd047; text-align: center;>* Through episode #", 
                ep_name_dict[length(ep_name_dict$episode),1]))
                # "<br>** From Wikipedia's ",
                # "<a href=https://en.wikipedia.org/wiki/Lists_of_films target='_blank'>",
                # "list of films</div>")
  })
          
  observeEvent(input$search_sel, {
    if (input$cat_sel == 'Movie') {
      matches <- unlist(ep_title_dict[which(names(ep_title_dict)==input$search_sel)])
      output$mats <- renderUI({
        mats = ""
        if (length(matches) > 0) {
          mats = "<div><table style=text-align:center; margin-right: 8%;
                      margin-left: auto;><tr><td>Potential matches</td></tr>"
          for (i in 1:length(matches)) {
            mats = paste0(mats, "<tr><td>", matches[i], "</td></tr>")
          }
          mats = paste0(mats, "</table></div>")
        }
        HTML(mats)
      })
      output$res <- renderText({
        raw_results <- unlist(ep_movie_dict[which(names(ep_movie_dict)==input$search_sel)])
        results <- sort(as.numeric(raw_results))
        linked_res = ""
        if (length(results) > 0) {
          linked_res = "<div><table><tr><td>Ep.</td><td>Title</td></tr>"
          for (i in 1:length(results)) {
            linked_res <- paste0(linked_res, "<tr><td>", results[i], "</td>", "<td><a href=",
                                 ep_link_dict[which(ep_link_dict$episode==results[i]), 2],
                                 " target='_blank'>",
                                 ep_name_dict[which(ep_name_dict$episode==results[i]), 2],
                                 "</a></td></tr>")
          }
          linked_res = paste0(linked_res, "</table></div>")
        }
        HTML(linked_res)
      })
      } else if (input$cat_sel == 'Episode Type') {
        output$mats <- renderUI({
          mats = ""
          HTML(mats)
        })
        output$res <- renderText({
          linked_res = ""
          if (input$search_sel != ""){
            results <- ep_name_dict[which(str_detect(ep_name_dict$name, input$search_sel)), 1]
              if (length(results) > 0) {
                linked_res = "<div><table><tr><td>Ep.</td><td>Title</td></tr>"
                for (i in 1:length(results)) {
                  linked_res <- paste0(linked_res, "<tr><td>", results[i], "</td>", "<td><a href=",
                                       ep_link_dict[which(ep_link_dict$episode==results[i]), 2],
                                       " target='_blank'>",
                                       ep_name_dict[which(ep_name_dict$episode==results[i]), 2],
                                       "</a></td></tr>")
                }
                linked_res = paste0(linked_res, "</table></div>")
              }
          } 
          HTML(linked_res)
        })
      } else if (input$cat_sel == 'Actor/Director') {
        output$mats <- renderUI({
          mats = ""
          HTML(mats)
        })
        output$res <- renderText({
          linked_res = ""
          if (input$search_sel != ""){
            raw_results <- unlist(ep_ad_dict[which(names(ep_ad_dict)==input$search_sel)])
            results <- sort(as.numeric(raw_results))
            if (length(results) > 0) {
              linked_res = "<div><table><tr><td>Ep.</td><td>Title</td></tr>"
              for (i in 1:length(results)) {
                linked_res <- paste0(linked_res, "<tr><td>", results[i], "</td>", "<td><a href=",
                                     ep_link_dict[which(ep_link_dict$episode==results[i]), 2],
                                     " target='_blank'>",
                                     ep_name_dict[which(ep_name_dict$episode==results[i]), 2],
                                     "</a></td></tr>")
              }
              linked_res = paste0(linked_res, "</table></div>")
            }
          } 
          HTML(linked_res)
        })
      }
    })
            
}

shinyApp(ui = ui, server = server)
