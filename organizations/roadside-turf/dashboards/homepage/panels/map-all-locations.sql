/*
 * Panel: Map - All Locations
 * Dashboard: Homepage Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Displays geographic visualization of the complete sensor network showing 
 *          all 11 roadside turf monitoring stations across Minnesota with their 
 *          most recent GPS coordinates for network overview and field operations.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Map Panel
 * 
 * Transforms:
 * 1. Prepare time series - Format: Wide time series
 * 2. Join by labels
 * 
 * Variables Used:
 * - $project_key: "Roadside Turf" (project identifier)
 * 
 * Data Sources:
 * - Longitude: GPS longitude coordinates for all nodes
 * - Latitude: GPS latitude coordinates for all nodes
 * - display_name: Human-readable node identifiers (RST_001A, RST_002, etc.)
 * - node_id: Unique sensor node identifiers
 * 
 * Expected Output:
 * - time: Timestamp of most recent GPS reading per node
 * - node_id: Sensor node identifier
 * - display_name: Human-readable node name
 * - metric: "Longitude" or "Latitude"
 * - value: Coordinate value in decimal degrees
 * 
 * Query Logic:
 * 1. Extract all longitude and latitude measurements for all nodes
 * 2. Filter to last 4 weeks of data for performance optimization
 * 3. Use ROW_NUMBER() to rank by most recent timestamp per node
 * 4. Keep only most recent coordinate pair per node (r <= 1)
 * 5. Transform data for map visualization
 * 
 * Homepage Dashboard Integration:
 * - Provides visual overview of sensor network extent
 * - Supports geographic context for other navigation panels
 * - Enables spatial understanding of data coverage
 * - Complements node table and dashboard list panels
 * 
 */

-- =============================================================================
-- Network-Wide Location Data Extraction for Map Visualization
-- =============================================================================

SELECT
    time,
    node_id,
    display_name,
    metric,
    value
FROM (
    -- Subquery to rank GPS coordinates by most recent timestamp per node
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY node_id, measure 
            ORDER BY time DESC
        ) AS r,
        time,
        value,
        measure AS "metric",
        node_id,
        display_name
    FROM $project_key.data
    WHERE
        measure IN ('Longitude', 'Latitude')
        AND time >= CURRENT_DATE - INTERVAL '4 weeks'  -- Performance optimization
) x
WHERE x.r <= 1  -- Keep only the most recent coordinate for each measure per node
ORDER BY x.time ASC;

-- =============================================================================
-- Transform Configuration
-- =============================================================================

/*
 * Transform 1: Prepare time series
 * - Format: Wide time series
 * - Purpose: Converts long format data to wide format for map processing
 * - Input: Multiple rows per node (longitude and latitude separately)
 * - Output: Structured format suitable for geographic visualization
 * 
 * Transform 2: Join by labels
 * - Purpose: Combines longitude and latitude coordinates for each node
 * - Input: Wide time series format from Transform 1
 * - Output: Node records with both coordinate values for map plotting
 * 
 * Combined Result Structure:
 * - Each node represented as single record with both coordinates
 * - display_name provides human-readable node identification
 * - node_id enables linking to other dashboard panels
 * - Coordinates in decimal degrees for direct map plotting
 */

