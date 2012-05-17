function figOut = openfig(filename, policy, visible)
%OPENFIG Open new copy or raise existing copy of saved figure.
%    OPENFIG('NAME.FIG','new') opens figure contained in .fig file,
%    NAME.FIG, and ensures it is completely on screen.  Specifying the
%    .fig extension is optional. Specifying the full path is optional
%    as long as the .fig file is on the MATLAB path.
%
%    If the .fig file contains an invisible figure, OPENFIG returns
%    its handle and leaves it invisible.  The caller should make the
%    figure visible when appropriate.
%
%    OPENFIG('NAME.FIG') is the same as OPENFIG('NAME.FIG','new').
%
%    OPENFIG('NAME.FIG','reuse') opens figure contained in .fig file
%    only if a copy is not currently open, otherwise ensures existing
%    copy is still completely on screen.  If the existing copy is
%    visible, it is also raised above all other windows.
%
%    OPENFIG(...,'invisible') opens as above, forcing figure invisible.
%
%    OPENFIG(...,'visible') opens as above, forcing figure visible.
%
%    F = OPENFIG(...) returns the handle to the figure.
%
%    See also: OPEN, MOVEGUI, GUIDE, GUIHANDLES, SAVE, SAVEAS.

%    OPENFIG(...,'auto') opens as above, forcing figure invisible on
%    creation.  Subsequent calls when the second argument is 'reuse' will
%    obey the visibility setting in the .fig file.
%
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.29.4.13 $  $Date: 2009/10/24 19:18:05 $

error(nargchk(1,inf,nargin));
if nargin < 3
    visible = '';
else
    visible = lower(visible);
end

if ~isempty(visible) && ~isequal(visible,'invisible') && ~isequal(visible,'visible') && ~isequal(visible,'auto')
    error('MATLAB:openfig:InvalidThirdArgument', 'Third input argument must be ''invisible'' or ''visible''.');
end

if nargin < 2
    policy = 'new';
end

if ~isequal(policy,'new') && ~isequal(policy,'reuse')
    error('MATLAB:openfig:InvalidSecondArgument', 'Second input argument must be ''new'' or ''reuse''.');
end

[path, name, ext] = fileparts(filename);

if isempty(ext)
    ext = '.fig';
elseif ~isequal(lower(ext), '.fig')
    error('MATLAB:openfig:FigFileExpected', 'Argument must be a .fig file');
end

filename = fullfile(path, [name ext]);

TOKEN = getToken(filename);
% get the existing list of figures, and prune out stale handles.
figs = getappdata(0, TOKEN);
figs = figs(ishghandle(figs));

% are we reusing an existing figure loaded from the given file?
reusing = strcmpi(policy, 'reuse') && ~isempty(figs);
if ~reusing
    % create another one, unconditionally
    [fig, savedvisible] = hgload(filename, struct('Visible','off'));
    % add listener to remove the appData added for the figures. we could
    % have multiple handles here. 
    figures = handle(fig);
    for i=1:length(figures)
        addlistener(figures(i) ,'ObjectBeingDestroyed', @(o,e) cleanUp(o,e, filename));
    end
    if cellfun('isempty',savedvisible)
        % savedvisible is empty from hgload if the saved value is the
        % same as root's DefaultFigureVisible
        savedvisible = get(0,'DefaultFigureVisible');
    else
        savedvisible = savedvisible{1}.Visible;
    end

    figs = [figs(:)' fig(:)'];
    setappdata(figs(end),'SavedVisible',savedvisible);

    % If this is a GUIDE GUI, clear a flag if it is saved in the figure file so
    % that handle structure can be calculated.
    for j = 1:length(fig)
        if isappdata(fig(j),'GUIOnScreen')
            rmappdata(fig(j),'GUIOnScreen');
        end
    end
else
    fig = figs(end);
    savedvisible = getappdata(fig,'SavedVisible');
end

% remember all instances of this figure.
setappdata(0, TOKEN, figs);

% If the figure is not docked, ensure the figure is completely 
% on the screen
for n = 1:length(fig)
    if ~(strcmpi(get(fig(n), 'WindowStyle'), 'docked'))
        movegui(fig(n), 'onscreen');
    end
end

% decide whether to adjust visible
if isempty(visible)
    set(fig,'Visible',savedvisible);
else
    switch visible
        case 'invisible'
            set(fig,'Visible','off');
        case 'visible'
            set(fig,'Visible','on');
        case 'auto'
            if reusing
                % if savedvisible is 'on', this will raise the figure to
                % the foreground it will do nothing if it is 'off'
                set(fig,'Visible',savedvisible);
            else
                set(fig,'Visible','off');
            end
    end
end

if nargout
    figOut = fig;
end

function cleanUp(fig,eve,filename)
% remove the appData added for this fig on root
token = getToken(filename);
figs = getappdata(0, token);
if ~isempty(figs)
    figs(figs==fig)=[];
    if isempty(figs)
        rmappdata(0,token);
    else
        setappdata(0,token,figs);
    end    
end

function token = getToken(filename)
% We will use this token, based on the base name of the file
% (without path or extension) to track open instances of figure.
fname = genvarname(filename);         % convert the file name to a valid field name
fname = fliplr(fname);            % file name is more important
token = ['OpenFig_' fname '_SINGLETON']; % hide leading kruft
token = token(1:min(end, namelengthmax));
