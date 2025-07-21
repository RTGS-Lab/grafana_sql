/*
 * Panel: Location (Map)
 * Dashboard: Error Flagging Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Extracts the most recent GPS coordinates (latitude and longitude) 
 *          for the selected sensor node to display location on a map visualization.
 *          Critical for field operations and spatial analysis.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Map Panel
 * 
 * Variables Used:
 * - $project_key: "Roadside Turf" (project identifier)
 * - $node: Selected sensor node ID (dropdown of 11 roadside locations)
 * 
 * Data Sources:
 * - Longitude: GPS longitude coordinate
 * - Latitude: GPS latitude coordinate
 * - display_name: Human-readable node identifier
 * - node_id: Unique sensor node identifier
 * 
 * Expected Output:
 * - time: Timestamp of most recent GPS reading
 * - node_id: Sensor node identifier
 * - display_name: Human-readable node name
 * - metric: "Longitude" or "Latitude"
 * - value: Coordinate value in decimal degrees
 * 
 * Query Logic:
 * 1. Extract all longitude and latitude measurements for selected node
 * 2. Use ROW_NUMBER() to rank by most recent timestamp
 * 3. Filter to keep only the most recent coordinate pair (r <= 1)
 * 4. Return both coordinates for map plotting
 * 
 * Map Visualization Requirements:
 * - Latitude and Longitude must be in decimal degrees
 * - Single point per node (most recent coordinates)
 * - Display name for map marker labels
 * - Node ID for marker identification
 *
 */

-- =============================================================================
-- Location Data Extraction for Map Visualization
-- =============================================================================

SELECT
    time,
    node_id,
    display_name,
    metric,
    value
FROM (
    -- Subquery to rank GPS coordinates by most recent timestamp
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
        node_id = '$node'
        AND measure IN ('Longitude', 'Latitude')
) x
WHERE x.r <= 1  -- Keep only the most recent coordinate for each measure
ORDER BY x.time ASC;

-- =============================================================================
-- Query Analysis Notes
-- =============================================================================

/*
 * ROW_NUMBER() Window Function:
 * - PARTITION BY: Separates Longitude and Latitude records
 * - ORDER BY time DESC: Most recent timestamp gets rank 1
 * - Result: Each coordinate type gets its most recent value
 * 
 * Filtering Logic:
 * - r <= 1: Keeps only the most recent record per coordinate type
 * - Ensures exactly 2 records: 1 Longitude + 1 Latitude
 * - Handles cases where GPS coordinates might be updated over time
 * 
 * Expected Result Structure:
 * | time                | node_id    | display_name | metric    | value     |
 * |---------------------|------------|--------------|-----------|-----------|
 * | 2023-08-17 10:30:00 | e00fce68...| RST_007     | Longitude | -94.13416 |
 * | 2023-08-17 10:30:00 | e00fce68...| RST_007     | Latitude  | 45.34852  |
 * 
 * Map Panel Configuration:
 * - Latitude field: value (where metric = 'Latitude')
 * - Longitude field: value (where metric = 'Longitude') 
 * - Label field: display_name
 * - Tooltip: node_id, display_name, coordinates
 * 
 * Coordinate System:
 * - Format: Decimal degrees (DD)
 * - Datum: WGS84 (standard GPS datum)
 * - Precision: Typically 5-6 decimal places for meter-level accuracy
 * - Minnesota range: Lat ~43-49°N, Lon ~89-97°W
 *
 */