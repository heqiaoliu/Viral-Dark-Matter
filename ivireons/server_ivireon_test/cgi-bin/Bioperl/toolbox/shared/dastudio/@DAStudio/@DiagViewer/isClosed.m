function b = isClosed(h)
%  isClosed
%
%  Returns true if the Diagnostic Viewer window is hidden. Note that
%  the DV's Visible property specifies what the DV's visibility SHOULD be.
%  This method guarantees that the DV actually is closed.
%
%  Copyright 2008 The MathWorks, Inc.


    if isa(h.Explorer, 'DAStudio.Explorer')
        imme = DAStudio.imExplorer(h.Explorer);
        b = ~imme.isVisible;
    else
        b = false;
    end

end