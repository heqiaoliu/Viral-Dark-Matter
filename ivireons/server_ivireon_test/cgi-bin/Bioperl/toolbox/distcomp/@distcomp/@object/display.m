function display(obj)
; %#ok Undocumented
% DISPLAY Displays a distcomp object. should generally not be overridden If
% a subclass wants to modify output style completely it should override
% pSingleObjectDisplay or pVectorObjectDisplay. We assume each child of
% distcomp.object implements distcomp.pGetDisplayItems in a suitable cell
% array or structure. If an object does not implement pGetDisplayItems the
% standard distcomp.OBJECTNAME N-by-N is returned. To change the format of
% the general headings modify the format strings in
% pDefaultSingleObjDisplay or its Vector equivalent. 

% Copyright 2006-2010 The MathWorks, Inc.

% $Revision: 1.1.6.4 $  $Date: 2010/03/01 05:20:17 $

% Next few lines get default spacing format and insert extra spaces if
% loose format is detected.
objname = inputname(1);
LOOSE = strcmp(get(0, 'FormatSpacing'), 'loose');
% When the format is loose add a leading linefeed
if LOOSE
    fprintf('\n');
end
% Have we got an input name to display - default to ans if it isn't here
if isempty(objname)
    fprintf('ans = \n');
else
    disp([objname ' =']);
end
% When the format is loose add a trailing linefeed
if LOOSE
    fprintf('\n');
end

% For the time being it is possible that the display methods below might
% throw an error (possibly because an object doesn't override
% pGetDisplayItems, or for other unknown reasons). Thus we will deal with
% the default display under these circumstances here. It may be that we
% will move the code in the catch to the individual display methods at some
% point.
try
    if numel( obj ) == 1
        obj.pSingleObjectDisplay;
    else
        obj.pVectorObjectDisplay;
    end
catch exception %#ok<NASGU>
    % if there is any problem output the distcomp.* 1-by-n as pre 7a
    % release
    fprintf('\t%s\n', parallel.internal.createDimensionDisplayString(obj, class(obj)));
end
end




