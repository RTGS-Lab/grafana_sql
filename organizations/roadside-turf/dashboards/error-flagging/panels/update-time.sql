/*
 * Panel: Update (Last Communication Time)
 * Dashboard: Error Flagging Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors sensor node communication health by displaying the most
 *          recent data transmission time and calculating elapsed time since
 *          last contact. Critical for identifying communication failures.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Stat Panel
 * 
 * Variables Used:
 * - $project_key: "Roadside Turf" (project identifier)
 * - $node: Selected sensor node ID (dropdown of 11 roadside locations)
 * 
 * Data Sources:
 * - Table: $project_key.data (processed sensor measurements)
 * - Field: time (timestamp of sensor readings)
 * - Scope: All measurements from selected node
 * 
 * Expected Output:
 * - Time: Most recent timestamp when node transmitted data
 * - Time Since Last Heard: Seconds elapsed since last communication
 * 
 * Communication Health Monitoring:
 * This panel provides real-time assessment of sensor node connectivity:
 * - Recent data (< 1 hour): Normal operation
 * - Delayed data (1-6 hours): Potential communication issues
 * - Stale data (> 6 hours): Communication failure, field intervention needed
 * - Very stale data (> 24 hours): Node offline, immediate attention required
 * 
 * Key Differences from Other System Panels:
 * - Battery/SoC: Power system health from diagnostic messages
 * - Update: Communication health from sensor data timestamps
 * - Location: Geographic positioning for field operations
 * - All three provide system monitoring vs environmental measurement
 * 
 * Query Logic:
 * 1. Find maximum timestamp across all sensor measurements for node
 * 2. Calculate elapsed seconds between now() and last transmission
 * 3. Exclude future timestamps (time <= now()) for data integrity
 * 4. Single row result for stat panel display
 * 
 * Time Calculation Details:
 * - now(): Current database server timestamp
 * - max(time): Most recent sensor data timestamp
 * - EXTRACT(EPOCH FROM ...): Converts interval to seconds
 * - Result: Positive integer representing seconds of silence
 * 
 */

-- =============================================================================
-- Communication Health Monitoring Query
-- =============================================================================

SELECT
    -- Most recent data transmission timestamp
    max(time) AS Time,
    
    -- Calculate seconds elapsed since last communication
    EXTRACT(EPOCH FROM (now() - max(time))) AS "Time Since Last Heard"

FROM $project_key.data
WHERE
    node_id = '$node'
    AND time <= now()  -- Exclude any future timestamps (data quality check)
ORDER BY 1;
