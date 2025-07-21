# Dashboards List Panel Configuration

## Panel Information

**Panel Type**: Dashboard List  
**Dashboard**: Homepage Dashboard  
**Organization**: Roadside Turf  
**Purpose**: Navigation panel providing searchable list of available dashboards  
**Visualization**: Dashboard List (Grafana built-in)

## Configuration

### Panel Settings
- **Panel Type**: Dashboard List
- **Search**: Enabled (toggle on)
- **SQL Query**: Not applicable (uses Grafana dashboard list functionality)

## Dashboard List Contents

### Available Dashboards
The panel displays all dashboards available in the Roadside Turf organization:

1. **Error Flagging Dashboard**
   - **Purpose**: Comprehensive sensor monitoring with error detection
   - **Panels**: 10 panels including soil sensors, system monitoring, raw data export
   - **Primary Use**: Daily monitoring, quality control, anomaly detection

2. **Multi-value Dashboard** 
   - **Purpose**: Real-time monitoring without error flagging complexity
   - **Focus**: Current sensor readings and trends
   - **Primary Use**: Quick status checks, operational overview

3. **Homepage Dashboard**
   - **Purpose**: Navigation hub and network overview
   - **Self-Reference**: Listed in its own dashboard list for navigation consistency
   - **Primary Use**: Entry point, network overview, navigation
