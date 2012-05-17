function setMarkersOn(Constr,onoff) 
% SETMARKERSON  Method to hide/show the constraint markers
%
 
% Author(s): A. Stothert 22-Dec-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:56 $

hGroup = Constr.Elements;
hChildren = hGroup.Children;
Tags = get(hChildren,'Tag');
idx = strcmp(Tags,'ConstraintMarkers');
set(hChildren(idx),'Visible',onoff);
