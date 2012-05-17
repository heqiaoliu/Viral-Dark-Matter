function uiwaitbar(par, mode, value, position, colorvec)
% par: parent figure
% mode: create/update
% value: new/initial value
% position: position of the uiwaitbar in the parent in point unit
% colorvec: color of the waitbar - may not be supported on all platforms

%   Copyright 2009 The MathWorks, Inc.

persistent useJavaWaitbar;

if isempty(useJavaWaitbar)
    useJavaWaitbar = feature('HGUsingMATLABClasses');
end

error(nargchk(2, 4, nargin));

parentH = par; % parent handle

% create or update
isCreate = true;
if ~strcmpi(mode, 'create')
    isCreate = false;
end

waitValue = 0;
if (nargin < 3)
    if ~isCreate
        error('MATLAB:uitools:uiwaitbar', 'Value must be provided for ''update''.');
    end
elseif (value >=0) && (value <= 100)
   waitValue = value;
else
    error('MATLAB:uitools:uiwaitbar', 'Value must be between 0 and 100.');
end



if isCreate
    if useJavaWaitbar
        waitPos = [0 0 1 1];
        if (nargin > 3)
            if (all(size(position) == [1 4]))
                waitPos = position;
            else
                error('MATLAB:uitools:uiwaitbar', 'Unsupported Position vector. Value must be a [1x4] vector.');
            end
        end
        
        waitColor = java.awt.Color.RED;
        if (nargin > 4)
            if (all(size(colorvec) == [1 3]))
                waitColor = java.awt.Color(colorvec(1), colorvec(2), colorvec(3));
            else
                error('MATLAB:uitools:uiwaitbar', 'Unsupported Color vector. Value must be a [1x3] vector.');
            end
        end
             
        % Use the java implementation
        jw = javaObjectEDT('javax.swing.JProgressBar');
        % Set the min and max limits
        jw.setMinimum(0); jw.setMaximum(100);
        % Set the old style border
        jw.setBorder(javax.swing.BorderFactory.createLineBorder(java.awt.Color.BLACK));
        jw.setBorderPainted(true);
        % Set the old background
        jw.setBackground(java.awt.Color.WHITE);
        % Set the customizable color. Always RED for waitbar.m
        jw.setForeground(waitColor);
        
        jw.setValue(waitValue);
        [jw jwc] = javacomponent(jw, [1 1 1 1], parentH);
        set(jwc, 'Units', 'points', 'Position', waitPos);
    else
        % Turn on the axes and keep the title visible
        axHandle = findall(parentH, 'type', 'axes');
        set(axHandle, 'Visible', 'on');
        % Use the patch implementation
        xpatch = [0 waitValue waitValue 0];
        ypatch = [0 0 1 1];
        xline = [100 0 0 100 100];
        yline = [0 0 1 1 0];
        
        p = patch(xpatch,ypatch,'r', 'Parent', axHandle, 'EdgeColor','r','EraseMode','none');
        setappdata(p,'waitbar__data__',waitValue);
        
        l = line(xline,yline,'EraseMode','none');
        set(l,'Color',get(axHandle,'XColor'));
    end
else
    if useJavaWaitbar
        % Update the java implementation
        jwc = findobj(parentH, 'type', 'hgjavacomponent');
        jw = get(jwc, 'JavaPeer');
        jw.setValue(waitValue);
    else
        % Update the patch implementation
        p = findobj(parentH,'Type','patch');
        l = findobj(parentH,'Type','line');
        if isempty(parentH) || isempty(p) || isempty(l),
            error('MATLAB:waitbar:WaitbarHandlesNotFound', 'Couldn''t find waitbar handles.');
        end
        %xpatch = get(p,'XData');
        if (getappdata(p,'waitbar__data__') > waitValue)
            set(p,'EraseMode','normal');
        else
            set(p,'EraseMode','none');
        end
        setappdata(p,'waitbar__data__',waitValue);
        xpatch = [0 waitValue waitValue 0];
        set(p,'XData',xpatch);
        xline = get(l,'XData');
        set(l,'XData',xline);
    end
end
