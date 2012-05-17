function [sys,x0,str,ts,simStateCompliance]=dblBallanim(t,x,u,flag,ts,y0) %#ok<INUSL>
%DBLBALLANIM S-function for animating the motion of double bouncing ball.
% y0 is the initial y position vector of all the objects

% Copyright 1990-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/12/01 07:50:47 $

handles = get_param([bdroot,'/Animation'],'UserData');

switch flag
    case 0 % Initialize
        set(handles.annotation1,'Visible','off')
        set(handles.annotation2,'Visible','off')
        set(handles.error,'Visible','off')
        sys = [0 0 0 4 0 0 1];
        str = [];
        x0  = [];
        ts  = [-1, 0];
        % specify that the simState for this s-function is same as the default
        simStateCompliance = 'DefaultSimState';
        sllastwarning([]);

    case 2 % Update animation
        % If grounds have moved, show annotations
        if u(3) ~= y0(3) && strcmpi(get(handles.annotation1,'Visible'),'off')
            % Create annotation for ground level 1 message
            set(handles.annotation1,'Visible','on')
        end
        if u(4) ~= y0(4) && strcmpi(get(handles.annotation2,'Visible'),'off')
            set(handles.annotation2,'Visible','on')
        end

        % Set new positions
        lineOffset = 1;
        set(handles.ball1,'YData',u(1));
        set(handles.ball2,'YData',u(2));
        set(handles.ground1,'YData',[u(3) u(3)] - lineOffset);
        set(handles.ground2,'YData',[u(4) u(4)] - lineOffset);
        drawnow;
        sys = [];

    case 4 % Return next sample hit
        ns = t/ts; % ns stores the number of samples
        sys = (1 + floor(ns + 1e-13*(1+ns)))*ts; % time of the next sample hit

    case {1, 3, 9 }
        sys=[];

    otherwise
        DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));
end
