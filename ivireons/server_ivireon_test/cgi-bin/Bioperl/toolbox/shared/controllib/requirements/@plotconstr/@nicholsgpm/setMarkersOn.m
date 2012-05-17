function setMarkersOn(Constr,onoff) 
% SETMARKERSON  Method to hide/show the constraint markers
%
 
% Author(s): A. Stothert 22-Dec-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:13 $


hGroup = Constr.Elements;
hChildren = hGroup.Children;
Tags = get(hChildren,'Tag');
idx = strcmp(Tags,'ConstraintMarkers');

if strcmp(onoff,'off')
    set(hChildren(idx),'Visible',onoff);
    %Quick return
    return
end

%Turn on markers based on active GM and PM constraint
gainphase = Constr.Data.Type;
if strcmp(gainphase,'both')
    set(hChildren(idx),'Visible',onoff);
else
    idx = find(idx);
    if strcmp(gainphase,'phase')
        set(hChildren(idx(1)),'Visible',onoff);
    elseif strcmp(gainphase,'gain')
        set(hChildren(idx(2)),'Visible',onoff);
    end
end
