
FIRST QUERY:

 WITH SEA_MAXSAL AS
((SELECT SEASON, TEAM  
FROM SALARY)
MINUS
(SELECT S1.SEASON, S1.TEAM
FROM SALARY S1, SALARY S2
WHERE S1.SEASON=S2.SEASON AND S1.TOTAL_SALARY<S2.TOTAL_SALARY)),
SEA_CHAM AS (
  SELECT SEASON, NBA_CHAMPION 
  FROM FINAL_AND_MVP),
SEA_MSTEAM_CTEAM AS
(SELECT SEA_MAXSAL.SEASON, SEA_MAXSAL.TEAM MAXSAL_TEAM, NBA_CHAMPION
FROM SEA_MAXSAL, SEA_CHAM
WHERE SEA_MAXSAL.SEASON=SEA_CHAM.SEASON)
SELECT TRUNC(N1/N2,4) P_OF_MAXSALARYTEAM_WIN_CHAMPION, TRUNC(1/N2,4) P_OF_A_RANDOMTEAM_WIN_CHAMPION
FROM (SELECT COUNT(*) N1 FROM SEA_MSTEAM_CTEAM WHERE MAXSAL_TEAM=NBA_CHAMPION), 
  (SELECT COUNT(*) N2 FROM SEA_MSTEAM_CTEAM);

(The first query is the probability of the team that has the
 most total salary of players winning the championship and the probability
 of a random team winning the championship)



SECOND QUERY:
  
 
WITH BACK_GAMES_INFO AS (
SELECT * FROM(
  SELECT BACKTOBACK_GAMES.TEAM_ABBREVIATION, BACKTOBACK_GAMES.G1_ID,GID_TEAM_AVAGE_1.AVG_AGE G1_AVG_AGE,G1_DATE,G1_WL,
    BACKTOBACK_GAMES.G2_ID,GID_TEAM_AVAGE_2.AVG_AGE G2_AVG_AGE,G2_DATE,G2_WL
  FROM(
    SELECT DISTINCT GAME_ID, TEAM_ABBREVIATION, TRUNC(AVG(AGE),2) AVG_AGE
    FROM (
    SELECT DISTINCT GAME_ID, TEAM_ABBREVIATION,PLAYER_NAME, 
      TRUNC(months_between(GAME_DATE, BIRTH_DATE)/12,2) AGE
    FROM PLAYER_DATA,(SELECT DISTINCT GAME_ID, TEAM_ABBREVIATION, PLAYER_NAME, GAME_DATE FROM PLAY)
    WHERE PLAYER_DATA.NAME=PLAYER_NAME AND PLAYER_DATA.BIRTH_DATE IS NOT NULL AND GAME_DATE IS NOT NULL) 
    GROUP BY GAME_ID, TEAM_ABBREVIATION)  GID_TEAM_AVAGE_1, (
    SELECT DISTINCT GAME_ID, TEAM_ABBREVIATION, TRUNC(AVG(AGE),2) AVG_AGE
    FROM (
      SELECT DISTINCT GAME_ID, TEAM_ABBREVIATION,PLAYER_NAME, 
        TRUNC(months_between(GAME_DATE, BIRTH_DATE)/12,2) AGE
      FROM PLAYER_DATA,(SELECT DISTINCT GAME_ID, TEAM_ABBREVIATION, PLAYER_NAME, GAME_DATE FROM PLAY)
      WHERE PLAYER_DATA.NAME=PLAYER_NAME AND PLAYER_DATA.BIRTH_DATE IS NOT NULL AND GAME_DATE IS NOT NULL) 
    GROUP BY GAME_ID, TEAM_ABBREVIATION) GID_TEAM_AVAGE_2, (
      SELECT DISTINCT P1.TEAM_ABBREVIATION,P1.GAME_DATE G1_DATE, P1.GAME_ID G1_ID, 
        P2.GAME_ID G2_ID, P2.GAME_DATE G2_DATE, P1.WL G1_WL,P2.WL G2_WL
        FROM PLAY P1, PLAY P2
        WHERE P2.GAME_DATE=P1.GAME_DATE+1 AND P1.TEAM_ABBREVIATION=P2.TEAM_ABBREVIATION) BACKTOBACK_GAMES
  WHERE GID_TEAM_AVAGE_1.GAME_ID=BACKTOBACK_GAMES.G1_ID AND GID_TEAM_AVAGE_2.GAME_ID=BACKTOBACK_GAMES.G2_ID AND
   GID_TEAM_AVAGE_1.TEAM_ABBREVIATION=BACKTOBACK_GAMES.TEAM_ABBREVIATION AND 
   GID_TEAM_AVAGE_2.TEAM_ABBREVIATION=BACKTOBACK_GAMES.TEAM_ABBREVIATION 
   )
   )
SELECT T1.TEAM_ABBREVIATION, BACKTOBACK_GNUM, G1_AVG_AGE, G2_AVG_AGE, G1_WIN_NUM, G2_WIN_NUM FROM   
(SELECT TEAM_ABBREVIATION, COUNT(G1_ID) BACKTOBACK_GNUM, TRUNC(AVG(G1_AVG_AGE),1) G1_AVG_AGE, TRUNC(AVG(G2_AVG_AGE),1) G2_AVG_AGE
FROM BACK_GAMES_INFO
  GROUP BY TEAM_ABBREVIATION) T1,(
    SELECT TEAM_ABBREVIATION,COUNT(G1_ID) G1_WIN_NUM FROM  BACK_GAMES_INFO WHERE G1_WL='W'
    GROUP BY TEAM_ABBREVIATION) T2,(
    SELECT TEAM_ABBREVIATION,COUNT(G1_ID) G2_WIN_NUM FROM  BACK_GAMES_INFO WHERE G2_WL='W'
    GROUP BY TEAM_ABBREVIATION ) T3
WHERE T1.TEAM_ABBREVIATION=T2.TEAM_ABBREVIATION AND T2.TEAM_ABBREVIATION=T3.TEAM_ABBREVIATION;



THIRD QUERY:
SELECT * FROM 
(SELECT TRUNC(pts_off-pts_nor,1) as difference ,TRUNC(pts_off,1) as off,TRUNC(pts_nor,1) as nor, n_1 as name FROM 
(SELECT avg(pts) as pts_nor,player_name as n_1 FROM 
play 
where season_type='Regular Season' 
group by player_name
having avg(pts)>20
order by pts_nor desc)
inner join
(SELECT avg(pts) as pts_off,player_name as n_2 FROM 
play 
where season_type='Playoffs'
group by player_name
order by pts_off desc)
on n_2=n_1
order by pts_off-pts_nor desc)
where rownum<=9


FOURTH QUERY:
SELECT *
                  FROM (select season as s_h,avg(pts) as pts_h
                  from 
                  play
                  INNER JOIN 
                  player_data1
                  ON play.player_name=player_data1.player
                  where player_data1.collage is null 
                  group by season
                  order by season)
                  inner join
                  (select season as s_c,avg(pts) as pts_c
                  from 
                  play
                  INNER JOIN 
                  player_data1
                  ON play.player_name=player_data1.player
                  where player_data1.collage is not null 
                  group by season
                  order by season)
                  on s_c=s_h


FIFTH QUERY: 

select *
             from (select TRUNC(AVG(PTS),2) as pts_k,season as s_l,player_name as n_k 
             from play
             where (player_name='Kobe Bryant' )
             and (season>2002 and season<2011)
             GROUP BY SEASON,player_name
             ORDER BY SEASON) 
             INNER JOIN 
             (select TRUNC(AVG(PTS),2) as pts_l,season as s_k,player_name as n_l 
             from play
             where (player_name='LeBron James' )
             and (season>2002 and season<2011)
             GROUP BY SEASON,player_name
             ORDER BY SEASON)
             ON s_l=s_k
             INNER JOIN 
             (select TRUNC(AVG(PTS),2) as pts_d,season as s_d,player_name as n_l 
             from play
             where (player_name='Dwyane Wade' )
             and (season>2002 and season<2011)
             GROUP BY SEASON,player_name
             ORDER BY SEASON)
             ON s_l=s_d



SIXTH QUERY:

SELECT * FROM 
(SELECT birth_state ,COUNT(*) as champion_player
FROM 
(SELECT
   distinct play.player_name,player_data1.birth_state
FROM 
(play
inner join
final_and_mvp
on play.season=final_and_mvp.season)
inner join
player_data1
on player_data1.player=play.player_name
where final_and_mvp.nba_champion=play.team_abbreviation
order by play.player_name)
GROUP BY birth_state
order by champion_player desc)
where rownum<=10
  
   
   

   





  
 





  



  





