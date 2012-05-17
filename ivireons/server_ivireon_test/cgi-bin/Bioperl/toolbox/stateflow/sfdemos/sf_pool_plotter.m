function [p_init, v_init] = sf_pool_plotter(command, p, pock, t, varargin) %#ok
% GUI for plotting and interaction for the sf_pool demo.

%   Copyright 2007 The MathWorks, Inc.

    % p is an Nx2 array

    persistent h x_circle y_circle
    global sf_pool_init_pos sf_pool_init_vel
    
    N = size(p,1);
    p_init = zeros(N,2);
    v_init = zeros(N,2);

    if strcmpi(command, 'init') || isempty(h) || ~ishandle(h(1))
        fig = findobj('Tag', 'PoolTable');
        if isempty(fig)
            fig = figure('Tag', 'PoolTable', 'Name', 'A Pool Table');
        end
        figure(fig);
        clf;
        set(gca, 'xtick', [], 'ytick', [], 'ztick', [], 'drawMode', 'fast');

        ballRadius = 1;

        t = linspace(0, 2*pi, 40);
        x_circle = ballRadius*cos(t);
        y_circle = ballRadius*sin(t);

        h = zeros(size(p,1),1);

        x_off = 20;
        y_off = 0;
        n = 1;
        for i=1:5
            for j=1:i
                p_init(n,1) = x_off;
                p_init(n,2) = y_off + (j-1)*2*ballRadius;
                n = n + 1;
            end
            x_off = x_off + 2*ballRadius*cos(pi/6);
            y_off = y_off - 2*ballRadius*sin(pi/6);
        end

        p_init(n,1) = -20;
        p_init(n,2) = 0;

        hold on;
        cols = get(gca, 'ColorOrder');
        for i=1:N
            h(i) = patch(x_circle+p_init(i,1), ...
                         y_circle+p_init(i,2), ...
                         zeros(size(x_circle)), ...
                        'EdgeColor', 0.8*cols(mod(i-1,7)+1,:), ...
                        'FaceColor', cols(mod(i-1,7)+1,:));
        end
        axis equal;
        xlim([-45,45]);
        ylim([-23,23]);
        set(h(end), 'EdgeColor', [0 0 0], 'FaceColor', [1 1 1]);

        if isempty(sf_pool_init_pos)
            [p_init(end,:), v_init(end,:)] = getUserChosenPos(h(end), x_circle, y_circle);
        else
            % This is a hook used for testing purposes.
            p_init(end,:) = sf_pool_init_pos;
            v_init(end,:) = sf_pool_init_vel;
        end

    elseif strcmpi(command, 'draw')
        for i=1:N
            set(h(i),   'xdata', x_circle+p(i,1), ...
                        'ydata', y_circle+p(i,2));
        end
        title(sprintf('Animating... (%d balls pocketed)', length(find(pock == 1))));
        drawnow;

        % This helps us maintain a somewhat close relationship between the
        % simulation time and the real-world time.
        pause(0.03);
    end
end

function [pc, vc] = getUserChosenPos(h, xc, yc)

    set(gcf, 'WindowButtonMotionFcn', @onMouseMoveForPos);
    title('Choose the cue-ball''s position by clicking somewhere...');
    set(gca, 'DrawMode', 'fast');
    uiwait(gcf);

    hLine = 0;
    
    function cp = saturate(cp)
        if cp(1,1) < -44
            cp(1,1) = -44;
        elseif cp(1,1) > -19
            cp(1,1) = -19;
        end
        if abs(cp(1,2)) > 22
            cp(1,2) = sign(cp(1,2))*22;
        end
    end

    function cp = getCurPos(sat)
        cp = get(gca, 'CurrentPoint');
        cp = cp(1,1:2);
        if sat
            cp = saturate(cp);
        end
    end

    function onMouseMoveForPos(fig, event) %#ok<INUSD>
        cp = getCurPos(1);
        set(h, 'XData', xc+cp(1), 'YData', yc+cp(2));
        set(fig, 'WindowButtonDownFcn', @onMouseDown);
    end

    function onMouseDown(fig, event) %#ok<INUSD>
        cp = getCurPos(1);
        set(h, 'XData', xc+cp(1), 'YData', yc+cp(2));
        set(fig, 'WindowButtonDownFcn', '');
        set(fig, 'WindowButtonMotionFcn', @onMouseMoveForVel);
        title('Choose the initial velocity by clicking somewhere else...');
        pc = cp;
        hLine = line('Xdata', cp(1), 'YData', cp(2));
    end
    
    function onMouseMoveForVel(fig, event) %#ok<INUSD>
        cp = getCurPos(0);
        set(hLine, 'XData', [pc(1), cp(1)], 'YData', [pc(2), cp(2)]);
        set(fig, 'WindowButtonUpFcn', @onMouseUp);
    end

    function onMouseUp(fig, event) %#ok<INUSD>
        cp = getCurPos(0);
        vc = 2*(cp - pc);
        delete(hLine);
        set(fig, 'WindowButtonUpFcn', '');
        set(fig, 'WindowButtonMotionFcn', '');
        title('Animating...');
        uiresume(fig);
    end
end
