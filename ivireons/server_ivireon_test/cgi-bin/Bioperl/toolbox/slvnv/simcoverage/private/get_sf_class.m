function str = get_sf_class(isa,id)
% GET_SF_CLASS - Get the class name 
% corresponding to an isa value.
%

%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/04/14 20:02:15 $

persistent sfClassNames;
persistent sfClassIsa;
persistent sfStateTypes;
persistent functionTypeIdx;

if isempty(sfClassNames)
    sfClassIsa = [ sf('get','default','machine.isa') ...
            sf('get','default','chart.isa') ...
            sf('get','default','state.isa') ...
            sf('get','default','transition.isa') ...
            sf('get','default','junction.isa') ...
            sf('get','default','data.isa') ...
            sf('get','default','event.isa') ...
            sf('get','default','target.isa') ...
            sf('get','default','note.isa') ...
            sf('get','default','script.isa')];

    sfClassNames = {   'Machine', ...
                'Chart', ...
                'State', ...
                'Transition', ...
                'Junction', ...
                'Data', ...
                'Event', ...
                'Target', ...
                'Note',...
                'external eM Function'};

    sfStateTypes = {'State','State','Function','Box'};
    functionTypeIdx = find(strcmp(sfStateTypes,'Function'));
end

if nargin>1 && isa==sf('get','default','state.isa') && ~isempty(id)
    sfId = cv('get', id, 'slsfobj.handle');
    type = sf('get', sfId, 'state.type');
    if isempty(type)
        str = 'State';
    else
        type = type + 1; % 0 => 1 based indexing
        str = sfStateTypes{type};
        
        if type == functionTypeIdx
            if sf('Private', 'is_truth_table_fcn', sfId)
                str = 'Truth Table';
            elseif sf('Private', 'is_eml_fcn', sfId)
                str = 'eM Function';
            end
        end
    end
else
    str = sfClassNames{isa==sfClassIsa};
end