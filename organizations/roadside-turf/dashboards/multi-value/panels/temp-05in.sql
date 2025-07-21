/*
 * Panel: Temp .5in (Surface Soil Temperature)
 * Dashboard: Multi-value Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors surface soil temperature at 0.5" depth across multiple 
 *          sensor nodes for streamlined thermal monitoring. Provides real-time 
 *          assessment of surface soil thermal conditions with Celsius to 
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
 * - Measure: Acclima Soil.Temperature.1.1 (surface temperature at 0.5" depth)
 * - Sensor: Acclima TDR 315H at surface level
 * 
 * Expected Output:
 * - time: Timestamp of measurement
 * - display_name: Human-readable node identifier (RST_001A, RST_002, etc.)
 * - value: Temperature in Fahrenheit (converted from Celsius via transform)
 * 
 * Surface Soil Temperature Monitoring:
 * This panel focuses specifically on surface thermal conditions:
 * - Immediate temperature exposure affecting turf crowns
 * - Surface freeze-thaw cycle monitoring
 * - Heat stress assessment at soil surface
 * - Diurnal temperature variation analysis
 * - Critical temperature threshold monitoring
 * 
 * Temperature Conversion Process:
 * - Raw Data: Celsius values from Acclima TDR 315H sensor
 * - Transform: Grafana math operation ($A*9/5)+32
 * - Display: Fahrenheit values for operational use
 * - Formula: °F = (°C × 9/5) + 32
 * - Example: 20°C → (20 × 9/5) + 32 = 68°F
 */

-- =============================================================================
-- Surface Temperature Monitoring Query (0.5" Depth)
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
    
    -- Surface temperature sensor filtering (0.5" depth)
    AND (measure ILIKE '%Acclima Soil.Temperature.1.1%')

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
 * Conversion Process:
 * 1. Query A provides raw temperature data in Celsius
 * 2. Transform applies mathematical conversion formula
 * 3. Result displays temperature values in Fahrenheit
 * 4. Visualization shows converted values with °F units
 * 
 * Formula Explanation:
 * - Multiply by 9/5: Converts Celsius degree scale to Fahrenheit scale
 * - Add 32: Adjusts for different zero points (0°C = 32°F)
 * - Result: Standard Fahrenheit temperature for operational use
 * 
 * Example Conversions:
 * - 0°C → (0 × 9/5) + 32 = 32°F (freezing point)
 * - 10°C → (10 × 9/5) + 32 = 50°F (cool weather)
 * - 20°C → (20 × 9/5) + 32 = 68°F (mild weather)
 * - 30°C → (30 × 9/5) + 32 = 86°F (warm weather)
 */

