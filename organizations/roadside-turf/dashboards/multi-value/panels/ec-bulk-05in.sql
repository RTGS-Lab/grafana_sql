/*
 * Panel: EC Bulk .5in (Surface Bulk Electrical Conductivity)
 * Dashboard: Multi-value Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors surface soil bulk electrical conductivity at 0.5" depth 
 *          across multiple sensor nodes for streamlined salinity monitoring. 
 *          Provides real-time assessment of salt stress conditions without 
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
 * - Measure: Acclima Soil.EC_Bulk.1.1 (surface bulk EC at 0.5" depth)
 * - Sensor: Acclima TDR 315H at surface level
 * 
 * Expected Output:
 * - time: Timestamp of measurement
 * - display_name: Human-readable node identifier (RST_001A, RST_002, etc.)
 * - value: Bulk EC measurement in µS/cm (microsiemens per centimeter)
 * 
 * 
 * Surface Soil Salinity Monitoring:
 * This panel focuses specifically on surface salt stress conditions:
 * - Immediate salt exposure from winter deicing operations
 * - Surface salt accumulation patterns
 * - Turf salt tolerance assessment at root zone entry
 * - Seasonal salt buildup and dilution cycles
 * - Critical zone monitoring for salt-sensitive species
 * 
 * Bulk Electrical Conductivity Context:
 * - Units: µS/cm (microsiemens per centimeter)
 * - Measurement: Conductivity of entire soil-water-air system
 * - Salt indicator: Higher values indicate increased salt content
 * - Range: 0-2000 µS/cm typical for roadside soil conditions
 * - Surface sensitivity: First to show salt application impacts
 * 
 * Roadside Salt Stress Assessment:
 * Critical thresholds for turf salt tolerance:
 * - 0-800 µS/cm: Normal range for most turfgrasses
 * - 800-1200 µS/cm: Moderate salt stress, monitor sensitive species
 * - 1200-1600 µS/cm: High salt stress, affects moderately tolerant species
 * - 1600-2000 µS/cm: Severe salt stress, only salt-tolerant species survive
 * - >2000 µS/cm: Extreme conditions, potential vegetation kill
 * 
 * Multi-Node Comparative Analysis:
 * - Geographic salt exposure patterns across Minnesota roadways
 * - Species salt tolerance performance comparison
 * - Deicing operation impact assessment across sites
 * - Regional salt accumulation and dilution patterns
 * - Site-specific salt management strategy effectiveness
 * 
 * Seasonal Monitoring Applications:
 * - Winter: Real-time salt application impact assessment
 * - Spring: Salt dilution and leaching monitoring
 * - Summer: Background salinity and drought concentration effects
 * - Fall: Pre-winter baseline establishment
 * - Annual: Long-term salt accumulation trend analysis
 * 
 */

-- =============================================================================
-- Surface Bulk EC Monitoring Query (0.5" Depth)
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
    
    -- Surface bulk EC sensor filtering (0.5" depth)
    AND (measure ILIKE '%Acclima Soil.EC_Bulk.1.1%')

-- Group by all selected fields to handle potential duplicates
GROUP BY data.measure, data.time, data.display_name, data.value
ORDER BY 1, 2;

