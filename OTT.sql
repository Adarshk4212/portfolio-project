SELECT COUNT(*) FROM ott_viewer_retention

-- Basic Data Validation
SELECT COUNT(*) FROM ott_viewer_retention WHERE drop_off NOT IN (0,1);
SELECT COUNT(*) FROM ott_viewer_retention WHERE drop_off IS NULL;
SELECT COUNT(*) FROM ott_viewer_retention WHERE episode_duration_min < 10;

DELETE FROM ott_viewer_retention
WHERE drop_off IS NULL OR episode_duration_min < 10;

DELETE FROM ott_viewer_retention
WHERE drop_off IS NULL;

CREATE VIEW ott_analysis AS
SELECT *,
    CASE
        WHEN cognitive_load <= 4 THEN 'Low'
        WHEN cognitive_load <= 7 THEN 'Medium'
        ELSE 'High'
    END AS cognitive_level,

    CASE
        WHEN hook_strength <= 2 THEN 'Weak'
        WHEN hook_strength = 3 THEN 'Medium'
        ELSE 'Strong'
    END AS hook_level,

    CASE
        WHEN episode_duration_min < 30 THEN 'Short'
        WHEN episode_duration_min <= 45 THEN 'Medium'
        ELSE 'Long'
    END AS duration_group,

    CASE
        WHEN pause_count <= 3 THEN 'Low Pause'
        WHEN pause_count <= 7 THEN 'Medium Pause'
        ELSE 'High Pause'
    END AS pause_intensity
FROM ott_viewer_retention;

SELECT * FROM ott_analysis LIMIT 5;

-- Drop-off by Cognitive Load
SELECT cognitive_level,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate
FROM ott_analysis
GROUP BY cognitive_level
ORDER BY drop_off_rate DESC;

-- Drop-off by Hook Strength
SELECT hook_level,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate
FROM ott_analysis
GROUP BY hook_level;

-- Pause Behavior vs Drop-off
SELECT pause_intensity,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate
FROM ott_analysis
GROUP BY pause_intensity;

-- Avg Watch % vs Cognitive Load
SELECT cognitive_level,
       ROUND(AVG(avg_watch_percentage),2) AS avg_watch_pct
FROM ott_analysis
GROUP BY cognitive_level;

-- Dialogue Density vs Drop-off
SELECT dialogue_density,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate
FROM ott_analysis
GROUP BY dialogue_density
ORDER BY dialogue_density;

-- MOST VIEWED TITLES (BY WATCH %)
SELECT title,
       ROUND(AVG(avg_watch_percentage),2) AS avg_watch_pct,
       COUNT(*) AS total_episodes
FROM ott_analysis
GROUP BY title
ORDER BY avg_watch_pct DESC
LIMIT 10;

-- TITLES WITH HIGHEST DROPOFF (RISKY CONTENT)
SELECT title,platform,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate
FROM ott_analysis
GROUP BY title,platform
ORDER BY drop_off_rate DESC
LIMIT 10;

-- GENRE PERFORMANCE ANALYSIS
SELECT genre,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate,
       ROUND(AVG(avg_watch_percentage),2) AS avg_watch_pct
FROM ott_analysis
GROUP BY genre
ORDER BY drop_off_rate;

-- PLATFORM COMPARISON (IMPORTANT)
SELECT platform,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate,
       ROUND(AVG(avg_watch_percentage),2) AS avg_watch_pct
FROM ott_analysis
GROUP BY platform 
ORDER BY drop_off_rate  DESC;

-- EPISODE NUMBER vs DROPOFF (VERY INSIGHTFUL)
SELECT  episode_number,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate
FROM ott_analysis
GROUP BY episode_number
ORDER BY episode_number;

-- ATTENTION REQUIRED vs DROPOFF
SELECT attention_required,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate
FROM ott_analysis
GROUP BY attention_required;

-- NIGHT WATCH SAFETY ANALYSIS
SELECT night_watch_safe,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate
FROM ott_analysis
GROUP BY night_watch_safe;

-- HIGH-RISK EPISODES (ACTIONABLE LIST)
SELECT title,
       season_number,
       episode_number,
       drop_off_probability,
       retention_risk
FROM ott_analysis
WHERE retention_risk = 'High'
ORDER BY drop_off_probability DESC
LIMIT 20;

-- STRONG HOOK BUT HIGH DROPOFF (CONTENT PROBLEM)
SELECT title,
       ROUND(AVG(drop_off)*100,2) AS drop_rate
FROM ott_analysis
WHERE hook_level = 'Strong'
GROUP BY title
HAVING drop_rate > 30;

-- TOP 10 BEST-PERFORMING EPISODES
SELECT title,
       season_number,
       episode_number,
       avg_watch_percentage,
       drop_off_probability,cognitive_load,hook_strength
FROM ott_analysis
ORDER BY avg_watch_percentage DESC
LIMIT 10;

-- PLATFORM × BEHAVIOR SIGNALS
SELECT platform,
       pause_intensity,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate
FROM ott_analysis
GROUP BY platform, pause_intensity
ORDER BY platform;

-- PLATFORM × RETENTION RISK DISTRIBUTION
SELECT platform,
       retention_risk,
       COUNT(*) AS episode_count
FROM ott_analysis
GROUP BY platform, retention_risk
ORDER BY platform;

-- BEST & WORST PLATFORMS (SUMMARY QUERY)
SELECT platform,
       ROUND(AVG(avg_watch_percentage),2) AS avg_watch_pct,
       ROUND(AVG(drop_off)*100,2) AS drop_off_rate
FROM ott_analysis
GROUP BY platform
ORDER BY avg_watch_pct DESC;


