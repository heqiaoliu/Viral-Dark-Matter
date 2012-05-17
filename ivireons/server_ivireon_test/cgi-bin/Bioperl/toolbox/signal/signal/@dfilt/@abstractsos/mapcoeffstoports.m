function [out coeffnames variables] = mapcoeffstoports(this,varargin)
%MAPCOEFFSTOPORTS 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/23 08:13:58 $

out = parse_mapcoeffstoports(this,varargin{:});

coeffnames = {'Num','Den','g'};
idx = find(strcmpi(varargin,'CoeffNames'));
if ~isempty(idx), 
    userdefinednames = varargin{idx+1}; 
    % if user-defined coefficient names are empty, return the default
    % names.
    if ~isempty(userdefinednames)
        coeffnames = varargin{idx+1}; 
    end
end

if length(coeffnames)~=3,
    error(generatemsgid('InvalidValue'), ...
        'The CoeffNames value must be a cell array containing three strings.');
end

Num = this.privNum.';

aux = this.privDen;
Den = aux(:,2:3).';
g = this.privScaleValues.';

variables{1} = Num;
variables{2} = Den;
variables{3} = g;

% [EOF]
