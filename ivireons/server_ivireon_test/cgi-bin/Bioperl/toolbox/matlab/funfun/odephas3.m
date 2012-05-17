function status = odephas3(t,y,flag,varargin)
%ODEPHAS3 3-D phase plane ODE output function.
%   When the function odephas3 is passed to an ODE solver as the 'OutputFcn'
%   property, i.e. options = odeset('OutputFcn',@odephas3), the solver
%   calls ODEPHAS3(T,Y,'') after every timestep.  The ODEPHAS3 function plots
%   the first three components of the solution it is passed as it is
%   computed, adapting the axis limits of the plot dynamically.  To plot
%   three particular components, specify their indices in the 'OutputSel'
%   property passed to the ODE solver.
%   
%   At the start of integration, a solver calls ODEPHAS3(TSPAN,Y0,'init') to
%   initialize the output function.  After each integration step to new time
%   point T with solution vector Y the solver calls STATUS = ODEPHAS3(T,Y,'').
%   If the solver's 'Refine' property is greater than one (see ODESET), then
%   T is a column vector containing all new output times and Y is an array
%   comprised of corresponding column vectors.  The STATUS return value is 1
%   if the STOP button has been pressed and 0 otherwise.  When the
%   integration is complete, the solver calls ODEPHAS3([],[],'done').
%   
%   See also ODEPLOT, ODEPHAS2, ODEPRINT, ODE45, ODE15S, ODESET.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.27.4.8 $  $Date: 2009/01/08 18:46:07 $

persistent TARGET_FIGURE TARGET_AXIS TARGET_HGCLASS

status = 0;                             % Assume stop button wasn't pushed.
chunk = 128;                            % Memory is allocated in chunks.

drawnowDelay = 2;  % HGUsingMATLABClasses - postpone drawnow for performance reasons
doDrawnow = true;  % default

if nargin < 3 || isempty(flag) % odephas3(t,y) [v5 syntax] or odephas3(t,y,'')

    if (isempty(TARGET_FIGURE) || isempty(TARGET_AXIS))
        
        error('MATLAB:odephas3:NotCalledWithInit', ...
              'ODEPHAS3 has not been initialized. Use syntax ODEPHAS3(tspan,y0,''init'').');
        
    elseif (ishghandle(TARGET_FIGURE) && ishghandle(TARGET_AXIS))  % figure still open   

        try
    
            ud = get(TARGET_FIGURE,'UserData');

            % Append y to ud.y, allocating if necessary.
            nt = length(t);
            chunk = max(chunk,nt);
            rows = size(ud.y,1);
            oldi = ud.i;
            newi = oldi + nt;
            if newi > rows
                ud.y = [ud.y; zeros(chunk,3)];
            end
            ud.y(oldi+1:newi,:) = y(1:3,:).';
            ud.i = newi;
            
            if TARGET_HGCLASS
                ploti = ud.ploti;
                doDrawnow = (ud.drawnowSteps > drawnowDelay);
                if doDrawnow
                    ud.ploti = newi;  
                    ud.drawnowSteps = 1;
                else
                    ud.drawnowSteps = ud.drawnowSteps + 1;
                end
            end                
            
            set(TARGET_FIGURE,'UserData',ud);
        
            if ud.stop == 1                       % Has stop button been pushed?
                status = 1;
            else
                % Rather than redraw all of the data every timestep, we will simply move
                % the line segments for the new data, not erasing.  But if the data has
                % moved out of the axis range, we redraw everything.
                xlim = get(TARGET_AXIS,'xlim');
                ylim = get(TARGET_AXIS,'ylim');
                zlim = get(TARGET_AXIS,'zlim');        
            
                % Replot everything if out of axis range or if just initialized.
                if (oldi == 2) || ...
                          (min(y(1,:)) < xlim(1)) || (xlim(2) < max(y(1,:))) || ...
                          (min(y(2,:)) < ylim(1)) || (ylim(2) < max(y(2,:))) || ...
                          (min(y(3,:)) < zlim(1)) || (zlim(2) < max(y(3,:)))
                    set(ud.lines, ...
                        'Xdata',ud.y(1:newi,1), ...
                        'Ydata',ud.y(1:newi,2), ...
                        'Zdata',ud.y(1:newi,3));
                    set(ud.line, ...
                        'Xdata',ud.y(oldi:newi,1), ...
                        'Ydata',ud.y(oldi:newi,2), ...
                        'Zdata',ud.y(oldi:newi,3));
                else
                    % Plot only the new data.
                    if doDrawnow                         
                        if TARGET_HGCLASS  % start new segment           
                            if ~ishold
                                hold on
                                plot3(ud.y(ploti:newi,1),...
                                      ud.y(ploti:newi,2),...
                                      ud.y(ploti:newi,3),'-o');                    
                                hold off
                            else
                                plot3(ud.y(ploti:newi,1),...
                                      ud.y(ploti:newi,2),...
                                      ud.y(ploti:newi,3),'-o');                                                    
                            end
                            view(3);
                        else
                            co = get(TARGET_AXIS,'ColorOrder');
                
                            set(ud.line,'Color',co(1,:));     % "erase" old segment
                            set(ud.line, ...
                                'Xdata',ud.y(oldi:newi,1), ...
                                'Ydata',ud.y(oldi:newi,2), ...
                                'Zdata',ud.y(oldi:newi,3), ...
                                'Color',co(2,:));
                        end
                    end
                end
            end
            
        catch ME
            error('MATLAB:odephas3:ErrorUpdatingWindow',...
                  'Error updating the ODEPHAS3 window. solution data may have been corrupted. %s',...
                  ME.message);
        end                             
    end
    
else
    
    switch(flag)
      case 'init'                           % odephas3(tspan,y0,'init')
        TARGET_HGCLASS = feature('HGUsingMATLABClasses');
        
        ud.y = zeros(chunk,3);
        ud.i = 1;
        ud.y(1,:) = y(1:3).';
        
        % Rather than redraw all data at every timestep, we will simply move
        % the last line segment along, not erasing it.
        f = figure(gcf);
        
        TARGET_FIGURE = f;
        TARGET_AXIS = gca;                

         if TARGET_HGCLASS
            EraseMode = {};
            ud.ploti = 1;                            
            ud.drawnowSteps = 1;                            
        else            
            EraseMode = {'EraseMode','none'};
        end
        
        co = get(TARGET_AXIS,'ColorOrder');
        
        if ~ishold
            ud.lines = plot3(y(1),y(2),y(3),'-o');
            hold on
            ud.line = plot3(y(1),y(2),y(3),'-o','Color',co(2,:),EraseMode{:});
            hold off
        else
            ud.lines = plot3(y(1),y(2),y(3),'-o',EraseMode{:});
            ud.line = plot3(y(1),y(2),y(3),'-o','Color',co(2,:),EraseMode{:});
        end
        
        set(TARGET_AXIS,'DrawMode','fast');         % Draw things in creation order.
        grid on
        
        % The STOP button.
        h = findobj(f,'Tag','stop');
        if isempty(h)
            ud.stop = 0;
            pos = get(0,'DefaultUicontrolPosition');
            pos(1) = pos(1) - 15;
            pos(2) = pos(2) - 15;
            uicontrol( ...
                'Style','push', ...
                'String','Stop', ...
                'Position',pos, ...
                'Callback',@StopButtonCallback, ...
                'Tag','stop');
        else
            set(h,'Visible','on');            % make sure it's visible
            if ishold
                oud = get(f,'UserData');
                ud.stop = oud.stop;             % don't change old ud.stop status
            else
                ud.stop = 0;
            end
        end
        set(f,'UserData',ud);
        
      case 'done'                           % odephas3([],[],'done')

        f = TARGET_FIGURE;
        TARGET_FIGURE = [];    
        TARGET_AXIS = [];

        if ishghandle(f)        
            ud = get(f,'UserData');
            ud.y = ud.y(1:ud.i,:);
            set(f,'UserData',ud);
            set(ud.lines, ...
                'Xdata',ud.y(1:ud.i,1), ...
                'Ydata',ud.y(1:ud.i,2), ...
                'Zdata',ud.y(1:ud.i,3));
            if ~ishold
                set(findobj(f,'Tag','stop'),'Visible','off');
                refresh;                          % redraw figure to remove marker frags
            end
        end
        
    end
end

if doDrawnow
    drawnow;
end

end  % odephas3


% --------------------------------------------------------------------------
% Sub-function
%

function StopButtonCallback(src,eventdata)
    ud = get(gcbf,'UserData'); 
    ud.stop = 1; 
    set(gcbf,'UserData',ud);    
end  % StopButtonCallback

% --------------------------------------------------------------------------
