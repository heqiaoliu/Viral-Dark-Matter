function sys = loadobj(s)
%LOADOBJ  Load filter for IDMODEL objects.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2009/10/16 04:55:15 $

if isa(s,'idmodel')
    sys = s;
else
    sys = idmodel;
end

% Name = [] in some old objects; replace with ''
if isa(sys.Name, 'double')
    sys.Name = '';
end

v = s.Version;
if v<3
    % R2008a or older
    % Algorithm properties need to be updated;
    
    alnew = idutils.utAlgoFieldsUpdate(s,v);
    
    % Update Algorithm struct
    sys.Algorithm = alnew;
    
    % set version to the old one so that subclasses can react to it 
    sys = setVersion(sys,v);
end
