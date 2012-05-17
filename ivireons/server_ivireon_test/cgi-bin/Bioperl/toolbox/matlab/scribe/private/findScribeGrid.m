function SG = findScribeGrid(fig)
% Given a figure, return the scribe grid associated with it.

%   Copyright 2010 The MathWorks, Inc.

if ~feature('HGUsingMATLABClasses')
    found=false;
    scribeunder = findall(fig,'Tag','scribeUnderlay');
    if ~isempty(scribeunder)
        % look for existing scribegrid - there can only be one.
        underkids = findall(scribeunder,'type','hggroup');
        k=1;
        while k<=length(underkids) && ~found
            if isprop(handle(underkids(k)),'shapetype')
                if strcmpi('scribegrid',get(handle(underkids(k)),'shapetype'))
                    SG = handle(underkids(k)); found=true;
                end
            end
            k=k+1;
        end
    end
    if ~found
        SG = scribe.scribegrid(fig);
        scribeax = getappdata(fig,'Scribe_ScribeOverlay');
        methods(handle(scribeax),'stackScribeLayersWithChild',double(scribeax),true);
    end
else
    scribeunder = getDefaultCamera(fig,'underlay');
    SG = getScribeGrid(scribeunder);
end