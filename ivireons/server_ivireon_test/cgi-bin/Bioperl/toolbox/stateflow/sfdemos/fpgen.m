function fpgen(axisLimits, topAltitude)

if nargin == 2, % setup
   
% create drawing/plotting figure
figure('tag', 'drawing');
plot(0,0);
grid on;
axis(axisLimits);
[fpX, fpY] = ginput(20);
fpZ = topAltitude*ones(length(fpX), 1);
fpXYZ = [fpX'; fpY'; fpZ'];

% construct string for listbox
xyzString = {};
for k = 1:length(fpX),
    xyzString = [xyzString, {sprintf('%0.2f, %0.2f, %0.2f', fpX(k), fpY(k), fpZ(k))}];
end    

% create points GUI
pointsGUI = figure('pos', [100, 100, 210, 400], 'vis', 'off', ...
                   'handlevisibility', 'callback', ...
                   'menubar', 'none', ...
                   'numbertitle', 'off', ...
                   'name', 'Waypoint GUI', ...
                   'tag', 'pointsGUI');

guiHandle(1) = uicontrol('style', 'listbox', ...
                       'pos', [10, 85, 200, 310], ...
                       'callback', 'fpgen(''Pick Z Value'')', ...
                       'string', xyzString, ...
                       'userdata', fpXYZ, ...
                       'parent', pointsGUI);
                   
guiHandle(2) = uicontrol('style', 'edit', ...
                  'pos', [10, 60, 60, 20], ...
                  'horizontalalignment', 'right', ...
                  'callback', 'fpgen(''Update Z Value'')', ...
                       'parent', pointsGUI);
              
guiHandle(3) = uicontrol('style', 'push', ...
                  'pos', [10, 35, 60, 20], ...
                  'string', 'Re-Pick', ...
                  'callback', 'fpgen(''Re-Pick'')', ...
                  'parent', pointsGUI);
              
guiHandle(4) = uicontrol('style', 'edit', ...
                  'pos', [80, 60, 100, 20], ...
                  'horizontalalignment', 'right', ...
                  'string', num2str(axisLimits), ...
                       'parent', pointsGUI);
              
guiHandle(5) = uicontrol('style', 'edit', ...
                  'pos', [80, 35, 100, 20], ...
                  'horizontalalignment', 'right', ...
                  'string', num2str(topAltitude), ...
                       'parent', pointsGUI); 
                   
guiHandle(6) = uicontrol('style', 'push', ...
                  'pos', [10, 5, 60, 20], ...
                  'string', 'Export', ...
                  'callback', 'fpgen(''Export'')', ...
                       'parent', pointsGUI);
                   
              
set(pointsGUI, 'userdata', guiHandle, 'vis', 'on');

plotfp(fpXYZ);
              
else % handle callbacks

    guiHandle = get(findobj(allchild(0), 'tag', 'pointsGUI'), 'userdata');
    fpXYZ = get(guiHandle(1), 'userdata');
    
    switch axisLimits,
        case('Pick Z Value'),
            lbValue = get(guiHandle(1), 'value');
            set(guiHandle(2), 'string', fpXYZ(3, lbValue));            
            
        case('Update Z Value'),
            lbValue = get(guiHandle(1), 'value');
            fpXYZ(3, lbValue) = str2num(get(guiHandle(2), 'string'));
            
            xyzString = {};
            for k = 1:size(fpXYZ, 2),
                xyzString = [xyzString, {sprintf('%0.2f, %0.2f, %0.2f', fpXYZ(1, k), fpXYZ(2, k), fpXYZ(3, k))}];
            end 
            
            set(guiHandle(1), 'string', xyzString, ...
                              'userdata', fpXYZ);
                          
            plotfp(fpXYZ);
            
        case('Re-Pick'),
            
            figure(findobj(allchild(0), 'tag', 'drawing'));
            plot(0,0);
            grid on;
            axis(str2num(get(guiHandle(4), 'string')));
            [fpX, fpY] = ginput(20);
            fpZ = str2double(get(guiHandle(5), 'string'))*ones(length(fpX), 1);
            fpXYZ = [fpX'; fpY'; fpZ'];

            % construct string for listbox
            xyzString = {};
            for k = 1:length(fpX),
                xyzString = [xyzString, {sprintf('%0.2f, %0.2f, %0.2f', fpX(k), fpY(k), fpZ(k))}];
            end 
            
            set(guiHandle(1), 'string', xyzString, ...
                              'userdata', fpXYZ);
                          
            plotfp(fpXYZ);
            
        case('Export'),
            
            fpPTS = plotfp(fpXYZ, 'output');
            assignin('base', 'fpPTS', fpPTS);
            evalin('base', 'flightpoints');
    end
    
end

function fpPTS = plotfp(fpXYZ, outputMode)

if nargin == 1,
    figure(findobj(allchild(0), 'tag', 'drawing'));
    stem3 (fpXYZ(1, :), fpXYZ(2, :), fpXYZ(3, :), 'DisplayName', 'fpX, fpY, fpZ');
    hold on
    fnplt(cscvn(fpXYZ),'r',2);
    hold off;
    
else
    fpPTS = fnplt(cscvn(fpXYZ),'r',2);
end    
