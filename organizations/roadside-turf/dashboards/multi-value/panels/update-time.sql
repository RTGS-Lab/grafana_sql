/*
 * Panel: Update Time
 * Dashboard: Multi-value Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors communication health across multiple sensor nodes by displaying 
 *          the most recent data transmission time and elapsed time since last contact 
 *          for each selected node. Enables quick identification of communication 
 *          failures across the network.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Table / Stat Panel
 * 
 * Variables Used:
 * - $project_key: "Roadside Turf" (project identifier)
 * - $node: Selected sensor nodes (multi-select dropdown)
 * 
 * Data Sources:
 * - Table: $project_key.data (processed sensor measurements)
 * - Field: time (timestamp of sensor readings)
 * - Scope: All measurements from selected nodes
 * 
 * Expected Output:
 * - Time: Most recent timestamp when each node transmitted data
 * - Time Since Last Heard: Seconds elapsed since last communication per node
 * - display_name: Human-readable node identifier (RST_001A, RST_002, etc.)
 * 
 * Communication Health Assessment:
 * This panel provides comparative assessment of sensor node connectivity:
 * - Recent data (< 1 hour): Normal operation for node
 * - Delayed data (1-6 hours): Potential communication issues for node
 * - Stale data (> 6 hours): Communication failure, field intervention needed
 * - Very stale data (> 24 hours): Node offline, immediate attention required
 * 
 * Multi-Node Monitoring Benefits:
 * - Network Overview: See communication status across multiple locations
 * - Comparative Analysis: Identify patterns in communication failures
 * - Prioritization: Rank nodes by communication urgency
 * - Regional Assessment: Monitor communication across geographic areas
 * - Operational Efficiency: Quick identification of multiple node issues
 * 
 * Query Logic:
 * 1. Filter to selected nodes using IN ($node) clause
 * 2. Find maximum timestamp across all sensor measurements per node
 * 3. Calculate elapsed seconds between now() and last transmission per node
 * 4. Group by display_name to get one result per node
 * 5. Exclude future timestamps (time <= now()) for data integrity
 * 
 * Time Calculation Details:
 * - now(): Current database server timestamp
 * - max(time): Most recent sensor data timestamp per node
 * - EXTRACT(EPOCH FROM ...): Converts interval to seconds
 * - GROUP BY: Ensures one result per display_name
 * - Result: Communication status summary for each selected node
 * 
 * Multi-value Dashboard Integration:
 * - Complementary to Battery panel for system health overview
 * - Network-wide communication assessment capability
 * - Quick operational status checking across multiple nodes
 * - Supports maintenance prioritization workflows
 */

-- =============================================================================
-- Multi-Node Communication Health Monitoring Query
-- =============================================================================

SELECT
    -- Most recent data transmission timestamp per node
    max(time) AS Time,
    
    -- Calculate seconds elapsed since last communication per node
    EXTRACT(EPOCH FROM (now() - max(time))) AS "Time Since Last Heard",
    
    -- Node identification for grouping and display
    display_name

FROM $project_key.data
WHERE
    -- Multi-node selection support
    node_id IN ($node)
    
    -- Exclude any future timestamps (data quality check)
    AND time <= now()

-- Group by node to get one result per selected node
GROUP BY data.display_name
ORDER BY time ASC;

