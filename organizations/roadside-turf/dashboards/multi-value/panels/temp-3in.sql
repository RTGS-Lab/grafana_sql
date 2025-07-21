/*
 * Panel: Temp 3in (Subsurface Soil Temperature)
 * Dashboard: Multi-value Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors subsurface soil temperature at 3" depth across multiple 
 *          sensor nodes for streamlined thermal monitoring. Provides real-time 
 *          assessment of subsurface soil thermal conditions with Celsius to 
 *          Fahrenheit conversion for operational use.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Time Series Graph
 * 
 * Transform: Math Operation
 * - Operation: Math
 * - Expression: ($A*9/5)+32
 * - Purpose: Convert Celsius to Fahrenheit for operational display
 * 
 * Variables Used:
 * - $__timeFilter: Grafana time range filter function
 * - $node: Selected sensor nodes (multi-select dropdown)
 * 
 * Data Sources:
 * - Table: roadsideturf.data (processed sensor measurements)
 * - Measure: Acclima Soil.Temperature.1.2 (subsurface temperature at 3" depth)
 * - Sensor: Acclima TDR 315H at subsurface level
 * 
 * Expected Output:
 * - time: Timestamp of measurement
 * - display_name: Human-readable node identifier (RST_001A, RST_002, etc.)
 * - value: Temperature in Fahrenheit (converted from Celsius via transform)
 * 
 * Subsurface Soil Temperature Monitoring:
 * This panel focuses on deeper thermal conditions:
 * - Root zone temperature stability assessment
 * - Deep freeze penetration monitoring
 * - Subsurface thermal stress evaluation
 * - Seasonal temperature buffer analysis
 * - Long-term thermal pattern documentation
 * 
 * Temperature Conversion Process:
 * - Raw Data: Celsius values from Acclima TDR 315H sensor
 * - Transform: Grafana math operation ($A*9/5)+32
 * - Display: Fahrenheit values for operational use
 * - Formula: °F = (°C × 9/5) + 32
 * - Example: 15°C → (15 × 9/5) + 32 = 59°F
 */

-- =============================================================================
-- Subsurface Temperature Monitoring Query (3" Depth)
-- =============================================================================

SELECT
    "time",
    
    -- Node identification for multi-series visualization
    -- Note: measure commented out for streamlined output focus
    -- measure,
    display_name,
    
    -- Temperature in Celsius (converted to Fahrenheit via transform)
    value

FROM roadsideturf.data
WHERE
    -- Time range filtering
    $__timeFilter("time")
    
    -- Multi-node selection support
    AND node_id IN ($node)
    
    -- Subsurface temperature sensor filtering (3" depth)
    AND (measure ILIKE '%Acclima Soil.Temperature.1.2%')

-- Group by all selected fields to handle potential duplicates
GROUP BY data.measure, data.time, data.display_name, data.value
ORDER BY 1, 2;

-- =============================================================================
-- Transform Configuration
-- =============================================================================

/*
 * Query B: Math Transform
 * - Operation: Math
 * - Expression: ($A*9/5)+32
 * 
 * Purpose: Convert Celsius temperature values to Fahrenheit for operational display
 * 
 * Note: Same transform configuration as surface temperature panel
 * Formula converts subsurface Celsius readings to Fahrenheit for consistency
 */