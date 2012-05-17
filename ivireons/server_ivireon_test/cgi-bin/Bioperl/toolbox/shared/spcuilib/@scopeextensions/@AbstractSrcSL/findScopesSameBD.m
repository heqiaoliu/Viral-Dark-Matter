function m = findScopesSameBD(this, varargin)
%FINDSCOPESSAMEBD Returns the number of scopes attached to the same source.
% Optional argument is the scope type to limit search
% By default search for all scopeextensions.AbstractSrcSL and derived

%   Author(s): J. Schickler
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:41:02 $

% If the current scope isn't properly connected, return early.
if ~isConnected(this)
    m = [];
    return;
end

if nargin < 2
    scopeType = 'scopeextensions.AbstractSrcSL';
else
    % could pass in 'scopeextensions.SrcSL' or 'scopeextensions.WiredSL'
    scopeType = varargin{1};
end

%  1 - find all other mplay instances
m = uiscopes.find;

parentModel = getParentModel(this);

indx = 1;

% Loop over the scope instances and remove any that do not match properly.
while indx <= numel(m)
    if isequal(this, m(indx).DataSource)
        
        % Remove ourselves from the vector of scopes
        m(indx) = [];
    elseif ~isa(m(indx).DataSource, scopeType)
        
        % Remove any scopes that are not attached to simulink
        m(indx) = [];
    elseif ~isequal(parentModel, getParentModel(m(indx).DataSource))
        
        % Remove any scopes that are not attached to the same model.
        m(indx) = [];
    else
        indx = indx+1;
    end
end

% [EOF]

