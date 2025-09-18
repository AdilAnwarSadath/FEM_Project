function K_global = assemble_stiffness(nodes, elements, IN)
    num_nodes = size(nodes,1);
    num_dof = 2*num_nodes;
    num_elements = size(elements,1);

    K_global = zeros(num_dof, num_dof);

    for j = 1:num_elements
        n1 = elements(j,1);
        n2 = elements(j,2);
        x1 = nodes(n1); x2 = nodes(n2);
        L = element_length(x1,x2);
        k_e = beam_stiffness(IN,L);
        dof = [2*n1-1, 2*n1, 2*n2-1, 2*n2];
        K_global(dof,dof) = K_global(dof,dof) + k_e;
    end
end