function resize(Constr, action, SelectedMarkerIndex)
%RESIZE   Keeps track of Closed-loop Peak Gain while resizing.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:27 $

% Persistent data
persistent PhaseOrigin MouseEditData

% Handle info
hGroup   = Constr.Elements;
HostAx   = handle(hGroup.Parent);
XUnits   = Constr.xDisplayUnits;
YUnits   = Constr.yDisplayUnits;
EventMgr = Constr.EventManager;

% Process event
switch action
    case 'init'
        % Initialize RESIZE
        MouseEditData = ctrluis.dataevent(EventMgr, 'MouseEdit', []);
        
        % Phase origin (in deg)
        PhaseOrigin  = unitconv(Constr.OriginPha, Constr.Data.getData('xUnits'), XUnits);
        
        % Initialize axes expand
        moveptr(HostAx, 'init');
        
    case 'acquire'
        % Track mouse location
        CP = HostAx.CurrentPoint;
        CPX = unitconv(CP(1,1), XUnits, 'rad');
        CPY = unitconv(CP(1,2), YUnits, 'abs');
        
        % Open-loop position
        G = CPY * exp(1j*CPX);
        
        % Update the constraint X data properties in dB.
        Constr.PeakGain = unitconv(20*log10(abs(G / (1+G))),'db',Constr.Data.getData('yUnits'));
        PeakGain = unitconv(Constr.PeakGain, Constr.Data.getData('yUnits'), YUnits);
        
        % Update graphics and notify observers
        update(Constr)
        
        % Adjust axis limits if moved constraint gets out of focus
        % Issue MouseEdit event and attach updated extent of resized objects
        % (for axes rescale)
        Extent = Constr.extent;
        MouseEditData.Data = struct('XExtent', Extent(1:2), ...
            'YExtent', Extent(3:4), ...
            'X', CP(1,1), 'Y', CP(1,2));
        EventMgr.send('MouseEdit', MouseEditData)
        
        % Update status bar with gradient of constraint line
        Status = sprintf('Closed-loop peak gain requirement: %0.3g %s at %0.3g %s.', ...
            PeakGain, YUnits, PhaseOrigin, XUnits);
        EventMgr.poststatus(sprintf('%s', Status));
        
    case 'finish'
        % Clean up
        MouseEditData = [];
        
        % Update status
        EventMgr.newstatus(Constr.status('resize'));
        
        %Notify listeners of data source change
        Constr.Data.send('DataChanged');
        
end
