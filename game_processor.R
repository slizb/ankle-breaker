
rm(list = ls())

library(tidyr)
library(zoo)
library(sp)
library(magrittr)
library(readr)
library(dplyr)
library(stringr)
library(data.table)

source('functions.R')
source('feature_engineering.R')

csv <- c('./data/motion_data.csv')

threes <- read_csv(csv)

threes$gameid <- as.numeric(threes$gameid)

game <- unique(threes$gameid)

pbp_path <- paste0('./data/pbp_data.txt')

df <- prep_data_from_frame(threes, game)

ball_feats <- get_ball_features(df) 

dist_feats <- get_dist_features(df, pbp_path) 

# join together ball and dist feats
feats <- ball_feats %>% 
     left_join(dist_feats,
               by = c('playid' = 'playid'))
          
target <- threes %>% 
     group_by(gameid, playid) %>% 
     summarize(EVENTMSGTYPE = mode(EVENTMSGTYPE),
               PLAYER1_ID = mode(PLAYER1_ID),
               team_id = team_id[which(PLAYER1_ID == player_id)[1] ] )

feats %<>% 
     left_join(target, by = c('playid' = 'playid' ))




