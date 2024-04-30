% MATLAB controller for Webots
% File: wallfollower_controller.m
% Date: 30/04/2024
% Description: Wall follower robot using e-puck
% Author: Emmet Bloomer
%
function wallfollower_controller
    % Initialize Webots API for MATLAB
    wb_robot_init();

    TIME_STEP = wb_robot_get_basic_time_step();  % Get the time step of the current world
    MAX_SPEED = 6.28;  % Define maximum speed

    % Enable motors
    left_motor = wb_robot_get_device('left wheel motor');
    right_motor = wb_robot_get_device('right wheel motor');

    wb_motor_set_position(left_motor, inf);
    wb_motor_set_velocity(left_motor, 0.0);

    wb_motor_set_position(right_motor, inf);
    wb_motor_set_velocity(right_motor, 0.0);

    % Initialize proximity sensors
    prox_sensors = [];
    for ind = 0:7
        sensor_name = ['ps', num2str(ind)];
        prox_sensors(ind+1) = wb_robot_get_device(sensor_name);
        wb_distance_sensor_enable(prox_sensors(ind+1), TIME_STEP);
    end

    % Main control loop
    while wb_robot_step(TIME_STEP) ~= -1
        % Read the sensors
        sensor_values = zeros(1, 8);  % Store sensor values
        for ind = 0:7
            sensor_values(ind+1) = wb_distance_sensor_get_value(prox_sensors(ind+1));
        end

        % Process sensor data
        left_wall = sensor_values(6) > 80;  % Sensor 5 in MATLAB (index 6)
        left_corner = sensor_values(7) > 80;  % Sensor 6 in MATLAB (index 7)
        front_wall = sensor_values(8) > 80;  % Sensor 7 in MATLAB (index 8)

        left_speed = MAX_SPEED;
        right_speed = MAX_SPEED;

        if front_wall
            disp('Turn right');
            left_speed = MAX_SPEED;
            right_speed = -MAX_SPEED;
        else
            if left_wall
                disp('Forwards');
                left_speed = MAX_SPEED;
                right_speed = MAX_SPEED;
            else
                disp('Turn left');
                left_speed = MAX_SPEED / 8;
                right_speed = MAX_SPEED;
            end

            if left_corner
                disp('go back to wall');
                left_speed = MAX_SPEED;
                right_speed = MAX_SPEED / 8;
            end
        end

        % Set motor velocities based on sensor data
        wb_motor_set_velocity(left_motor, left_speed);
        wb_motor_set_velocity(right_motor, right_speed);
    end

    % Cleanup code
    wb_robot_cleanup();
end