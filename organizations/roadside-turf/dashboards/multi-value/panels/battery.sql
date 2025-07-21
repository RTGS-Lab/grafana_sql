/*
 * Panel: Battery
 * Dashboard: Multi-value Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Monitors battery voltage across multiple sensor nodes for streamlined 
 *          power system overview. Focuses on essential battery health metrics 
 *          without complex error flagging, enabling quick operational assessment.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Time Series Graph
 * 
 * Transform: Labels to fields
 * - Mode: Columns
 * - Labels: display_name, node_id
 * - Value field name: display_name
 * 
 * Variables Used:
 * - $project_key: "Roadside Turf" (project identifier)
 * - $__timeFilter: Grafana time range filter function (on publish_time)
 * - $node: Selected sensor nodes (multi-select dropdown)
 * 
 * Data Sources:
 * - Table: $project_key.raw (diagnostic message table)
 * - Event Type: diagnostic/v2
 * - JSON Path: message.Diagnostic.Devices.GONK.CellVAvg
 * - Device Type: GONK (power management unit)
 * 
 * Expected Output:
 * - node_id: Sensor node identifier
 * - display_name: Human-readable node name (RST_001A, RST_002, etc.)
 * - time: Timestamp from diagnostic message
 * - battery: Average cell voltage in volts (converted from mV)
 * 
 * Multi-Node Functionality:
 * - Node Selection: $node variable supports multiple selections
 * - Comparative Analysis: View battery health across multiple locations
 * - Operational Overview: Quick assessment of power system status
 * - Regional Monitoring: Compare power performance across Minnesota sites
 * 
 * Battery Health Assessment:
 * This panel enables quick evaluation of battery conditions across the network:
 * - Normal Range: 3.6V to 4.2V per cell (typical lithium-ion)
 * - Warning Range: 3.2V to 3.6V (monitoring recommended)
 * - Critical Range: <3.2V (immediate attention required)
 * - Overcharge: >4.3V (potential system issues)
 * 
 * JSON Message Processing:
 * - Source: GONK power management unit diagnostic messages
 * - Extraction: CellVAvg field from nested JSON structure
 * - Conversion: Millivolts to volts (/1000) for standard voltage display
 * - Validation: is_valid_json() and is_valid_time() ensure data quality
 * 
 * Transform Processing:
 * Labels to Fields transformation converts query output for visualization:
 * - Input: Multiple rows per timestamp (one per node)
 * - Output: Multiple series (one per node) for time series display
 * - Labels: display_name and node_id used for series identification
 * - Value Field: display_name creates meaningful series names
 * 
 * Multi-value Dashboard Integration:
 * - Complementary Monitoring: Works with Update Time for system health overview
 * - Node Correlation: Compare battery status with sensor performance
 * - Operational Efficiency: Quick identification of power-related issues
 * - Maintenance Planning: Prioritize field visits based on battery health
 * 
 * Performance Characteristics:
 * - JSON parsing overhead for diagnostic message processing
 * - Multi-node aggregation increases computational complexity
 * - Transform processing adds visualization optimization
 * - GROUP BY message ensures proper aggregation per diagnostic event
 * 
 * Operational Applications:
 * - Daily monitoring of power system health across network
 * - Identification of nodes requiring battery maintenance
 * - Seasonal power performance assessment (winter vs summer)
 * - Preventive maintenance scheduling based on voltage trends
 * - Field team prioritization for power system interventions
 * 
 * Troubleshooting Indicators:
 * - Declining voltage trends: Battery aging or charging system issues
 * - Voltage inconsistencies: Wiring problems or cell imbalances
 * - Missing data: Communication failures or power system malfunctions
 * - Extreme values: Sensor calibration issues or hardware problems
 */

-- =============================================================================
-- Multi-Node Battery Voltage Monitoring Query
-- =============================================================================

SELECT
    node_id,
    display_name,
    
    -- Extract timestamp from JSON diagnostic message
    to_timestamp((message::json->'Diagnostic'->>'Time')::int) AS "time",
    
    -- Average cell voltage converted from millivolts to volts
    -- Note: SoC and Solar metrics commented out for simplified focus
    -- max((elems1->'GONK'->'SoC')::float) AS "SoC",
    max((elems1->'GONK'->'CellVAvg')::float/1000) AS "battery"
    -- max((elems2->'Kestrel'->'PORT_V'->3)::float) AS "Solar"

FROM $project_key.raw,
    -- Parse JSON arrays for GONK and Kestrel device data
    jsonb_array_elements((message::jsonb)->'Diagnostic'->'Devices') elems1,
    jsonb_array_elements((message::jsonb)->'Diagnostic'->'Devices') elems2

WHERE
    -- Time range filter on message publish time
    $__timeFilter("publish_time") 
    
    -- Multi-node selection support
    AND node_id IN ($node)
    
    -- Diagnostic message filtering
    AND event = 'diagnostic/v2' 
    AND (elems1 ? 'GONK' OR elems2 ? 'Kestrel')
    
    -- Data quality validation
    AND is_valid_json(message)
    AND is_valid_time(message)

-- Group by message and node information to handle multiple device records
GROUP BY raw.message, raw.node_id, raw.display_name
ORDER BY "time" ASC, 1;

-- =============================================================================
-- Transform Configuration
-- =============================================================================

/*
 * Transform: Labels to fields
 * - Mode: Columns
 * - Labels: display_name, node_id
 * - Value field name: display_name
 * 
 * Purpose: Convert multi-node query results into time series format
 * 
 * Input Structure:
 * | time | node_id | display_name | battery |
 * |------|---------|--------------|---------|
 * | t1   | e00f... | RST_007     | 3.85    |
 * | t1   | e00f... | RST_002     | 3.92    |
 * | t2   | e00f... | RST_007     | 3.84    |
 * | t2   | e00f... | RST_002     | 3.91    |
 * 
 * Output Structure (Time Series):
 * - Series 1: "RST_007" with battery voltage values over time
 * - Series 2: "RST_002" with battery voltage values over time
 * - Legend: Node display names for easy identification
 * - Tooltip: Node information and voltage values
 */
