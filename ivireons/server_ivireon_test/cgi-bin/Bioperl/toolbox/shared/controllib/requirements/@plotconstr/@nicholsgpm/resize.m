function resize(Constr, action, SelectedMarkerIndex, idx)
%RESIZE   Keeps track of Phase Margin Constraint while resizing.

%   Author(s): A. Stothert
%   Revised:
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:10 $

% Persistent data
persistent PhaseOrigin index MouseEditData ResizePhase

% Handle info
hGroup   = Constr.Elements;
HostAx   = handle(hGroup.Parent);
XUnits   = Constr.xDisplayUnits;
YUnits   = Constr.yDisplayUnits;
EventMgr = Constr.EventManager;

% Process event
switch action
    case 'init'
        
        %Determine if we're resizing phase or gain
        if idx(1)
            ResizePhase = true;
        else
            ResizePhase = false;
        end
        
        % Initialize RESIZE
        MouseEditData = ctrluis.dataevent(EventMgr, 'MouseEdit', []);
        
        % Phase margin origin (in deg)
        %PhaseOrigin  = unitconv(Constr.Origin, XUnits, 'deg');
        PhaseOrigin  = unitconv(Constr.Origin, 'deg', Constr.Data.xUnits);
        
        if ResizePhase
            % Marker index: -1 if left marker moved, 1 otherwise
            index = 2 * SelectedMarkerIndex - 3;
        else
            % Marker index: 1 if top marker moved, -1 otherwise
            index = 3 - 2 * SelectedMarkerIndex;
        end
        
        % Initialize axes expand
        moveptr(HostAx, 'init');
        
    case 'acquire'
        % Track mouse location
        CP  = HostAx.CurrentPoint;
        if ResizePhase
            %CPX = index * (unitconv(CP(1,1), XUnits, 'deg') - PhaseOrigin);
            CPX = index * (unitconv(CP(1,1), XUnits, Constr.Data.xUnits) - PhaseOrigin);
            % Phase margin should be between [eps,180] degrees.
            CPX = max(min(CPX,unitconv(180,'deg',Constr.Data.xUnits)), 0.01*(diff(HostAx.Xlim)));
            
            % Update the constraint X data properties
            %Constr.MarginPha = CPX;
            Constr.Data.xCoords = CPX;
        else
            %CPY = index * unitconv(CP(1,2), YUnits, 'dB');
            CPY = index * unitconv(CP(1,2), YUnits, Constr.Data.yUnits);
            % Protect against very small gain margin values
            CPY = max(CPY, 0.01*(diff(HostAx.YLim)));
            % Update the constraint X data properties
            Constr.Data.yCoords = CPY;
        end
        
        % Update graphics and notify observers
        update(Constr)
        
        % Adjust axis limits if moved constraint gets out of focus
        % Issue MouseEdit event and attach updated extent of resized objects
        % (for axes rescale)
        Extent = Constr.extent;
        MouseEditData.Data = struct('XExtent', Extent(1:2), ...
            'YExtent', HostAx.Ylim, ...
            'X', CP(1,1), 'Y', CP(1,2));
        EventMgr.send('MouseEdit', MouseEditData)
        
        if ResizePhase
            % Update status bar with new requirement data
            MarginPhase = unitconv(Constr.Data.xCoords, Constr.Data.xUnits, XUnits);
            Status = sprintf('Phase margin requirement: %0.3g %s at %0.3g %s.', ...
                MarginPhase, XUnits, PhaseOrigin, XUnits);
        else
            % Update status bar with new requirement data
            MarginGain = unitconv(Constr.Data.yCoords, Constr.Data.yUnits, YUnits);
            Status = sprintf('Gain margin requirement: %0.3g %s at %0.3g %s.', ...
                MarginGain, YUnits, PhaseOrigin, XUnits);
        end
        EventMgr.poststatus(sprintf('%s', Status));
        
    case 'finish'
        % Clean up
        MouseEditData = [];
        
        % Update status
        EventMgr.newstatus(Constr.status('resize'));
        
        %Notify listeners of data source change
        Constr.Data.send('DataChanged');
        
end
