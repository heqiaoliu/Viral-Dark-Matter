function properties = getpp( target )
%GETPP Get all PaperProperties.
%	GPP( h ) returns structure with fields the names of paperproperties and
%   values that of the object h.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.2 $  $Date: 2008/06/24 17:13:02 $

if nargin == 0
    if length( findall(get(0,'children'), 'type','figure') ) > 0
        target = gcf;
    elseif ~isempty(gcs)
        target = gcs;
    else
        error('MATLAB:getpp:MissingTarget','No target.')
    end
end

properties.paperpositionmode = getget(target,'paperpositionmode');
properties.paperposition = getget(target,'paperposition');
properties.paperorientation = getget(target,'paperorientation');
properties.paperunits = getget(target,'paperunits');
properties.papertype = getget(target,'papertype');
properties.papersize = getget(target,'papersize');
