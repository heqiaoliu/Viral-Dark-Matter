function isave(fName, varargin)
%ISAVE    Save the instrumentation set.
%   uiscopes.isave(FILENAME) saves all serializable scope instances to an
%   instrumentation-set file named FILENAME.
%
%   uiscopes.isave(FILENAME, INSTANCENUMBERS) saves all serializable scopes
%   instances whose InstanceNumber properties match the vector
%   INSTANCENUMBERS to an instrumentation-set file.
%
%   See also uiscopes.iload.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/03/09 19:32:46 $

% Default iset extension:
[p,n,e]=fileparts(fName);
if isempty(e)
    fName = [fName '.iset'];
end

if nargin > 1 && isa(varargin{1}, 'uiscopes.AbstractScopeCfg')
    inst = varargin{1};
else
    inst = uiscopes.iget(varargin{:});
end

if isempty(inst)
    DAStudio.warning('Spcuilib:scopes:NoSerializableScopes');
else
    
    % Save the states in the specified file.
    save(fName, 'inst')
end

% [EOF]
