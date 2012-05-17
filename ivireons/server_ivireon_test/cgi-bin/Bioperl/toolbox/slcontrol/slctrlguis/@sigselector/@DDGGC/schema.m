function schema
    % 
    
	% Class definition for @selsigviewDDGView - the DDG implementation
	% of selected signal viewer widget.   
    
    %  Author(s): Erman Korkut
    %  Revised:
    % Copyright 1986-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:54:14 $
    
    % =====================================================================
    % Class Definition
    % =====================================================================
    hPackage      = findpackage('sigselector');
    hThisClass    = schema.class(hPackage, 'DDGGC');
    
    % =====================================================================
    % Class Methods
    % =====================================================================
    % getDialogSchema
    m = schema.method(hThisClass, 'getDialogSchema');
    s = m.Signature;
    s.varargin    = 'off';
    s.InputTypes  = {'handle', 'string'};
    s.OutputTypes = {'mxArray'};
    % applyFilter - executes when filter edit changes
    m = schema.method(hThisClass,'applyFilter');
    m.signature.varargin = 'off';
    m.signature.InputTypes={'handle','handle'};   
    % update - executes when underlying tool component changes
    m = schema.method(hThisClass,'update');
    m.signature.varargin = 'off';
    m.signature.InputTypes={'handle','MATLAB array','MATLAB array'};
    % clearFilter - executes when clear filter button is clicked
    m = schema.method(hThisClass,'clearFilter');
    m.signature.varargin = 'off';
    m.signature.InputTypes={'handle','handle'};
    % selectSignal - executes when a signal in the tree is selected
    m = schema.method(hThisClass,'selectSignal');
    m.signature.varargin = 'off';
    m.signature.InputTypes={'handle','handle'};
    % constructTreeItems - method that constructs tree given current
    % signals and filter
    m = schema.method(hThisClass,'constructTreeItems');
    m.signature.varargin = 'off';
    m.signature.InputTypes={'handle'};
    m.signature.OutputTypes = {'mxArray','mxArray'};
    % setMinimumSize = method to set the minimum size of the tree.
    m = schema.method(hThisClass,'setMinimumSize');
    m.signature.varargin = 'off';
    m.signature.InputTypes = {'handle','MATLAB array'};    
    
    % =====================================================================
    % Class Properties
    % =====================================================================    
    % The only public property is TCPeer. The clients should communicate
    % using TCPeer, not UDD class for DDG view.
    p = schema.prop(hThisClass, 'TCPeer', 'MATLAB array');
    p = schema.prop(hThisClass, 'Parent', 'MATLAB array');
    p = schema.prop(hThisClass, 'TCListeners', 'MATLAB array');    
    p.AccessFlags.PublicGet = 'off';
    p.AccessFlags.PublicSet = 'off';
    p = schema.prop(hThisClass, 'MinimumSize', 'MATLAB array');
    p.FactoryValue = [200 200];
    % =====================================================================
    % Class Events
    % =====================================================================
    schema.event(hThisClass,'TreeSelectionEvent');
    
end

