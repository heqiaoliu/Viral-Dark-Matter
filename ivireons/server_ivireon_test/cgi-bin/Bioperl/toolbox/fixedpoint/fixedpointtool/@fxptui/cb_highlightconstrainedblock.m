function cb_highlightconstrainedblock
%CB_HIGHLIGHTCONSTRAINEDBLOCK highlights selected block with data type constraints in model

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/11/13 04:18:42 $

me =  fxptui.explorer;
selection = me.getlistselection;
if(isa(selection, 'fxptui.abstractobject'))
    if ~isempty(selection.DTConstraints.SourceBlk)
        try
            selection.DTConstraints.SourceBlk.hilite;
        catch e  %#ok  %consume the error for hilighting
        end
    end
end

% [EOF]
