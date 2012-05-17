function [typeStruct, isFixdt] = resolve_type(varargin)
% isFixdt is set to true when the input string matches the 'fixdt(...)' pattern.
% This parameter is then used by Stateflow/EML wiring to detect 'fixdt('double')' and
% interpret it as fi-double type (in MATLAB, fixdt('double') is just a plain double).

% Copyright 2004-2008 The MathWorks, Inc.

typeStruct = [];
isFixdt = false;

if nargin == 1 && ischar(varargin{1})
    typeString = varargin{1};
    if ~isempty(regexp(typeString, '^\s*fixdt\s*\(.*\)\s*$', 'once'))
        typeStruct = eval(typeString);
        isFixdt = true;
    elseif ~isempty(regexp(typeString, '^\s*\w+\s*$', 'once'))
        try
            aliasChain = {typeString};
            typeStruct = evalin('base', typeString);
            while isa(typeStruct, 'Simulink.AliasType')
                typeString = typeStruct.BaseType;
                if any(strcmp(aliasChain, typeString))
                    typeStruct = [];
                    return;
                end
                aliasChain{end+1} = typeString;
                typeStruct = evalin('base', typeString);
            end
        end
        typeStruct = fixdt(typeString);                
    end
else
    typeStruct = fixdt(varargin{:});
end

typeStruct = struct(typeStruct);
