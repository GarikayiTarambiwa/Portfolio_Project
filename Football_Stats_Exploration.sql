select *
from PortfolioProject..Matches


------------------------- Calculating The win Percantage for a team (Manchester United)-----------------------


WITH SumMatches AS (
    SELECT 
        season,
        COUNT(CASE 
                WHEN team1 = 'Manchester United' AND score1 > score2 THEN 1
                WHEN team2 = 'Manchester United' AND score2 > score1 THEN 1
              END) AS Wins,
        COUNT(CASE 
                WHEN team1 = 'Manchester United' AND score1 < score2 THEN 1
                WHEN team2 = 'Manchester United' AND score2 < score1 THEN 1
              END) AS Losses,
        COUNT(CASE 
                WHEN team1 = 'Manchester United' AND score1 = score2 THEN 1
                WHEN team2 = 'Manchester United' AND score2 = score1 THEN 1
              END) AS Draws
    FROM PortfolioProject..Matches
    WHERE team1 = 'Manchester United' OR team2 = 'Manchester United'
    GROUP BY season
)
SELECT 
    season,
    Wins,
    Draws,
    Losses,
    (Wins + Losses + Draws) AS Total_matches,
    CAST(Wins AS FLOAT) / CAST((Wins + Losses + Draws) AS FLOAT) * 100 AS Win_Percentage
FROM SumMatches
ORDER BY season
----------------------------------------------Average spi per season for a team (Manchester United)---------------------------------------------------------------------------------------

SELECT 
    season,
    AVG(CASE 
            WHEN team1 = 'Manchester United' THEN spi1
            WHEN team2 = 'Manchester United' THEN spi2
        END) as avg_spi
FROM PortfolioProject..Matches
WHERE team1 = 'Manchester United' OR team2 = 'Manchester United'
GROUP BY season
ORDER BY season

--------------------------------------Average Spi Per Team in The South African ABSA Premier League in 2022----------------------------------------------------------------
SELECT 
    season,
    league,
    team,
    AVG(spi) as avg_spi
FROM 
(
    SELECT season, league, team1 as team, spi1 as spi
    FROM PortfolioProject..Matches
    WHERE season = '2022' AND league = 'South African ABSA Premier League'
    UNION ALL
    SELECT season, league, team2 as team, spi2 as spi
    FROM PortfolioProject..Matches
    WHERE season = '2022' AND league = 'South African ABSA Premier League'
) as tmp
GROUP BY season, league, team
ORDER BY avg_spi DESC

---------------------------------------------------------------Highest and lowest performing teams per season---------------------------------------------------------------------------
WITH PerformanceCounts AS (
    SELECT 
        season, league,
        team1 as team, 
        performance,
        COUNT(*) as count
    FROM (
        SELECT 
            season, league,
            team1, 
            CASE 
                WHEN score1 < ROUND(xg1, 0) THEN 'Underperformed'
                WHEN score1 > ROUND(xg1, 0) THEN 'Overperformed'
                ELSE 'Met Expectation'
            END as performance
        FROM 
            PortfolioProject..Matches
        WHERE 
            xg1 IS NOT NULL
        UNION ALL
        SELECT 
            season, league,
            team2 as team, 
            CASE 
                WHEN score2 < ROUND(xg2, 0) THEN 'Underperformed'
                WHEN score2 > ROUND(xg2, 0) THEN 'Overperformed'
                ELSE 'Met Expectation'
            END as performance
        FROM 
            PortfolioProject..Matches
        WHERE 
            xg2 IS NOT NULL
    ) t
    GROUP BY season, league, team1, performance
),
PerformanceRanks AS (
    SELECT 
        season, league,
        team, 
        performance,
        count,
        ROW_NUMBER() OVER(PARTITION BY season, league, performance ORDER BY count DESC) as rank
    FROM PerformanceCounts
)
SELECT 
    season, league,
    team, 
    performance,
    count
FROM PerformanceRanks
WHERE rank = 1
ORDER BY season, league, performance