function v = visualise(IN, nodes, elements, u)
    num_elements = size(elements, 1);
    figure
    for i = 1:num_elements
        n1 = elements(i, 1);
        n2 =  elements(i, 2);

        x1 = nodes(n1);
        x2 = nodes(n2);

        Le = x2-x1;

        dof = [2*n1-1, 2*n1, 2*n2-1, 2*n2];
        ue = u(dof); % nodal displacement values for the element i

        points_per_element = 20; %number of points between nodes between which interpolation is done
        
        x_coord = linspace(0, Le, points_per_element);
        v = zeros(size(x_coord));

        for j = 1:points_per_element
            %define the shape functions
            x = x_coord(j);
            x_bar = x_coord(j)/Le;
            N1 = 1 - 3*x_bar.^2 + 2*x_bar.^3;
            N2 = x * (1 - 2*x_bar + x_bar^2);
            N3 = 3*x_bar.^2 - 2*x_bar.^3;
            N4 = x * (-x_bar + x_bar.^2);

            N = [N1, N2, N3, N4];

            v(j) = [N(1) N(2) N(3) N(4)] * [ue(1) ue(2) ue(3) ue(4)]'; % interpolate the displacement values

        end
        x_global = linspace(x1, x2, points_per_element);
        plot(x_global, v, 'b-'); % plot the interpolated displacement
        hold on; % hold on to plot multiple elements
        xlabel("distance")
        ylabel("displacement")
        title("displacement")
    end
    hold off

    %recall dM/dx = V, and M = E*I*d2v/dx2, so V = EI*d3v/dx3
    %to find dv/dx take third derivative of v found in this code
    % that will give summation u(i) times third derivative of shape
    % function N(i)
    figure
    for i = 1:num_elements
        n1 = elements(i, 1);
        n2 =  elements(i, 2);

        x1 = nodes(n1);
        x2 = nodes(n2);

        Le = x2-x1;

        dof = [2*n1-1, 2*n1, 2*n2-1, 2*n2];
        ue = u(dof)'; % nodal displacement values for the element i

        points_per_element = 20; %number of points between nodes between which interpolation is done
        
        x_coord = linspace(0, Le, points_per_element);
        V = zeros(size(x_coord));

        for j = 1:points_per_element
            %define the shape functions
            d3N1 = 12/Le^3;
            d3N2 = 6/Le^2;
            d3N3 = -12/Le^3;
            d3N4 = 6/Le^2;

            N = [d3N1, d3N2, d3N3, d3N4];

            V(j) = IN.E*IN.I*[N(1) N(2) N(3) N(4)] * [ue(1) ue(2) ue(3) ue(4)]'; % interpolate the displacement values

        end
        x_global = linspace(x1, x2, points_per_element);
        
        plot(x_global, V, 'r-'); % plot the interpolated displacement
        hold on; % hold on to plot multiple elements
        xlabel("distance")
        ylabel("shear force")
        title("shear force")
    end
    hold off

    % bending moment uses the second derivative of displacement, so we need
    % the second derivative of the shape functions here
    figure
    for i = 1:num_elements
        n1 = elements(i, 1);
        n2 =  elements(i, 2);

        x1 = nodes(n1);
        x2 = nodes(n2);

        Le = x2-x1;

        dof = [2*n1-1, 2*n1, 2*n2-1, 2*n2];
        ue = u(dof); % nodal displacement values for the element i

        points_per_element = 20; %number of points between nodes between which interpolation is done
        
        x_coord = linspace(0, Le, points_per_element);
        M = zeros(size(x_coord));
    for j = 1:points_per_element
            %define the shape functions
            x = x_coord(j);
            x_bar = x_coord(j)/Le;
            d2N1 = (-6+12*x_bar)/Le^2;
            d2N2 = (-4+6*x_bar)/Le;
            d2N3 = (6-12*x_bar)/Le^2;
            d2N4 = (-2+6*x_bar)/Le;

            d2N = [d2N1, d2N2, d2N3, d2N4];

            M(j) = IN.E*IN.I* d2N * ue; % interpolate the displacement values

     end
        x_global = linspace(x1, x2, points_per_element);
        plot(x_global, M, 'b-'); % plot the interpolated displacement
        hold on; % hold on to plot multiple elements
        xlabel("distance")
        ylabel("bending moment")
        title("bending moment")
    end
    hold off
end