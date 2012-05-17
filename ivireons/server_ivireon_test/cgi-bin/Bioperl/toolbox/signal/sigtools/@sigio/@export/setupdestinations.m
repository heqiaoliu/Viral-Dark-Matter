function setupdestinations(this)
%SETUPDESTINATIONS Setup the destination information.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:44:59 $

% out is a sigutils.vector object which contains data of homogenous
% type, i.e., arrays or object handles
set(this,'AvailableConstructors',getconstructors(this),...
    'AvailableDestinations',getdestinations(this));

% -------------------------------------------------------------------------
function constructor = getconstructors(this)
% Get the destinations to export the data

% Default destination object constructors
constructor = {'sigio.xp2wksp','sigio.xp2txtfile','sigio.xp2matfile'};

% Check if structure contains data specific constructors
info = exportinfo(this.data);

if isfield(info,'constructors'),
    newconstructors = info.constructors;
    
    % Index of the data requested default destination object constructors
    idx = find(cellfun('isempty',info.constructors));
    
    newconstructors(idx) = constructor(idx); 
    constructor = newconstructors;
end

% -------------------------------------------------------------------------
function des = getdestinations(this)
% Get the destinations to export the data

% Default Destinations
des = {'Workspace','Text-File','MAT-File'};

% Get the info structure
info = exportinfo(this.data);

% Check if structure contains data specific destinations
if isfield(info,'destinations'),
    des = info.destinations;
end


% [EOF]
