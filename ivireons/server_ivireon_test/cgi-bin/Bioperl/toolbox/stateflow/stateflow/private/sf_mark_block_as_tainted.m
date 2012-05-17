function  sf_mark_block_as_tainted(sfBlkH)
% sf_mark_block_as_tainted
%   sf_mark_block_as_tainted
%   Neuters a Stateflow block if running in demo mode. 
%

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/12/01 08:07:23 $

    set_param(sfBlkH, 'openFcn', 'sf(''Private'', ''sf_demo_disclaimer'');');
    set_param(sfBlkH, 'initFcn', 'sf(''Private'', ''sf_demo_disclaimer'');error(''Preventing simulation in the absence of Stateflow license'');');
    set_param(sfBlkH, 'preSaveFcn', 'sf(''Private'', ''sf_demo_disclaimer'');error(''Preventing save to avoid model corruptions'');');
    if isempty(get_param(sfBlkH, 'ReferenceBlock')), 
        set_param(sfBlkH, 'ForegroundColor', 'red');
    else
        set_param(sfBlkH, 'BackgroundColor', 'red');
    end;
	set_param(sfBlkH,'MaskType', 'INVALID');
	set_param(sfBlkH, 'userdata', []);

