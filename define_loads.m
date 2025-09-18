function loads = define_loads(nodes, elements, LL, PL)


% =========================================================================
% This function defines a specific set of loads and processes them against
% a given beam geometry to determine the load on each element.
% It is now a self-contained function.
%
% INPUTS:
%   nodes    - A row vector of node coordinates, e.g., [0, 1, 2, 3].
%   elements - An Nx2 matrix connecting nodes to form elements, e.g., [1 2; 2 3].
%
% OUTPUT:
%   loads    - A structure with fields 'distributed' and 'point'.
% =========================================================================

% 1. DEFINE THE LOADS
% We will create a cell array to hold all load definitions.
load_definitions = {};

% --- EDITABLE LOAD EXAMPLE: QUADRATIC FUNCTION ---
% To use this load, uncomment the following 5 lines and comment out the
% 'LINEARLY INCREASING' load section below.
%
% % Define a quadratic load q(x) = -20*x^2 + 150*x + 50 from x=2 to x=8
% quad_load.type = 'distributed';
% quad_load.func = @(x) -20*x.^2 + 150*x + 50; % EDIT THIS FUNCTION
% quad_load.x_start = 2;
% quad_load.x_end = 8;
% load_definitions{end+1} = quad_load;


% --- Load 1: The original LINEARLY INCREASING distributed load ---
% This load started at q=0 at x=0 and ended at q=500 at x=5.
% The function for a line is y = mx + c.
% m = (y2-y1)/(x2-x1) = (500-0)/(5-0) = 100.
% c = 0 (since it passes through the origin).
% So, the function is q(x) = 100*x.
if strcmp(LL.type, 'linear')
    dist_load.type = 'distributed';
    dist_load.func = @(x) (LL.q_end_val-LL.q_start_val)/(LL.x_end-LL.x_start) * (x - LL.x_start) + LL.q_start_val; % Function for the original linear load
    dist_load.x_start = LL.x_start;
    dist_load.x_end = LL.x_end;
    load_definitions{end+1} = dist_load;

else 
    dist_load.type = 'distributed';
    dist_load.func = LL.q_func; % Function for the function based load
    dist_load.x_start = LL.x_start;
    dist_load.x_end = LL.x_end;
    load_definitions{end+1} = dist_load;
end

% --- Load 2: The original POINT LOAD ---
% A force of 1000 N at x = 10 meters.
point_load.type = 'point';
point_load.location = PL.x_point;
point_load.value = PL.P;
load_definitions{end+1} = point_load;


% 2. PROCESS THE DEFINED LOADS
% Initialize the output structure
loads.distributed = [];
loads.point = [];

% Loop through each load defined in the cell array
for i = 1:length(load_definitions)
    current_load = load_definitions{i};

    % --- Process DISTRIBUTED loads ---
    if strcmp(current_load.type, 'distributed')
        x_start = current_load.x_start;
        x_end   = current_load.x_end;
        q_func  = current_load.func;

        for e = 1:size(elements, 1)
            x1 = nodes(elements(e, 1));
            x2 = nodes(elements(e, 2));

            % Find the overlap between the element and the load's range
            xL = max(x1, x_start);
            xR = min(x2, x_end);

            % If there is a valid overlap, process it
            if xR > xL
                % Calculate load intensities by calling the function handle
                qL = q_func(xL);
                qR = q_func(xR);

                % Assign the calculated load data to the output structure
                loads.distributed(end+1).element = e;
                loads.distributed(end).type    = 'function';
                loads.distributed(end).xL      = xL;
                loads.distributed(end).xR      = xR;
                loads.distributed(end).qL      = qL;
                loads.distributed(end).qR      = qR;
            end
        end
    end

    % --- Process POINT loads ---
    if strcmp(current_load.type, 'point')
        x_point = current_load.location;
        P       = current_load.value;

        for e = 1:size(elements, 1)
            x1 = nodes(elements(e, 1));
            x2 = nodes(elements(e, 2));

            % Check if the point is within the element's bounds
            if x1 <= x_point && x_point <= x2
                a = x_point - x1;
                L = x2 - x1;

                loads.point(end+1).element = e;
                loads.point(end).type    = 'force';
                loads.point(end).value   = P;
                loads.point(end).a       = a;
                loads.point(end).L       = L;
                break; % Stop after finding the correct element
            end
        end
    end
end

end

