function [nodes, elements] = mesh_beam(IN)

    nodes = linspace(0, IN.L, IN.num_elements + 1)'; % column
    elements = zeros(IN.num_elements, 2);
    for i = 1:IN.num_elements
        elements(i,:) = [i, i+1];
    end
end
