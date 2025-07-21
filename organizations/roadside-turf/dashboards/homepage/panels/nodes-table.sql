/*
 * Panel: Nodes Table
 * Dashboard: Homepage Dashboard
 * Organization: Roadside Turf
 * 
 * Purpose: Displays a clickable table of all sensor nodes with direct navigation 
 *          links to each node's individual error flagging dashboard. Provides 
 *          immediate access to detailed monitoring for any specific location.
 * 
 * Last Modified: 2025-07-16
 * 
 * Visualization: Table Panel with Data Links
 * 
 * Variables Used:
 * - $project_key: "Roadside Turf" (project identifier)
 * 
 * Data Sources:
 * - Table: $project_key.meta (project metadata table)
 * - Field: display_name (human-readable node identifiers)
 * - Filter: project = 'Roadside Turf'
 * 
 * Expected Output:
 * - display_name: Node identifiers (RST_001A, RST_002, etc.) in descending order
 * 
 * Data Link Configuration:
 * - URL: https://sensing-0.msi.umn.edu/d/O9hQkgasdgasdvasef1erscv84562/rst_flag_db?orgId=15&var-node=${__data.fields[0]}
 * - Purpose: Direct navigation to node-specific error flagging dashboard
 * - Variable Injection: ${__data.fields[0]} passes selected node display_name
 * - Target: Error Flagging Dashboard with pre-selected node
 * 
 * Node Network Coverage:
 * This table provides navigation to all 11 roadside monitoring stations:
 * - RST_001A: Bemidji (replacement node)
 * - RST_002: Roseville
 * - RST_003A: Chatfield (replacement node)
 * - RST_004: Marshall
 * - RST_005: East Grand Forks
 * - RST_006: Grand Rapids
 * - RST_007: Saint Cloud
 * - RST_008: Worthington
 * - RST_009A: Fergus Falls (replacement node)
 * - RST_010: Duluth
 * - RST_011: International Falls
 * 
 * Key Features:
 * - Simple, efficient query from metadata table
 * - Clickable navigation to detailed monitoring
 * - Alphabetical sorting (descending) for consistent presentation
 * - Direct integration with error flagging dashboard
 * - Seamless user workflow from overview to detailed analysis
 * 
 * Homepage Dashboard Integration:
 * - Complements map visualization with textual navigation
 * - Provides alternative navigation method to geographic selection
 * - Enables quick access to known problem nodes
 * - Supports systematic review of all monitoring locations
 * 
 * User Workflow:
 * 1. User views Homepage Dashboard for network overview
 * 2. Identifies node of interest from map or needs assessment
 * 3. Clicks on node name in table
 * 4. Automatically navigated to Error Flagging Dashboard
 * 5. Error Flagging Dashboard pre-loaded with selected node data
 * 
 * Data Link Mechanics:
 * - Click Event: User clicks on any display_name value
 * - URL Construction: Template URL with variable substitution
 * - Variable Passing: ${__data.fields[0]} = clicked display_name
 * - Navigation: Browser redirects to error flagging dashboard
 * - Context Preservation: Selected node automatically loaded
 */

-- =============================================================================
-- Node Navigation Table Query
-- =============================================================================

SELECT DISTINCT display_name
FROM $project_key.meta 
WHERE project = 'Roadside Turf'
AND display_name NOT LIKE 'DoA2'
ORDER BY display_name asc;

-- =============================================================================
-- Data Link Configuration
-- =============================================================================

/*
 * Data Link URL Template:
 * https://sensing-0.msi.umn.edu/d/O9hQkgasdgasdvasef1erscv84562/rst_flag_db?orgId=15&var-node=${__data.fields[0]}
 * 
 * URL Components:
 * - Base URL: https://sensing-0.msi.umn.edu/d/
 * - Dashboard ID: O9hQkgasdgasdvasef1erscv84562
 * - Dashboard Slug: rst_flag_db (Error Flagging Dashboard)
 * - Organization ID: orgId=15 (Roadside Turf organization)
 * - Variable Assignment: var-node=${__data.fields[0]}
 * 
 * Variable Substitution:
 * - ${__data.fields[0]}: Grafana template variable
 * - Resolves to: Clicked display_name value from table
 * - Examples: RST_001A, RST_002, RST_003A, etc.
 * - Result: Pre-selects node in destination dashboard
 * 
 * Navigation Flow:
 * 1. User clicks "RST_007" in nodes table
 * 2. URL becomes: .../rst_flag_db?orgId=15&var-node=RST_007
 * 3. Error Flagging Dashboard loads with RST_007 pre-selected
 * 4. All panels automatically display Saint Cloud sensor data
 * 5. User has immediate access to detailed error flagging analysis
 */
