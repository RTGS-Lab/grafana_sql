/*
 * Panel: Battery and SoC (State of Charge)
 * Dashboard: Error Flagging Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors sensor node power system including battery state of charge,
 *          average cell voltage, and solar panel voltage from diagnostic messages.
 *          Critical for system maintenance and power management.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Time Series Graph / Stat Panel
 * 
 * Variables Used:
 * - $project_key: "Roadside Turf" (project identifier)
 * - $__timeFilter: Grafana time range filter function (on publish_time)
 * - $node: Selected sensor node ID (dropdown of 11 roadside locations)
 * 
 * Data Sources:
 * - Table: $project_key.raw (diagnostic message table)
 * - Event Type: diagnostic/v2
 * - JSON Path: message.Diagnostic.Devices
 * - Device Types: GONK (power management), Kestrel (environmental sensor)
 * 
 * Expected Output:
 * - time: Timestamp from diagnostic message
 * - SoC: State of charge percentage (0-100%)
 * - Battery: Average cell voltage in volts (converted from mV)
 * - Solar: Solar panel voltage (PORT_V[3])
 * 
 * JSON Message Structure:
 * {
 *   "Diagnostic": {
 *     "Time": unix_timestamp,
 *     "Devices": [
 *       {
 *         "GONK": {
 *           "SoC": float,           // State of charge percentage
 *           "CellVAvg": integer     // Average cell voltage in millivolts
 *         }
 *       },
 *       {
 *         "Kestrel": {
 *           "PORT_V": [v0, v1, v2, v3]  // Array of port voltages
 *         }
 *       }
 *     ]
 *   }
 * }
 * */
 
-- =============================================================================
-- Main Power System Monitoring Query
-- =============================================================================

SELECT
    -- Extract timestamp from JSON diagnostic message
    to_timestamp((message::json->'Diagnostic'->>'Time')::int) AS "time",
    
    -- State of Charge percentage from GONK power management unit
    max((elems1->'GONK'->'SoC')::float) AS "SoC",
    
    -- Average cell voltage converted from millivolts to volts
    max((elems1->'GONK'->'CellVAvg')::float/1000) AS "Battery",
    
    -- Solar panel voltage from Kestrel PORT_V[3]
    max((elems2->'Kestrel'->'PORT_V'->3)::float) AS "Solar"

FROM $project_key.raw,
    -- Parse JSON arrays for device data
    jsonb_array_elements((message::jsonb)->'Diagnostic'->'Devices') elems1,
    jsonb_array_elements((message::jsonb)->'Diagnostic'->'Devices') elems2

WHERE
    -- Time range filter on message publish time
    $__timeFilter("publish_time") 
    AND node_id = '$node' 
    AND event = 'diagnostic/v2'
    
    -- Ensure we have either GONK or Kestrel device data
    AND (elems1 ? 'GONK' OR elems2 ? 'Kestrel')
    
    -- Data quality validation
    AND is_valid_json(message) 
    AND is_valid_time(message)

-- Aggregate multiple device records per timestamp
GROUP BY 1
ORDER BY 1;

