function postdeserialize(hThis)
% Clean up deserialized scribe object. This includes removing extra
% children.

%   Copyright 2006 The MathWorks, Inc.

% delete children not created in constructor and children involved in
% pinning (Pin, Pinrect).
goodchildren = double(hThis.Srect);
goodchildren = [goodchildren;double(hThis.Pin)];

% Subclasses may add additional children, call the method
% "getCreatedChildren" to capture this.
goodchildren = [goodchildren;double(hThis.getCreatedChildren)];

% Since handle visibility of the children may be "off", use the FINDALL
% function to make sure we find all thie children.
allchildren = findall(double(hThis),'-depth',1);
allchildren = allchildren(2:end);

% Delete the children not explicitly referenced above.
badchildren = setdiff(allchildren,goodchildren);
if ~isempty(badchildren)
    delete(badchildren);
end

% If we are pasting, offset position so that the pasted object doesn't 
% overlap existing objects
hFig = ancestor(hThis,'Figure');
if isappdata(hFig,'BusyPasting')
    peers = get(get(hThis,'Parent'),'Children');
    dh = double(hThis);
    peers(peers == dh) = [];
    origpos = get(hThis,'Position');
    changed = false;
    k = length(peers);
    hFig = ancestor(hThis,'Figure');
    offset = hgconvertunits(hFig,[0 0 0.02 -0.02],'Normalized',get(hThis,'Units'),hFig);
    offset = offset(3:4);
    while k > 0
        peer = peers(k);
        k = k-1;
        try % skip objects that don't have Position as a 4 elem vector
            pos = hgconvertunits(hFig,get(peer,'Position'),get(peer,'Units'),get(hThis,'Units'),hFig);
            if all(abs(pos-origpos) < sqrt(eps))
                origpos(1:2) = origpos(1:2) + offset;
                changed = true;
                k = length(peers);
            end
        catch
        end
    end
    if changed, set(hThis,'Position',origpos); end
end

% If an object was pinned, repin it
if any(hThis.PinExists)
    hThis.postDeserializePins;
end

% If we are loading from a previous version of MATLAB, set the "HitTest"
% property of the object to be "on" and all its children to be "off".
set(findall(double(hThis)),'HitTest','off')
set(hThis,'HitTest','on');