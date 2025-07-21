/*
 * Panel: Soil Temperature
 * Dashboard: Error Flagging Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors soil temperature at two depths (0.5" and 3") with comprehensive
 *          error flagging including range validation, missing data detection, and
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
 * - $TDR315H_ST_MIN: -40 (minimum soil temperature threshold in Celsius)
 * - $TDR315H_ST_MAX: 60 (maximum soil temperature threshold in Celsius)
 * - $stddev: 2.6898 (standard deviation multiplier for outlier detection)
 * - $window: Time window for statistical calculations (minutes)
 * 
 * Data Sources:
 * - Acclima Soil.Temperature.1.1: Surface soil temperature at 0.5" depth
 * - Acclima Soil.Temperature.1.2: Subsurface soil temperature at 3" depth
 * 
 * Expected Output:
 * - time: Timestamp of measurement
 * - value: Temperature in Fahrenheit OR flag value (0/1)
 * - metric: Parameter name or flag type description
 * 
 * Temperature Conversion:
 * - Raw sensor data in Celsius converted to Fahrenheit: value * 9/5 + 32
 * - Thresholds remain in Celsius for comparison, display in Fahrenheit
 * 
 * Error Flagging Logic:
 * 1. Value Out of Range: Flags temperatures outside -40°C to 60°C range
 * 2. Missing Value: Flags timestamps where either sensor has no data
 * 3. Standard Deviation Warning: Flags statistical outliers beyond 2.6898 std dev
 * 4. Daily Operations: Flags entire days with no sensor data
 * 
 */

-- =============================================================================
-- QUERY A: Main Temperature Data and Error Flags
-- =============================================================================

(
    -- Temperature Measurements (converted to Fahrenheit)
    (
        SELECT
            "time",
            value * 9/5 + 32 AS value,  -- Convert Celsius to Fahrenheit
            measure AS "metric"
        FROM $project_key.data
        WHERE
            $__timeFilter(time)
            AND node_id = '$node'
            AND (measure ILIKE '%Acclima Soil.Temperature.1.1%' 
                 OR measure ILIKE '%Acclima Soil.Temperature.1.2%')
        ORDER BY time
    )
    
    UNION
    
    -- Value Out of Range Flags
    (
        WITH st AS (
            -- Surface temperature data (0.5" depth)
            SELECT time, value AS "st"
            FROM $project_key."data"
            WHERE $__timeFilter(time)
                AND node_id = '$node'
                AND measure = 'Acclima Soil.Temperature.1.1'
        ), 
        svwc AS (
            -- Subsurface temperature data (3" depth) 
            -- Note: Variable name 'svwc' appears to be legacy from VWC query
            SELECT time, value AS "svwc"
            FROM $project_key."data"
            WHERE $__timeFilter(time)
                AND node_id = '$node'
                AND measure = 'Acclima Soil.Temperature.1.2'
        ),
        transposed_and_flagged AS (
            -- Join both sensors and apply range checking
            SELECT 
                svwc.time, 
                join1.st, 
                join1.svwc,
                CASE
                    WHEN (join1.st < $TDR315H_ST_MIN OR
                          join1.st > $TDR315H_ST_MAX OR
                          join1.st IS NULL OR
                          svwc.svwc < $TDR315H_ST_MIN OR
                          svwc.svwc > $TDR315H_ST_MAX OR
                          svwc.svwc IS NULL) THEN 1
                    ELSE 0
                END AS range_flag
            FROM svwc
            JOIN (
                SELECT st.time, st.st, svwc.svwc 
                FROM st 
                JOIN svwc ON st.time = svwc.time
            ) AS join1 ON join1.time = svwc.time
        )
        SELECT 
            time, 
            range_flag AS value, 
            'Value Out of Range Flag' AS metric
        FROM transposed_and_flagged
        ORDER BY time
    )
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
    temp1_observations AS (
        -- Timestamps with surface temperature data
        SELECT "time" AS temp1_observation
        FROM $project_key.data
        WHERE $__timeFilter("time")
            AND data.measure = 'Acclima Soil.Temperature.1.1'
            AND node_id = '$node'
    ),
    temp2_observations AS (
        -- Timestamps with subsurface temperature data
        SELECT "time" AS temp2_observation
        FROM $project_key.data
        WHERE $__timeFilter("time")
            AND data.measure = 'Acclima Soil.Temperature.1.2'
            AND node_id = '$node'
    )
    SELECT 
        "time",
        CASE
            WHEN (temp1_observation IS NULL) THEN 1
            WHEN (temp2_observation IS NULL) THEN 1
            ELSE 0
        END AS value,
        'Missing Value Flag' AS metric
    FROM message_timestamps 
    LEFT JOIN temp1_observations ON time = temp1_observation  
    LEFT JOIN temp2_observations ON time = temp2_observation
    ORDER BY 1
)

UNION

-- Standard Deviation Warning Flags
(
    WITH std_dev_timestamps AS (
        -- Identify timestamps with statistical outliers
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
                AND (measure ILIKE '%Acclima Soil.Temperature.1.1%' 
                     OR measure ILIKE '%Acclima Soil.Temperature.1.2%')
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