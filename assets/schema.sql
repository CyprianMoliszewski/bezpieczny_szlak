CREATE TABLE gpx_data (
    GPXD_id INTEGER PRIMARY KEY CHECK (GPXD_id = 1),
    GPXD_name TEXT NOT NULL,
    GPXD_total_distance REAL,
    GPXD_total_elevation REAL,
    GPXD_min_lat REAL,
    GPXD_max_lat REAL,
    GPXD_min_lon REAL,
    GPXD_max_lon REAL
);

CREATE TABLE gpx_points (
    GPXP_id INTEGER PRIMARY KEY AUTOINCREMENT,
    GPXP_lat REAL NOT NULL,
    GPXP_lon REAL NOT NULL,
    GPXP_ele REAL NOT NULL
);

CREATE TABLE sos_stations (
    SOS_id INTEGER PRIMARY KEY AUTOINCREMENT,
    SOS_name TEXT,
    SOS_region TEXT,
    SOS_number TEXT,
    SOS_lat REAL,
    SOS_lon REAL
);

CREATE TABLE weather_forecast(
    WF_id INTEGER PRIMARY KEY CHECK (WF_id = 1),
    WF_time TEXT NOT NULL,
    WF_lat REAL NOT NULL,
    WF_lon REAL NOT NULL
);

CREATE TABLE weather_forecast_details(
    WFD_id INTEGER PRIMARY KEY AUTOINCREMENT,
    WFD_time TEXT NOT NULL,
    WFD_temperature REAL,
    WFD_status TEXT,
    WFD_precipitation REAL,
    WFD_wind_speed REAL
);

CREATE TABLE ai_prompts(
    AIP_id INTEGER PRIMARY KEY,
    AIP_prompt TEXT NOT NULL,
    AIP_response TEXT NOT NULL
);