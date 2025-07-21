/*
 * Panel: Raw Data
 * Dashboard: Multi-value Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Provides streamlined raw sensor data export across multiple nodes 
 *          for operational analysis and data download. Focuses on essential 
 *          sensor measurements without complex error flagging for efficient 
 *          data access and analysis.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Table
 * 
 * Transform: Join by field
 * - Mode: Outer
 * - Field: Time
 * 
 * Variables Used:
 * - $__timeFilter: Grafana time range filter function
 * - $node: Selected sensor nodes (multi-select dropdown)
 * 
 * Data Sources:
 * - Table: roadsideturf.data (processed sensor measurements)
 * - Scope: All environmental sensor measurements (excludes location data)
 * - Coverage: Multiple nodes with all sensor parameters
 * 
 * Expected Output:
 * Query A - Sensor Data:
 * - time: Timestamp of measurements
 * - metric: Sensor parameter name
 * - value: Measurement value
 * 
 * Query B - Node Identification:
 * - time: Timestamp of measurements  
 * - node_id: Node display name for identification
 * 
 * Included Sensor Measurements:
 * Environmental sensors (per node):
 * - Acclima Soil.Temperature.1.1, 1.2 (surface and subsurface)
 * - Acclima Soil.VWC.1.1, 1.2 (volumetric water content)
 * - Acclima Soil.EC_BULK.1.1, 1.2 (bulk electrical conductivity)
 * - Acclima Soil.EC_PORE.1.1, 1.2 (pore electrical conductivity)
 * - Acclima Soil.Permitivity.1.1, 1.2 (soil permittivity)
 * - Apogee O2.Oxygen_%.1.4 (gaseous oxygen)
 * - Apogee O2.Temperature.1.4 (oxygen sensor temperature)
 * 
 * Multi-Node Export Capability:
 * - Comparative analysis: Multiple nodes in single export
 * - Regional assessment: Geographic data comparison
 * - Operational efficiency: Bulk data access for selected nodes
 * - Research support: Multi-site data package for analysis
 * - Quality assurance: Cross-node validation and comparison
 * 
 * Transform Processing:
 * Join by Field (Outer) creates comprehensive table:
 * - Query A: Provides sensor measurements with metric identification
 * - Query B: Provides node identification per timestamp
 * - Join: Combines on Time field for complete data context
 * - Output: Table with timestamps, nodes, metrics, and values
 * 
 * Multi-value Dashboard Integration:
 * - Comprehensive export: Supports all individual panel data
 * - Validation tool: Verify individual panel accuracy
 * - Bulk analysis: Multi-parameter, multi-node assessment
 * - Operational backup: Complete data access for troubleshooting
 * - Research bridge: Connect operational monitoring to analysis
 */

-- =============================================================================
-- QUERY A: Sensor Measurements Data
-- =============================================================================

SELECT
    "time" AS "time",
    measure AS "metric",
    value
FROM roadsideturf.data
WHERE
    -- Time range filtering
    $__timeFilter("time")
    
    -- Multi-node selection support
    AND node_id IN ($node)
    
    -- Exclude location/positioning data for sensor focus
    AND measure NOT ILIKE 'latitude'
    AND measure NOT ILIKE 'longitude'
    AND measure NOT ILIKE 'altitude'
ORDER BY time ASC;

-- =============================================================================
-- QUERY B: Node Identification Data
-- =============================================================================

SELECT
    "time" AS "time",
    display_name AS "node_id"
FROM roadsideturf.data
WHERE
    -- Time range filtering
    $__timeFilter("time")
    
    -- Multi-node selection support
    AND node_id IN ($node)
    
    -- Exclude location/positioning data for consistency
    AND measure NOT ILIKE 'latitude'
    AND measure NOT ILIKE 'longitude'
    AND measure NOT ILIKE 'altitude'
ORDER BY time ASC;

-- =============================================================================
-- Transform Configuration
-- =============================================================================

/*
 * Transform: Join by field
 * - Mode: Outer
 * - Field: Time
 * 
 * Purpose: Combine sensor measurements with node identification
 * 
 * Input Structure:
 * Query A (Sensor Data):
 * | time | metric | value |
 * |------|--------|-------|
 * | t1   | Temp   | 20.5  |
 * | t1   | VWC    | 25.2  |
 * 
 * Query B (Node Data):
 * | time | node_id |
 * |------|---------|
 * | t1   | RST_007 |
 * | t1   | RST_007 |
 * 
 * Output Structure (Joined Table):
 * | Time | metric | value | node_id |
 * |------|--------|-------|---------|
 * | t1   | Temp   | 20.5  | RST_007 |
 * | t1   | VWC    | 25.2  | RST_007 |
 * 
 * Benefits:
 * - Complete context: Each measurement linked to node and time
 * - Export ready: Suitable for CSV download or analysis
 * - Multi-node clarity: Node identification for every measurement
 * - Research format: Standard structure for data analysis
 */

