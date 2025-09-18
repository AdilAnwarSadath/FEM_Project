function f_global = assemble_force(nodes, elements, loads)
    num_nodes = size(nodes,1);
    num_dof = 2*num_nodes;
    num_elements = size(elements,1);

    f_global = zeros(num_dof,1);

    for e = 1:num_elements
        n1 = elements(e,1);
        n2 = elements(e,2);
        x1 = nodes(n1); x2 = nodes(n2);
        L = element_length(x1,x2);

        % call using element index e, element length L, element coords x1
        fe = element_load_vector(e, L, x1, loads);

        dof = [2*n1-1, 2*n1, 2*n2-1, 2*n2];
        f_global(dof) = f_global(dof) + fe;
    end
end