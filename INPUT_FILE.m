%andi adil
%% INPUT FILE (main)
clc; clearvars;

%% ----------------INPUT--------------------

% 1. Meshing Characteristics
IN.L               = 15;       % Length of Beam
IN.num_elements    = 300;      % Number of Elements in Mesh      

% Mesh Refining (optional) 
%elements_per_length = [100 5]; %[no_elements_per_length said_length]; -> 100 element per 5 meters in this case.
%IN.num_elements = (elements_per_length(1) * IN.L / elements_per_length(2));


% 2. Material Properties
IN.E = 2e11;   % Young's Modulus
IN.I = 7e-5;   % Second Moment of Area

%% 3. Loads

% Linear load/ Uniformly distrubuted load

LL.type = 'linear';
LL.x_start =        0;      % Starting position (x) of Uniform load
LL.x_end   =        5;      % Ending position (x) of Uniform load
LL.q_start_val =    0;      % q value at starting
LL.q_end_val   =    500;    % q value at ending

% Quadratic load/ Function based distrubuted load
%LL.type = 'function';
%LL.x_start =        0;      % Starting position (x) of Uniform load
%LL.x_end   =        5;      % Ending position (x) of Uniform load
%LL.q_func  =        @(x) 100 * x^2;       % function for load distribution

% Point load

PL.x_point  = 10;       % Position (x) of Point Load
PL.P        = 1000;     % Force 

%% 4. Boundary Conditions

% Position (x) of BC
BC.fixed_BC_position = [-1]; %set to -1 if such a boundary condition is not there.
BC.pinned_BC_position =[0];
BC.roller_BC_position = [15];








%% --------------Solver Functions----------------
    

[nodes, elements] = mesh_beam(IN); % meshing

loads = define_loads(nodes, elements, LL, PL);  % element wise loads

constrained_dof = dof(nodes, BC, IN); %BC constraints

f_global = assemble_force(nodes, elements, loads); % global force vector
K_global = assemble_stiffness(nodes, elements, IN); % global stiffness matrix


%disp('Global force vector f_global:')
%disp(f_global)

%disp('Global stiffness matrix K_global:')
%disp(K_global)

[u, f] = solve_global(constrained_dof, nodes, K_global, f_global); % solver

%disp('nodal_U:');
%disp(u); 

%disp('nodal_F:');
%disp(f);

v = visualise(IN, nodes, elements, u); % plotting

