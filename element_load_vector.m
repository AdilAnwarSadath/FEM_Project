function fe = element_load_vector(e, L, x1, loads)
    % e   : element index (1..num_elements)
    % L   : element length
    % x1  : coordinate of left node of element
    % loads: load structure created by define_loads
    fe = zeros(4,1); % [v1; theta1; v2; theta2]

    % ---- Distributed loads (numerical integration over overlap) ----
    if isfield(loads, 'distributed')
        for i = 1:length(loads.distributed)
            ld = loads.distributed(i);
            if ld.element == e
                % ld contains xL, xR, qL, qR for the overlap subinterval
                xL = ld.xL;
                xR = ld.xR;
                qL = ld.qL;
                qR = ld.qR;

                % map to local (s) coordinate: s in [0,1] along full element
                sL = (xL - x1)/L;
                sR = (xR - x1)/L;
                if sR <= sL
                    continue
                end

                % integrand: fe = \int_{xL}^{xR} N^T * q(x) dx
                % use 3-point Gauss on interval [sL, sR] for good accuracy
                % Hermite shape functions for transverse displacement:
                % N1(s) = 1 - 3 s^2 + 2 s^3
                % N2(s) = L*(s - 2 s^2 + s^3)
                % N3(s) = 3 s^2 - 2 s^3
                % N4(s) = L*(- s^2 + s^3)
                gauss_pts = [ -sqrt(3/5), 0, sqrt(3/5) ];
                gauss_wts = [ 5/9, 8/9, 5/9 ];

                % transform from standard [-1,1] to [sL,sR]: s = 0.5*(sR+sL) + 0.5*(sR-sL)*xi
                s_mid = 0.5*(sR + sL);
                s_half = 0.5*(sR - sL);

                fe_loc = zeros(4,1);
                for gp = 1:3
                    xi = gauss_pts(gp);
                    w = gauss_wts(gp);
                    s = s_mid + s_half * xi;        % local s
                    x = x1 + s * L;                 % global x coordinate
                    % linear q between qL at xL and qR at xR
                    if xR == xL
                        qx = 0;
                    else
                        qx = qL + (qR - qL) * ( (x - xL) / (xR - xL) );
                    end

                    % Hermite shape functions (note N2 and N4 include factor L)
                    N1 = 1 - 3*s^2 + 2*s^3;
                    N2 = L*( s - 2*s^2 + s^3 );
                    N3 = 3*s^2 - 2*s^3;
                    N4 = L*( -s^2 + s^3 );

                    Nvec = [N1; N2; N3; N4];

                    % Jacobian dx/ds = L
                    fe_loc = fe_loc + (Nvec * qx) * (w * s_half * L);
                end

                fe = fe + fe_loc;
            end
        end
    end

    % ---- Point loads inside element (exact equivalent nodal forces) ----
    if isfield(loads, 'point')
        for i = 1:length(loads.point)
            ld = loads.point(i);
            if ld.element == e
                a = ld.a;   % distance from left node
                b = L - a;  % distance from right node
                P = ld.value;

                % Equivalent nodal forces for a point load in an element
                % Using standard exact formula:
                fe = fe + P * [ b^2*(3*a+b)/(L^3);   % at v1
                               -a*b^2/(L^2);        % at theta1
                                a^2*(a+3*b)/(L^3);  % at v2
                               +a^2*b/(L^2) ];      % at theta2
            end
        end
    end
end