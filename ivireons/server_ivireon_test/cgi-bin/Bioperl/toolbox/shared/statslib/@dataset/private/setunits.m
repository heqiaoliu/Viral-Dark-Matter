function a = setunits(a,newunits)
%SETUNITS Set dataset array Units property.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:16 $

if nargin < 2
    error('stats:dataset:setunits:TooFewInputs', ...
          'Requires at least two inputs.');
end

if nargin == 2
    if isempty(newunits)
        a.props.Units = {}; % do this for cosmetics
        return
    end
    if numel(newunits) ~= a.nvars
        error('stats:dataset:setunits:WrongLength', ...
              'NEWUNITS must have one element for each variable in A.');
    elseif ~iscell(newunits)
        error('stats:dataset:setunits:InvalidUnits', ...
              'NEWUNITS must be a cell array of strings.');
    elseif ~all(cellfun(@isstring,newunits))
        error('stats:dataset:setunits:InvalidUnits', ...
              'NEWUNITS must contain strings.');
    end
    a.props.Units = newunits(:)';
end

function tf = isstring(s) % require a row of chars, or possibly ''
tf = ischar(s) && ((isvector(s) && (size(s,1) == 1)) || all(size(s)==0));
