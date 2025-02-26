{ pkgs, ... }:
{
  services.influxdb2 = {
    enable = true;
  };
  services.telegraf = {
    enable = true;
    extraConfig = {
      inputs = {

        mqtt_consumer = {
          servers = ["tcp://localhost:1883"];
          topics = [
            "solar/+/status/+"
            "solar/+/0/+"
            "solar/+/1/+"
            "solar/+/2/+"
          ];

          data_format = "value";
          data_type = "float";
          topic_parsing = [
            {
              topic = "solar/+/+/+";
              tags = "_/serial/channel/field";
            }
          ];
          username = "mqtt";
          password = "6o81OYekOl";
        };
      };
      processors.pivot = [
        {
          tag_key = "field";
          value_key = "value";
        }
      ];
      outputs = {
        influxdb_v2 = {
          urls = [ "http://127.0.0.1:8086" ];
          token = "Tq4FAQCdtndv6ZR2WlFRZ5TX9v6TrVTUbZlYsTgEO_HGRuqHA1LE4-JwiDRIw084jyjR9GHVKYrlsXSSw5bejQ==";
          organization = "home";
          bucket = "main";
        };
      };
    };
  };
  services.home-assistant = {
    enable = true;

      extraComponents = [
        "mqtt"
        "signal_messenger"
        "roborock"
        "hue"
        "zeroconf"
        "brother"
        "influxdb"
        "mobile_app"
      # "3_day_blinds", "abode", "accuweather", "acer_projector", "acmeda",
      # "acomax", "actiontec", "adax", "adguard", "ads", "advantage_air",
      # "aemet", "aep_ohio", "aep_texas", "aftership", "agent_dvr",
      # "air_quality", "airgradient", "airly", "airnow", "airq", "airthings",
      # "airthings_ble", "airtouch4", "airtouch5", "airvisual",
      # "airvisual_pro", "airzone", "airzone_cloud", "aladdin_connect",
      # "alarm_control_panel", "alarmdecoder", "alert", "alexa",
      # "alpha_vantage", "amazon_polly", "amberelectric", "ambient_network",
      # "ambient_station", "amcrest", "amp_motorization", "ampio", "analytics",
      # "analytics_insights", "android_ip_webcam", "androidtv",
      # "androidtv_remote", "anel_pwrctrl", "anova", "anthemav", "anthropic",
      # "anwb_energie", "aosmith", "apache_kafka", "apcupsd", "api",
      # "appalachianpower", "apple_tv", "application_credentials", "apprise",
      # "aprilaire", "aprs", "aps", "apsystems", "aquacell", "aqualogic",
      # "aquostv", "aranet", "arcam_fmj", "arest", "arris_tg2492lg",
      # "artsound", "aruba", "arve", "arwn", "aseko_pool_live",
      # "assist_pipeline", "assist_satellite", "asuswrt", "atag", "aten_pe",
      # "atlanticcityelectric", "atome", "august", "august_ble", "aurora",
      # "aurora_abb_powerone", "aussie_broadband", "autarco", "auth",
      # "automation", "avea", "avion", "awair", "aws", "axis",
      # "azure_data_explorer", "azure_devops", "azure_event_hub",
      # "azure_service_bus", "backup", "baf", "baidu", "balboa",
      # "bang_olufsen", "bayesian", "bbox", "beewi_smartclim", "bge",
      # "binary_sensor", "bitcoin", "bizkaibus", "blackbird", "blebox",
      # "blink", "bliss_automation", "bloc_blinds", "blockchain", "bloomsky",
      # "blue_current", "bluemaestro", "blueprint", "bluesound", "bluetooth",
      # "bluetooth_adapters", "bluetooth_le_tracker", "bluetooth_tracker",
      # "bmw_connected_drive", "bond", "bosch_shc", "brandt", "braviatv",
      # "brel_home", "bring", "broadlink", "brother", "brottsplatskartan",
      # "browser", "brunt", "bryant_evolution", "bsblan", "bswitch",
      # "bt_home_hub_5", "bt_smarthub", "bthome", "bticino", "bubendorff",
      # "buienradar", "button", "caldav", "calendar", "cambridge_audio",
      # "camera", "canary", "cast", "ccm15", "cert_expiry", "chacon_dio",
      # "channels", "cisco_ios", "cisco_mobility_express", "citybikes",
      # "clementine", "clickatell", "clicksend", "clicksend_tts", "climate",
      # "cloud", "cloudflare", "cmus", "co2signal", "coautilities", "coinbase",
      # "color_extractor", "comed", "comed_hourly_pricing", "comelit",
      # "comfoconnect", "command_line", "compensation", "concord232", "coned",
      # "config", "configurator", "control4", "conversation", "coolmaster",
      # "counter", "cover", "cozytouch", "cppm_tracker", "cpuspeed", "cribl",
      # "crownstone", "cups", "currencylayer", "dacia", "daikin",
      # "danfoss_air", "datadog", "date", "datetime", "ddwrt", "deako",
      # "debugpy", "deconz", "decora", "decora_wifi", "default_config",
      # "delijn", "delmarva", "deluge", "demo", "denon", "denonavr",
      # "derivative", "devialet", "device_automation",
      # "device_sun_light_trigger", "device_tracker", "devolo_home_control",
      # "devolo_home_network", "dexcom", "dhcp", "diagnostics", "dialogflow",
      # "diaz", "digital_loggers", "digital_ocean", "directv", "discogs",
      # "discord", "discovergy", "dlib_face_detect", "dlib_face_identify",
      # "dlink", "dlna_dmr", "dlna_dms", "dnsip", "dominos", "doods",
      # "doorbird", "dooya", "dormakaba_dkey", "downloader",
      # "dremel_3d_printer", "drop_connect", "dsmr", "dsmr_reader",
      # "dte_energy_bridge", "dublin_bus_transport", "duckdns", "duke_energy",
      # "dunehd", "duotecno", "duquesne_light", "dwd_weather_warnings",
      # "dweet", "dynalite", "eafm", "eastron", "easyenergy", "ebox", "ebusd",
      # "ecoal_boiler", "ecobee", "ecoforest", "econet", "ecovacs", "ecowitt",
      # "eddystone_temperature", "edimax", "edl21", "efergy", "egardia",
      # "eight_sleep", "electrasmart", "electric_kiwi", "elevenlabs", "elgato",
      # "eliqonline", "elkm1", "elmax", "elv", "elvia", "emby", "emoncms",
      # "emoncms_history", "emonitor", "emulated_hue", "emulated_kasa",
      # "emulated_roku", "energenie_power_sockets", "energie_vanons", "energy",
      # "energyzero", "enigma2", "enmax", "enocean", "enphase_envoy",
      # "entur_public_transport", "environment_canada", "envisalink",
      # "ephember", "epic_games_store", "epion", "epson", "eq3btsmart",
      # "escea", "esera_onewire", "esphome", "etherscan", "eufy",
      # "eufylife_ble", "event", "evergy", "everlights", "evil_genius_labs",
      # "evohome", "ezviz", "faa_delays", "facebook", "fail2ban", "familyhub",
      # "fan", "fastdotcom", "feedreader", "ffmpeg", "ffmpeg_motion",
      # "ffmpeg_noise", "fibaro", "fido", "file", "file_upload", "filesize",
      # "filter", "fints", "fire_tv", "fireservicerota", "firmata", "fitbit",
      # "fivem", "fixer", "fjaraskupan", "fleetgo", "flexit", "flexit_bacnet",
      # "flexom", "flic", "flick_electric", "flipr", "flo", "flock", "flume",
      # "flux", "flux_led", "folder", "folder_watcher", "foobot",
      # "forecast_solar", "forked_daapd", "fortios", "foscam", "foursquare",
      # "free_mobile", "freebox", "freedns", "freedompro", "fritz", "fritzbox",
      # "fritzbox_callmonitor", "fronius", "frontend", "frontier_silicon",
      # "fujitsu_anywair", "fujitsu_fglair", "fully_kiosk", "futurenow",
      # "fyta", "garadget", "garages_amsterdam", "gardena_bluetooth",
      # "gaviota", "gc100", "gdacs", "generic", "generic_hygrostat",
      # "generic_thermostat", "geniushub", "geo_json_events", "geo_location",
      # "geo_rss_events", "geocaching", "geofency", "geonetnz_quakes",
      # "geonetnz_volcano", "gios", "github", "gitlab_ci", "gitter", "glances",
      # "goalzero", "gogogate2", "goodwe", "google", "google_assistant",
      # "google_assistant_sdk", "google_cloud", "google_domains",
      # "google_generative_ai_conversation", "google_mail", "google_maps",
      # "google_photos", "google_pubsub", "google_sheets", "google_tasks",
      # "google_translate", "google_travel_time", "google_wifi", "govee_ble",
      # "govee_light_local", "gpsd", "gpslogger", "graphite", "gree",
      # "greeneye_monitor", "greenwave", "group", "growatt_server",
      # "gstreamer", "gtfs", "guardian", "habitica", "hardkernel", "hardware",
      # "harman_kardon_avr", "harmony", "hassio", "havana_shade",
      # "haveibeenpwned", "hddtemp", "hdmi_cec", "heatmiser", "heiwa", "heos",
      # "here_travel_time", "hexaom", "hi_kumo", "hikvision", "hikvisioncam",
      # "hisense_aehw4a1", "history", "history_stats", "hitron_coda", "hive",
      # "hko", "hlk_sw16", "holiday", "home_connect", "home_plus_control",
      # "homeassistant", "homeassistant_alerts", "homeassistant_green",
      # "homeassistant_hardware", "homeassistant_sky_connect",
      # "homeassistant_yellow", "homekit", "homekit_controller", "homematic",
      # "homematicip_cloud", "homewizard", "homeworks", "honeywell", "horizon",
      # "hp_ilo", "html5", "http", "huawei_lte", "hue", "huisbaasje",
      # "humidifier", "hunterdouglas_powerview", "hurrican_shutters_wholesale",
      # "husqvarna_automower", "huum", "hvv_departures", "hydrawise",
      # "hyperion", "ialarm", "iammeter", "iaqualink", "ibeacon", "icloud",
      # "idasen_desk", "idteck_prox", "ifttt", "iglo", "ign_sismologia", "ihc",
      # "image", "image_processing", "image_upload", "imap", "imgw_pib",
      # "improv_ble", "incomfort", "indianamichiganpower", "influxdb",
      # "inkbird", "input_boolean", "input_button", "input_datetime",
      # "input_number", "input_select", "input_text", "inspired_shades",
      # "insteon", "integration", "intellifire", "intent", "intent_script",
      # "intesishome", "ios", "iotawatt", "iotty", "iperf3", "ipma", "ipp",
      # "iqvia", "irish_rail_transport", "iron_os", "isal", "iskra",
      # "islamic_prayer_times", "ismartwindow", "israel_rail", "iss",
      # "ista_ecotrend", "isy994", "itach", "itunes", "izone", "jellyfin",
      # "jewish_calendar", "joaoapps_join", "juicenet", "justnimbus",
      # "jvc_projector", "kaiterra", "kaleidescape", "kankun", "keba",
      # "keenetic_ndms2", "kef", "kegtron", "kentuckypower", "keyboard",
      # "keyboard_remote", "keymitt_ble", "kira", "kitchen_sink", "kiwi",
      # "kmtronic", "knocki", "knx", "kodi", "konnected", "kostal_plenticore",
      # "kraken", "krispol", "kulersky", "kwb", "lacrosse", "lacrosse_view",
      # "lamarzocco", "lametric", "landisgyr_heat_meter", "lannouncer",
      # "lastfm", "launch_library", "laundrify", "lawn_mower", "lcn",
      # "ld2410_ble", "leaone", "led_ble", "legrand", "lektrico", "lg_netcast",
      # "lg_soundbar", "lidarr", "life360", "lifx", "lifx_cloud", "light",
      # "lightwave", "limitlessled", "linear_garage_door", "linkplay",
      # "linksys_smart", "linode", "linux_battery", "lirc", "litejet",
      # "litterrobot", "livisi", "llamalab_automate", "local_calendar",
      # "local_file", "local_ip", "local_todo", "locative", "lock", "logbook",
      # "logentries", "logger", "london_air", "london_underground", "lookin",
      # "loqed", "lovelace", "luci", "luftdaten", "lupusec", "lutron",
      # "lutron_caseta", "luxaflex", "lw12wifi", "lyric", "madeco", "madvr",
      # "mailgun", "manual", "manual_mqtt", "map", "marantz", "martec",
      # "marytts", "mastodon", "matrix", "matter", "maxcube", "mazda",
      # "mealie", "meater", "medcom_ble", "media_extractor", "media_player",
      # "media_source", "mediaroom", "melcloud", "melissa", "melnor", "meraki",
      # "mercury_nz", "message_bird", "met", "met_eireann", "meteo_france",
      # "meteoalarm", "meteoclimatic", "metoffice", "mfi", "microbees",
      # "microsoft", "microsoft_face", "microsoft_face_detect",
      # "microsoft_face_identify", "mijndomein_energie", "mikrotik", "mill",
      # "min_max", "minecraft_server", "mini_connected", "minio", "mjpeg",
      # "moat", "mobile_app", "mochad", "modbus", "modem_callerid",
      # "modern_forms", "moehlenhoff_alpha2", "mold_indicator",
      # "monarch_money", "monessen", "monoprice", "monzo", "moon", "mopeka",
      # "motion_blinds", "motionblinds_ble", "motioneye", "motionmount", "mpd",
      # "mqtt", "mqtt_eventstream", "mqtt_json", "mqtt_room",
      # "mqtt_statestream", "msteams", "mullvad", "mutesync", "my", "myq",
      # "mysensors", "mystrom", "mythicbeastsdns", "myuplink", "nad", "nam",
      # "namecheapdns", "nanoleaf", "neato", "nederlandse_spoorwegen",
      # "ness_alarm", "nest", "netatmo", "netdata", "netgear", "netgear_lte",
      # "netio", "network", "neurio_energy", "nexia", "nexity", "nextbus",
      # "nextcloud", "nextdns", "nfandroidtv", "nibe_heatpump", "nice_go",
      # "nightscout", "niko_home_control", "nilu", "nina", "nissan_leaf",
      # "nmap_tracker", "nmbs", "no_ip", "noaa_tides", "nobo_hub",
      # "norway_air", "notify", "notify_events", "notion", "nsw_fuel_station",
      # "nsw_rural_fire_service_feed", "nuheat", "nuki", "numato", "number",
      # "nut", "nutrichef", "nws", "nx584", "nyt_games", "nzbget",
      # "oasa_telematics", "obihai", "octoprint", "oem", "ohmconnect",
      # "ollama", "ombi", "omnilogic", "onboarding", "oncue", "ondilo_ico",
      # "onewire", "onkyo", "onvif", "open_meteo", "openai_conversation",
      # "openalpr_cloud", "openerz", "openevse", "openexchangerates",
      # "opengarage", "openhardwaremonitor", "openhome", "opensensemap",
      # "opensky", "opentherm_gw", "openuv", "openweathermap", "opnsense",
      # "opower", "opple", "oralb", "oru", "oru_opower", "orvibo", "osoenergy",
      # "osramlightify", "otbr", "otp", "ourgroceries", "overkiz",
      # "ovo_energy", "owntracks", "p1_monitor", "panasonic_bluray",
      # "panasonic_viera", "pandora", "panel_custom", "panel_iframe",
      # "pcs_lighting", "peco", "peco_opower", "pegel_online", "pencom",
      # "pepco", "permobil", "persistent_notification", "person", "pge",
      # "philips_js", "pi_hole", "picnic", "picotts", "pilight", "pinecil",
      # "ping", "pioneer", "piper", "pjlink", "plaato", "plant", "plex",
      # "plugwise", "plum_lightpad", "pocketcasts", "point", "poolsense",
      # "portlandgeneral", "powerwall", "private_ble_device", "profiler",
      # "progettihwsw", "proliphix", "prometheus", "prosegur", "prowl",
      # "proximity", "proxmoxve", "proxy", "prusalink", "ps4", "pse",
      # "psoklahoma", "pulseaudio_loopback", "pure_energie", "purpleair",
      # "push", "pushbullet", "pushover", "pushsafer", "pvoutput",
      # "pvpc_hourly_pricing", "pyload", "python_script", "qbittorrent",
      # "qingping", "qld_bushfire", "qnap", "qnap_qsw", "qrcode", "quadrafire",
      # "quantum_gateway", "qvr_pro", "qwikswitch", "rabbitair", "rachio",
      # "radarr", "radio_browser", "radiotherm", "rainbird", "raincloud",
      # "rainforest_eagle", "rainforest_raven", "rainmachine", "random",
      # "rapt_ble", "raspberry_pi", "raspyrfm", "raven_rock_mfg", "rdw",
      # "recollect_waste", "recorder", "recovery_mode", "recswitch", "reddit",
      # "refoss", "rejseplanen", "remember_the_milk", "remote",
      # "remote_rpi_gpio", "renault", "renson", "reolink", "repairs",
      # "repetier", "rest", "rest_command", "rexel", "rflink", "rfxtrx",
      # "rhasspy", "ridwell", "ring", "ripple", "risco",
      # "rituals_perfume_genie", "rmvtransport", "roborock", "rocketchat",
      # "roku", "romy", "roomba", "roon", "route53", "rova", "rpi_camera",
      # "rpi_power", "rss_feed_template", "rtorrent", "rtsp_to_webrtc",
      # "ruckus_unleashed", "russound_rio", "russound_rnet", "ruuvi_gateway",
      # "ruuvitag_ble", "rympro", "sabnzbd", "saj", "samsam", "samsungtv",
      # "sanix", "satel_integra", "scene", "schedule", "schlage", "schluter",
      # "scl", "scrape", "screenaway", "screenlogic", "script", "scsgate",
      # "search", "season", "select", "sendgrid", "sense", "sensibo",
      # "sensirion_ble", "sensor", "sensorblue", "sensorpro", "sensorpush",
      # "sensoterra", "sentry", "senz", "serial", "serial_pm", "sesame",
      # "seven_segments", "seventeentrack", "sfr_box", "sharkiq",
      # "shell_command", "shelly", "shodan", "shopping_list", "sia", "sigfox",
      # "sighthound", "signal_messenger", "simplefin", "simplepush",
      # "simplisafe", "simply_automated", "simu", "simulated", "sinch",
      # "siren", "sisyphus", "sky_hub", "skybeacon", "skybell", "slack",
      # "sleepiq", "slide", "slimproto", "sma", "smappee", "smart_blinds",
      # "smart_home", "smart_meter_texas", "smarther", "smartthings",
      # "smarttub", "smarty", "smhi", "smlight", "sms", "smtp", "smud",
      # "snapcast", "snips", "snmp", "snooz", "solaredge", "solaredge_local",
      # "solarlog", "solax", "soma", "somfy", "somfy_mylink", "sonarr",
      # "songpal", "sonos", "sony_projector", "soundtouch", "spaceapi", "spc",
      # "speedtestdotnet", "spider", "splunk", "spotify", "sql", "squeezebox",
      # "srp_energy", "ssdp", "starline", "starlingbank", "starlink",
      # "startca", "statistics", "statsd", "steam_online", "steamist",
      # "stiebel_eltron", "stookalert", "stookwijzer", "stream",
      # "streamlabswater", "stt", "subaru", "suez_water", "sun", "sunweg",
      # "supervisord", "supla", "surepetcare", "swepco",
      # "swiss_hydrological_data", "swiss_public_transport", "swisscom",
      # "switch", "switch_as_x", "switchbee", "switchbot", "switchbot_cloud",
      # "switcher_kis", "switchmate", "symfonisk", "syncthing", "syncthru",
      # "synology_chat", "synology_dsm", "synology_srm", "syslog",
      # "system_bridge", "system_health", "system_log", "systemmonitor",
      # "tado", "tag", "tailscale", "tailwind", "tami4", "tank_utility",
      # "tankerkoenig", "tapsaff", "tasmota", "tautulli", "tcp", "technove",
      # "ted5000", "tedee", "telegram", "telegram_bot", "tellduslive",
      # "tellstick", "telnet", "temper", "template", "tensorflow",
      # "tesla_fleet", "tesla_wall_connector", "teslemetry", "tessie", "text",
      # "thermobeacon", "thermoplus", "thermopro", "thethingsnetwork",
      # "thingspeak", "thinkingcleaner", "thomson", "thread", "threshold",
      # "tibber", "tikteck", "tile", "tilt_ble", "time", "time_date", "timer",
      # "tmb", "tod", "todo", "todoist", "tolo", "tomato", "tomorrowio",
      # "toon", "torque", "totalconnect", "touchline", "touchline_sl",
      # "tplink", "tplink_lte", "tplink_omada", "tplink_tapo", "traccar",
      # "traccar_server", "trace", "tractive", "tradfri",
      # "trafikverket_camera", "trafikverket_ferry", "trafikverket_train",
      # "trafikverket_weatherstation", "transmission", "transport_nsw",
      # "travisci", "trend", "triggercmd", "tts", "tuya", "twentemilieu",
      # "twilio", "twilio_call", "twilio_sms", "twinkly", "twitch", "twitter",
      # "ubiwizz", "ubus", "uk_transport", "ukraine_alarm", "ultraloq",
      # "unifi", "unifi_direct", "unifiled", "unifiprotect", "universal",
      # "upb", "upc_connect", "upcloud", "update", "upnp",
      # "uprise_smart_shades", "uptime", "uptimerobot", "usb",
      # "usgs_earthquakes_feed", "utility_meter", "uvc", "v2c", "vacuum",
      # "vallox", "valve", "vasttrafik", "velbus", "velux", "venstar", "vera",
      # "verisure", "vermont_castings", "versasense", "version", "vesync",
      # "viaggiatreno", "vicare", "vilfo", "vivotek", "vizio", "vlc",
      # "vlc_telnet", "vodafone_station", "voicerss", "voip", "volkszaehler",
      # "volumio", "volvooncall", "vulcan", "vultr", "w800rf32", "wake_on_lan",
      # "wake_word", "wallbox", "waqi", "water_heater", "waterfurnace",
      # "watson_iot", "watttime", "waze_travel_time", "weather", "weatherflow",
      # "weatherflow_cloud", "weatherkit", "webhook", "webmin", "webostv",
      # "websocket_api", "weheat", "wemo", "whirlpool", "whisper", "whois",
      # "wiffi", "wilight", "wirelesstag", "withings", "wiz", "wled", "wmspro",
      # "wolflink", "workday", "worldclock", "worldtidesinfo", "worxlandroid",
      # "ws66i", "wsdot", "wyoming", "x10", "xbox", "xeoma", "xiaomi",
      # "xiaomi_aqara", "xiaomi_ble", "xiaomi_miio", "xiaomi_tv", "xmpp",
      # "xs1", "yale", "yale_home", "yale_smart_alarm", "yalexs_ble", "yamaha",
      # "yamaha_musiccast", "yandex_transport", "yandextts", "yardian",
      # "yeelight", "yeelightsunflower", "yi", "yolink", "youless", "youtube",
      # "zabbix", "zamg", "zengge", "zeroconf", "zerproc", "zestimate",
      # "zeversolar", "zha", "zhong_hong", "ziggo_mediabox_xl", "zodiac",
      #p "zondergas", "zone", "zoneminder", "zwave_js", "zwave_me"
      ];
    config = {
      http = {
        server_host = [ "192.168.1.10" "10.1.3.10" ];
        server_port = 8123;
        # base_url = "https://${hostname}";
        # use_x_forwarded_for = true;
        # trusted_proxies = [ "127.0.0.1" ];
      };

      homeassistant = {
        latitude = "50.927305";
        longitude = "11.596704";
        unit_system = "metric";
        temperature_unit = "C";
        time_zone = "Europe/Berlin";
      };


      # frontend = { };
      # history = { };

      # prometheus = { };

      # sensor = [
      #   {
      #     platform = "fitbit";
      #     monitored_resources = [
      #       "activities/calories"
      #       "activities/distance"
      #       "activities/floors"
      #       "activities/heart"
      #       "activities/steps"
      #       "body/weight"
      #       "devices/battery"
      #       "sleep/efficiency"
      #     ];
      #   }
      #   { platform = "netatmo"; }
      # ];
    };

    extraPackages = python3Packages:
      with python3Packages; [
        pyturbojpeg
        numpy
        psycopg2
        gtts
        zlib-ng
      ];

  };
}
