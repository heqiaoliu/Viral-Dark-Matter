function [tscellArray,Names]= tstoolUnpack(h,varargin)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

% Get a flat list of all the Simulink Timeseries members of a Simulink
% logged data object

tscellArray = {};
Names = {};
try
    members = struct2cell(get(h));
catch
    return;
end
for k = 1:length(members)
    if isa(members{k},'Simulink.Timeseries')
        tscellArray = {tscellArray{:},members{k}};
        if nargin==2 && strcmp(varargin{1},'add_tsarray_name')
            newName = [h.Name,'/',members{k}.Name];
        else
            newName = members{k}.Name;
        end
        Names = {Names{:},newName};
    elseif any(ismember(class(members{k}),{'Simulink.ModelDataLogs','Simulink.SubsysDataLogs',...
            'Simulink.StateflowDataLogs','Simulink.ScopeDataLogs'}))
        [c,newNames] = tstoolUnpack(members{k});
        tscellArray = {tscellArray{:},c{:}};
        Names = {Names{:},newNames{:}};
    elseif isa(members{k},'Simulink.TsArray')
        %[c,newNames]= tstoolUnpack(members{k},'add_tsarray_name');
        [c,newNames]= tstoolUnpack(members{k});
        tscellArray = {tscellArray{:},c{:}};
        Names = {Names{:},newNames{:}};
    end
end

