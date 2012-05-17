function a = setvardescription(a,newvardescr)
%SETVARDESCRIPTION Set dataset array VarDescription property.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2009/04/15 23:35:27 $

if nargin < 2
    error('stats:dataset:setvardescription:TooFewInputs', ...
          'Requires at least two inputs.');
end

if nargin == 2
    if isempty(newvardescr)
        a.props.VarDescription = {}; % do this for cosmetics
        return
    end
    if numel(newvardescr) ~= a.nvars
        error('stats:dataset:setvardescription:WrongLength', ...
              'NEWVARDESCR must have one element for each variable in A.');
    elseif ~iscell(newvardescr)
        error('stats:dataset:setvardescription:InvalidDescr', ...
              'NEWVARDESCR must be a cell array of strings.');
    elseif ~all(cellfun(@isstring,newvardescr))
        error('stats:dataset:setvardescription:InvalidDescr', ...
              'NEWVARDESCR must contain strings.');
    end
    a.props.VarDescription = newvardescr(:)';
end

function tf = isstring(s) % require a row of chars, or possibly ''
tf = ischar(s) && ((isvector(s) && (size(s,1) == 1)) || all(size(s)==0));
