/*
 * Panel: VWC .5in (Surface Volumetric Water Content)
 * Dashboard: Multi-value Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors surface soil volumetric water content at 0.5" depth across 
 *          multiple sensor nodes for streamlined moisture monitoring. Provides 
 *          real-time assessment of surface soil moisture conditions without 
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
 * - Measure: Acclima Soil.VWC.1.1 (surface VWC at 0.5" depth)
 * - Sensor: Acclima TDR 315H at surface level
 * 
 * Expected Output:
 * - time: Timestamp of measurement
 * - display_name: Human-readable node identifier (RST_001A, RST_002, etc.)
 * - value: VWC percentage (0-100% soil volume occupied by water)
 * 
 * Surface Soil Moisture Monitoring:
 * This panel focuses specifically on surface soil conditions:
 * - Immediate water availability for turf roots
 * - Surface drought stress assessment
 * - Irrigation effectiveness evaluation
 * - Rainfall impact on surface moisture
 * - Evapotranspiration pattern analysis
 * 
 * VWC Measurement Context:
 * - Units: Percentage of soil volume occupied by water
 * - Range: 0% (completely dry) to 100% (water saturated)
 * - Typical turf range: 10-40% depending on soil type and conditions
 * - Critical levels: <15% (drought stress), >50% (potential waterlogging)
 * - Surface sensitivity: Responds quickly to irrigation and precipitation
 */ 
-- =============================================================================
-- Surface VWC Monitoring Query (0.5" Depth)
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
    
    -- Subsurface VWC sensor filtering (0.5" depth)
    AND (measure ILIKE '%Acclima Soil.VWC.1.1%')

-- Group by all selected fields to handle potential duplicates
GROUP BY data.measure, data.time, data.display_name, data.value
ORDER BY 1, 2;