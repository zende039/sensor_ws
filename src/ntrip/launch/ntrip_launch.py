from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration

def generate_launch_description():
    # Declare the log level argument
    log_level = DeclareLaunchArgument(
        'log_level',
        default_value='info',
        description='Logging level (debug, info, warn, error, fatal)',
        choices=['debug', 'info', 'warn', 'error', 'fatal']
    )

    # Create the node configuration
    ntrip_node = Node(
        package='ntrip',
        executable='ntrip',
        name='ntrip_client',
        output='screen',
        parameters=[{
            # NTRIP Server Configuration
            # EarthScope default configuration.
            'host': 'ntrip.earthscope.org',
            'port': 2101,
            'mountpoint': 'P803_RTCM3P3',
            'username': 'mystifying_chandrasekhar',
            'password': 'FEZh0kd1ncgF9Oi3',

            # Legacy Minnesota CORS configuration kept here for quick switching.
            # 'host': 'mncors.dot.state.mn.us',
            # 'port': 9000,
            # 'mountpoint': 'RTCM_34_NAD83(2011)',
            # 'username': 'UofM/RushikeshZ',
            # 'password': 'auto2255',

            # Generic template for other casters.
            # 'host': '203.107.45.154',
            # 'port': 8002,
            # 'mountpoint': 'AUTO',
            # 'username': 'Your_User_Name',
            # 'password': 'Your_Password',
		
            # NMEA and Update Rate Configuration
            'nmea_input_rate': 4.0,    # Input NMEA rate in Hz (default: 4.0)
            'update_rate': 1.0,        # Desired rate for sending GGA messages (Hz)

            # Connection Configuration
            'reconnect_delay': 1.0,    # Delay between reconnection attempts (seconds)
            'max_reconnect_attempts': 0,  # 0 for infinite attempts

            # Debug Configuration
            'send_default_gga': True,    # Set to False if using real GNSS data
            'debug': True,              # Set to True for detailed debug output
            'output_rtcm_details': True  # Set to True for RTCM message details
        }],
        # Topic Remapping
        remappings=[
            ('nmea', 'nmea'),  # Input NMEA topic
            ('rtcm', 'rtcm')   # Output RTCM topic
        ],
        # Add arguments for log level
        arguments=['--ros-args', '--log-level', LaunchConfiguration('log_level')]
    )

    return LaunchDescription([
        log_level,  # Include the log level argument
        ntrip_node  # Include the node configuration
    ])			
