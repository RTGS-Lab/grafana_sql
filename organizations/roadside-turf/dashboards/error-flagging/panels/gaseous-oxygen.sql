/*
 * Panel: Gaseous Oxygen
 * Dashboard: Error Flagging Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors soil gaseous oxygen concentration at 2" depth with error 
 *          flagging including range validation, missing data detection, and 
 *          statistical outlier identification.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Time Series Graph
 * 
 * Variables Used:
 * - $project_key: "Roadside Turf" (project identifier)
 * - $__timeFilter: Grafana time range filter function
 * - $node: Selected sensor node ID (dropdown of 11 roadside locations)
 * - $Apogee_SO421_MIN: 0 (minimum oxygen percentage threshold)
 * - $Apogee_SO421_MAX: 100 (maximum oxygen percentage threshold)
 * - $stddev: 2.6898 (standard deviation multiplier for outlier detection)
 * - $window: Time window for statistical calculations (minutes)
 * 
 * Data Sources:
 * - Apogee O2.Oxygen_%.1.4: Gaseous oxygen concentration at 2" depth
 * 
 * Expected Output:
 * - time: Timestamp of measurement
 * - value: Oxygen percentage OR flag value (0/1)
 * - metric: Parameter name or flag type description
 * 
 * Error Flagging Logic:
 * 1. Value Out of Range: Flags O₂ outside 0-100% range + NULL values
 * 2. Missing Value: Flags timestamps where oxygen sensor has no data
 * 3. Standard Deviation Warning: Flags statistical outliers beyond 2.6898 std dev
 * 4. Daily Operations: Flags entire days with no sensor data
 *
 */

-- =============================================================================
-- QUERY A: Main Oxygen Data and Error Flags
-- =============================================================================

(
    -- Oxygen Measurements and Range Flags (combined approach)
    (
        -- Raw oxygen percentage measurements
        SELECT
            "time",
            value,  -- Oxygen percentage (no conversion needed)
            measure AS "metric"
        FROM $project_key.data
        WHERE
            $__timeFilter(time)
            AND node_id = '$node'
            AND (measure = 'Apogee O2.Oxygen_%.1.4')
        ORDER BY time
    )
    
    UNION
    
    -- Value Out of Range Flags (simplified single-sensor approach)
    SELECT
        "time" AS "time",
        CASE
            WHEN (value IS NULL) THEN 1
            WHEN (measure = 'Apogee O2.Oxygen_%.1.4' AND 
                  (value < $Apogee_SO421_MIN OR value > $Apogee_SO421_MAX)) THEN 1
            ELSE 0
        END AS value,
        'Value Out Of Range Flag' AS metric
    FROM $project_key.data
    WHERE
        $__timeFilter("time")
        AND node_id = '$node'
        AND (measure = 'Apogee O2.Oxygen_%.1.4')
    ORDER BY 1
)

UNION

-- Missing Value Flags
(
    WITH message_timestamps AS (
        -- Get all timestamps where any data was recorded for this node
        SELECT DISTINCT "time" AS "time"
        FROM $project_key.data
        WHERE $__timeFilter("time")
            AND node_id = '$node'
            AND measure NOT ILIKE 'altitude'
            AND measure NOT ILIKE 'latitude'
            AND measure NOT ILIKE 'longitude'
        ORDER BY 1
    ), 
    apo2_observations AS (
        -- Timestamps with oxygen sensor data
        SELECT "time" AS apo2_observation
        FROM $project_key.data
        WHERE $__timeFilter("time")
            AND data.measure = 'Apogee O2.Oxygen_%.1.4'
            AND node_id = '$node'
    )
    SELECT 
        "time",
        CASE
            WHEN (apo2_observation IS NULL) THEN 1
            ELSE 0
        END AS value,
        'Missing Value Flag' AS metric
    FROM message_timestamps 
    LEFT JOIN apo2_observations ON time = apo2_observation
    ORDER BY 1
)

UNION

-- Standard Deviation Warning Flags
(
    WITH std_dev_timestamps AS (
        -- Identify timestamps with oxygen statistical outliers
        SELECT DISTINCT "time" AS std_dev_timestamp
        FROM (
            SELECT
                "time",
                value,
                AVG(value) OVER w AS _avg,
                STDDEV(value) OVER w AS _stddev,
                measure
            FROM $project_key.data
            WHERE $__timeFilter(time)
                AND node_id = '$node'
                AND (measure = 'Apogee O2.Oxygen_%.1.4')
            WINDOW w AS (
                PARTITION BY measure, time_bucket(INTERVAL '$window minutes', "time")
            )
            ORDER BY time
        ) AS d
        WHERE ABS(value - _avg) > (('$stddev')::numeric * _stddev)
    ),
    message_timestamps AS (
        -- All data timestamps for this node
        SELECT DISTINCT "time" AS "time"
        FROM $project_key.data
        WHERE $__timeFilter("time")
            AND node_id = '$node'
            AND measure NOT ILIKE 'altitude'
            AND measure NOT ILIKE 'latitude'
            AND measure NOT ILIKE 'longitude'
        ORDER BY 1
    )
    SELECT 
        "time",
        CASE
            WHEN (std_dev_timestamp IS NULL) THEN 0
            ELSE 1
        END AS value,
        'Standard Deviation Warning Flag' AS metric
    FROM message_timestamps 
    LEFT JOIN std_dev_timestamps ON "time" = std_dev_timestamp
    ORDER BY 1
)
ORDER BY 1;

-- =============================================================================
-- QUERY B: Daily Operations Flag
-- =============================================================================

WITH operating_days AS (
    -- Days with any recorded data
    SELECT DISTINCT date_trunc('day', time) AS operating_day
    FROM $project_key.data
    WHERE $__timeFilter("time") 
        AND node_id = '$node'
    ORDER BY 1
), 
range_days AS (
    -- All days in selected time range
    SELECT range_day
    FROM generate_series(
        '${__from:date:YYYY-MM-DD}'::date, 
        '${__to:date:YYYY-MM-DD}'::date, 
        '1 day'
    ) AS range_day
    ORDER BY 1
)
SELECT
    range_day AS time,
    CASE 
        WHEN (operating_day IS NULL) THEN 1
        ELSE 0
    END AS "Daily Operations Flag"
FROM range_days 
LEFT JOIN operating_days ON range_day = operating_day
ORDER BY range_day;