function legKidsOut = expandLegendChildren(legKids)
%EXPANDLEGENDCHILDREN recursively goes through a list of graphics objects,
%   expanding groups whose "LegendEntry" display property is set to
%   "Children".

%   Copyright 2007 The MathWorks, Inc.


legKidsOut = [];
for i = 1:length(legKids)
    hA = get(legKids(i),'Annotation');
    if ishandle(hA)
        hL = get(hA,'LegendInformation');
        if ishandle(hL) && strcmpi(hL.IconDisplayStyle,'Children')
            if isprop(handle(legKids(i)),'Children') && ...
                    ~isempty(get(legKids(i),'Children'))
                legKidsOut = [legKidsOut;...
                    expandLegendChildren(get(legKids(i),'Children'))];
            else
                legKidsOut = [legKidsOut;legKids(i)];
            end
        else
            legKidsOut = [legKidsOut;legKids(i)];
        end
    else
        legKidsOut = [legKidsOut;legKids(i)];
    end
end