function [u, f] = solve_global(constrained_dof, nodes, K_global, f_global) %change the node_no to nodes
    number_of_nodes = size(nodes,1);
    % constrained_nodes = [1, 4]; %change based on where roller and pin are
    % constrained_dof = 2*constrained_nodes-1;
    u = zeros(2*number_of_nodes, 1);
    free_dof = setdiff(1: 2*number_of_nodes, constrained_dof); %removed constrained dof
    u(free_dof) = K_global(free_dof,free_dof)\f_global(free_dof);
    
    f =  K_global * u;
end