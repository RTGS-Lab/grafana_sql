/*
 * Panel: EC Bulk 3in (Subsurface Bulk Electrical Conductivity)
 * Dashboard: Multi-value Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors subsurface soil bulk electrical conductivity at 3" depth 
 *          across multiple sensor nodes for streamlined salinity monitoring. 
 *          Provides real-time assessment of deep salt stress conditions without 
 *          complex error flagging for quick operational overview.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Time Series Graph
 * Refresh Rate: [Please specify]
 * 
 * Variables Used:
 * - $__timeFilter: Grafana time range filter function
 * - $node: Selected sensor nodes (multi-select dropdown)
 * 
 * Data Sources:
 * - Table: roadsideturf.data (processed sensor measurements)
 * - Measure: Acclima Soil.EC_Bulk.1.2 (subsurface bulk EC at 3" depth)
 * - Sensor: Acclima TDR 315H at subsurface level
 * 
 * Expected Output:
 * - time: Timestamp of measurement
 * - display_name: Human-readable node identifier (RST_001A, RST_002, etc.)
 * - value: Bulk EC measurement in µS/cm (microsiemens per centimeter)
 * 
 * Subsurface Soil Salinity Monitoring:
 * This panel focuses on deeper salt stress conditions:
 * - Root zone salt accumulation assessment
 * - Deep salt penetration from repeated deicing
 * - Long-term salt stress evaluation
 * - Subsurface salt leaching effectiveness
 * - Chronic salt exposure monitoring
 * 
 * Bulk Electrical Conductivity Context:
 * - Units: µS/cm (microsiemens per centimeter)
 * - Measurement: Conductivity of entire soil-water-air system at depth
 * - Salt accumulation: Often higher than surface due to leaching
 * - Range: 0-2000 µS/cm typical for roadside subsurface conditions
 * - Stability: Changes more gradually than surface measurements
 *
 */

-- =============================================================================
-- Subsurface Bulk EC Monitoring Query (3" Depth)
-- =============================================================================

SELECT
    "time",
    
    -- Node identification for multi-series visualization
    -- Note: measure commented out for streamlined output focus
    -- measure,
    display_name,
    
    -- Bulk EC measurement in µS/cm (no conversion needed)
    value

FROM roadsideturf.data
WHERE
    -- Time range filtering
    $__timeFilter("time")
    
    -- Multi-node selection support
    AND node_id IN ($node)
    
    -- Subsurface bulk EC sensor filtering (3" depth)
    AND (measure ILIKE '%Acclima Soil.EC_Bulk.1.2%')

-- Group by all selected fields to handle potential duplicates
GROUP BY data.measure, data.time, data.display_name, data.value
ORDER BY 1, 2;