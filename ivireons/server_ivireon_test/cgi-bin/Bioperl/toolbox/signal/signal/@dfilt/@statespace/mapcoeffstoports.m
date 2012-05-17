function [out coeffnames variables] = mapcoeffstoports(this,varargin)
%MAPCOEFFSTOPORTS 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/14 04:03:12 $

out = parse_mapcoeffstoports(this,varargin{:});

coeffnames = coefficientvariables(this);
idx = find(strcmpi(varargin,'CoeffNames'));
if ~isempty(idx),
    userdefinednames = varargin{idx+1}; 
    % if user-defined coefficient names are empty, return the default names.
    if ~isempty(userdefinednames)
        coeffnames = userdefinednames;
    end
end

if length(coeffnames)~=4,
    error(generatemsgid('InvalidValue'), ...
        'The CoeffNames value must be a cell array containing four strings.');
end

if isempty(this.refA)
    % This is the header_order0 case for the default object. Only
    % coefficient name corresponds to refD will be exported to the
    % workspace.
    variables{1} = this.refD;
    coeffnames = coeffnames(4);
else
    variables{1} = this.refA;
    variables{2} = this.refB;
    variables{3} = this.refC;
    variables{4} = this.refD;
end


% [EOF]
