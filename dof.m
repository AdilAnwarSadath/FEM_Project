function constrained_dof = dof(nodes, BC ,IN)
    

    num_nodes = size(nodes,1);

    fixed_node = round(BC.fixed_BC_position*(num_nodes-1)/IN.L + 1);
    pinned_node = round(BC.pinned_BC_position*(num_nodes-1)/IN.L + 1);
    roller_node = round(BC.roller_BC_position*(num_nodes-1)/IN.L + 1);

    constrained_dof = [];

    if fixed_node ~=-1
        constrained_dof = [constrained_dof fixed_node*2 - 1, fixed_node * 2 ];
    end

    if pinned_node ~=-1
        constrained_dof = [constrained_dof pinned_node*2 - 1];
    end

    if roller_node ~=-1
        constrained_dof = [constrained_dof roller_node*2-1];
    end

end