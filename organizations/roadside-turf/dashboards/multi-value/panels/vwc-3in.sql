/*
 * Panel: VWC 3in (Subsurface Volumetric Water Content)
 * Dashboard: Multi-value Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors subsurface soil volumetric water content at 3" depth across 
 *          multiple sensor nodes for streamlined moisture monitoring. Provides 
 *          real-time assessment of subsurface soil moisture conditions without 
 *          complex error flagging for quick operational overview.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Time Series Graph
 * 
 * Variables Used:
 * - $__timeFilter: Grafana time range filter function
 * - $node: Selected sensor nodes (multi-select dropdown)
 * 
 * Data Sources:
 * - Table: roadsideturf.data (processed sensor measurements)
 * - Measure: Acclima Soil.VWC.1.2 (subsurface VWC at 3" depth)
 * - Sensor: Acclima TDR 315H at subsurface level
 * 
 * Expected Output:
 * - time: Timestamp of measurement
 * - display_name: Human-readable node identifier (RST_001A, RST_002, etc.)
 * - value: VWC percentage (0-100% soil volume occupied by water)
 * 
 * Subsurface Soil Moisture Monitoring:
 * This panel focuses on deeper soil moisture conditions:
 * - Primary root zone water availability
 * - Stable moisture reservoir assessment
 * - Deep irrigation effectiveness evaluation
 * - Seasonal moisture storage patterns
 * - Drought resilience indicator analysis
 */

-- =============================================================================
-- Subsurface VWC Monitoring Query (3" Depth)
-- =============================================================================

SELECT
    "time",
    
    -- Node identification for multi-series visualization
    -- Note: measure commented out for streamlined output focus
    -- measure,
    display_name,
    
    -- VWC percentage (no conversion needed)
    value

FROM roadsideturf.data
WHERE
    -- Time range filtering
    $__timeFilter("time")
    
    -- Multi-node selection support
    AND node_id IN ($node)
    
    -- Subsurface VWC sensor filtering (3" depth)
    AND (measure ILIKE '%Acclima Soil.VWC.1.2%')

-- Group by all selected fields to handle potential duplicates
GROUP BY data.measure, data.time, data.display_name, data.value
ORDER BY 1, 2;