/*
 * Panel: Gaseous Oxygen
 * Dashboard: Multi-value Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors soil gaseous oxygen concentration at 2" depth across multiple 
 *          sensor nodes for streamlined oxygen availability assessment. Provides 
 *          real-time evaluation of root zone oxygen conditions without complex 
 *          error flagging for quick operational overview.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Time Series Graph
 * 
 * Transform: Labels to fields
 * - Mode: Column
 * - Labels: display_name
 * - Value field name: display_name
 * 
 * Variables Used:
 * - $__timeFilter: Grafana time range filter function
 * - $node: Selected sensor nodes (multi-select dropdown)
 * 
 * Data Sources:
 * - Table: roadsideturf.data (processed sensor measurements)
 * - Measure: Apogee O2.Oxygen_%.1.4 (gaseous oxygen at 2" depth)
 * - Sensor: Apogee SO-421 oxygen sensor
 * 
 * Expected Output:
 * - time: Timestamp of measurement
 * - display_name: Human-readable node identifier (RST_001A, RST_002, etc.)
 * - value: Oxygen percentage (0-100% O₂ in soil atmosphere)
 * 
 * Gaseous Oxygen Monitoring Context:
 * This panel focuses on root zone oxygen availability:
 * - Root respiration support assessment
 * - Soil compaction detection through oxygen depletion
 * - Waterlogging identification via oxygen reduction
 * - Turf stress evaluation under traffic/maintenance pressure
 * - Soil aeration effectiveness monitoring
 * 
 * Oxygen Measurement Context:
 * - Units: Percentage O₂ in soil atmosphere
 * - Range: 0-100% (typical soil range 10-21%)
 * - Installation depth: 2 inches (root zone level)
 * - Normal atmospheric: ~21% oxygen
 * - Critical for: Root respiration and turf health
 * - Sensitivity: Responds to soil moisture and compaction
 * 
 * Multi-Node Comparative Analysis:
 * - Geographic oxygen availability patterns across Minnesota
 * - Soil compaction comparison between roadside locations
 * - Site-specific aeration needs assessment
 * - Regional drainage effectiveness evaluation
 * - Traffic impact correlation with oxygen levels
 * 
 * Transform Processing:
 * Labels to Fields transformation optimizes multi-node display:
 * - Input: Multiple rows per timestamp (one per node)
 * - Output: Multiple series (one per node) for time series display
 * - Labels: display_name used for series identification
 * - Value Field: display_name creates meaningful series names
 * - Mode: Column format for efficient visualization
 */

-- =============================================================================
-- Gaseous Oxygen Monitoring Query (2" Depth)
-- =============================================================================

SELECT
    "time",
    
    -- Node identification for multi-series visualization
    -- Note: measure commented out for streamlined output focus
    -- measure,
    display_name,
    
    -- Oxygen percentage (no conversion needed)
    value

FROM roadsideturf.data
WHERE
    -- Time range filtering
    $__timeFilter("time")
    
    -- Multi-node selection support
    AND node_id IN ($node)
    
    -- Gaseous oxygen sensor filtering (2" depth)
    AND (measure = 'Apogee O2.Oxygen_%.1.4')

-- Group by all selected fields plus time for proper aggregation
-- Note: Group by 1 commented out, using explicit field grouping
-- Group by 1
GROUP BY data.measure, data.time, data.display_name, data.value, 1
ORDER BY 1, 2;

-- =============================================================================
-- Transform Configuration
-- =============================================================================

/*
 * Transform: Labels to fields
 * - Mode: Column
 * - Labels: display_name
 * - Value field name: display_name
 * 
 * Purpose: Convert multi-node query results into time series format
 * 
 * Input Structure:
 * | time | display_name | value |
 * |------|--------------|-------|
 * | t1   | RST_007     | 18.5  |
 * | t1   | RST_002     | 16.2  |
 * | t2   | RST_007     | 18.3  |
 * | t2   | RST_002     | 16.4  |
 * 
 * Output Structure (Time Series):
 * - Series 1: "RST_007" with oxygen values over time
 * - Series 2: "RST_002" with oxygen values over time
 * - Legend: Node display names for easy identification
 * - Tooltip: Node information and oxygen percentage values
 */