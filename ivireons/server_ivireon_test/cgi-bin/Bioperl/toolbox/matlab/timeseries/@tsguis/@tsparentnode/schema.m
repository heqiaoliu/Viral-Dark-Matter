function schema
% Defines properties for @tsnode class.
%
%   Author(s): James G. Owen
%   Copyright 2004-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $ $Date: 2005/05/27 14:18:57 $


%% Register class (subclass)
pparent = findpackage('tsexplorer');
c = schema.class(findpackage('tsguis'), 'tsparentnode', ...
    findclass(pparent,'node'));

%The parent node keeps information on its child types.
p = schema.prop(c,'legalChildren','MATLAB array');
p.FactoryValue = {'timeseries','tscollection','tsdata.timeseries','tsdata.tscollection'};
p.Description = ['List of all the valid timeseries data',...
    ' objects (non-Simulink) currently allowed in the TSTOOL GUI under the main Time Series node.'];
p.AccessFlags.PublicSet = 'off';