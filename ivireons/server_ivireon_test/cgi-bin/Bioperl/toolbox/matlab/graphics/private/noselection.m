function noselection( state, fig )
%NOSELECTION Select/Deselect all objects in Figure.
%   NOSELECTION SAVE finds all objects with the Selected property 
%   of 'on'. Turns them all 'off'. Saves the handles so the Selected
%   values can be restored. This is useful when printing so that we
%   do not print the selection handles.
%
%   NOSELECTION RESTORE returns any previously changed objects'
%   Selected properties to their original values.
%
%   NOSELECTION(...,FIG) operates on the specified figure.
%
%   See also PRINT.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2008/04/11 15:37:32 $

persistent NoSelectedOriginalValues;

if nargin == 0 ...
    || ~ischar( state ) ...
    || ~(strcmp(state, 'save') || strcmp(state, 'restore'))
    error('MATLAB:Print:noselectionNeedsSaveOrRestore', '%s needs to know if it should ''save'' or ''restore''', mfilename)
elseif nargin ==1
    fig = gcf;
end

if strcmp( state, 'save' )
    %Get all objects we need to change, 
    %be careful about setting root property back.
    hiddenH = get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on');
    try
        h = findobj(fig,'Selected','on');
        err = 0;
    catch ex
        err = 1;
    end
    set(0,'showhiddenhandles', hiddenH)
    if err
        rethrow(ex)
    end
    
    storage.handles = h;
    storage.origValue = get(h, {'Selected'});
    set(h,'Selected','off');
    
    NoSelectedOriginalValues = [storage NoSelectedOriginalValues];
else
    orig = NoSelectedOriginalValues(1);
    NoSelectedOriginalValues = NoSelectedOriginalValues(2:end);
    set(orig.handles, {'Selected'}, orig.origValue);
end
