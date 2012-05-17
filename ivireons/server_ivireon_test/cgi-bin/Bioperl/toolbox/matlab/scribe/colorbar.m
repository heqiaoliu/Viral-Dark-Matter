function cbar=colorbar(varargin)
%COLORBAR Display color bar (color scale)
%   COLORBAR appends a colorbar to the current axes in the default (right)
%   location
%
%   COLORBAR('peer',AX) creates a colorbar associated with axes AX
%   instead of the current axes.
%
%   COLORBAR(...,LOCATION) appends a colorbar in the specified location
%   relative to the axes.  LOCATION may be any one of the following strings:
%       'North'              inside plot box near top
%       'South'              inside bottom
%       'East'               inside right
%       'West'               inside left
%       'NorthOutside'       outside plot box near top
%       'SouthOutside'       outside bottom
%       'EastOutside'        outside right
%       'WestOutside'        outside left
%
%   COLORBAR(...,P/V Pairs) specifies additional property name/value pairs
%   for colorbar
%
%   COLORBAR('off'), COLORBAR('hide'), and COLORBAR('delete') delete all
%   colorbars associated with the current axes.
%
%   COLORBAR(H,'off'), COLORBAR(H,'hide'), and COLORBAR(H,'delete') delete
%   the colorbar specified by H.
%
%   H = COLORBAR(...) returns a handle to the colorbar axes, which is a
%   child of the current figure. If a colorbar exists, a new one is still \
%   created.
%
%   See also COLORMAP.

%   Unsupported APIs for internal use:
%   LOCATION strings can be abbreviated N, SO, etc or lower case.
%   COLORBAR(...,'horiz') is the same as COLORBAR(...,'SouthOutside')
%   COLORBAR(...,'vert') is the same as COLORBAR(...,'EastOutside')
%   COLORBAR(...,'off') and COLORBAR(...,'delete') deletes the colorbar, if any
%   COLORBAR(AX) puts an R13 colorbar into axes AX.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.17

% First we check whether Handle Graphics uses MATLAB classes
isHGUsingMATLABClasses = feature('HGUsingMATLABClasses');

if isHGUsingMATLABClasses
    if nargout == 0
        colorbarHGUsingMATLABClasses(varargin{:});
    else
        cbar = colorbarHGUsingMATLABClasses(varargin{:});
    end
else
    narg = nargin;
    
    old_currfig = get(0,'CurrentFigure');
    if ~isempty(old_currfig)
        old_currax = get(old_currfig,'CurrentAxes');
    end
    
    cbarIn = false;
    colBar = [];
    
    % check for colorbar(ax,...) or colorbar('v6',...) or colorbar(cbar,...)
    args = varargin;
    if narg > 0
        arg = args{1};
        do_v6 = false;
        if ischar(arg) && strcmp(arg,'v6')
            do_v6 = true;
            warning(['MATLAB:', mfilename, ':DeprecatedV6Argument'],...
                ['The ''v6'' argument to %s is deprecated,',...
                ' and will no longer be supported in a future release.'], upper(mfilename));
            varargin(1) = [];
        elseif ~isempty(arg) && length(arg)==1 && ...
                ishandle(arg) && strcmp(get(arg(1),'type'),'axes')
            if isa(handle(arg),'scribe.colorbar')
                cbarIn = true;
                colBar = arg;
                if nargin < 2
                    error(id('TooFewInputs'),'The colorbar handle must be followed by either ''delete'', ''hide'' or ''off''.');
                end
                args = args(2:end);
                narg = narg-1;
            else
                do_v6 = true;
            end
        end
        if do_v6
            if nargout > 0
                cbar = colorbarv6(varargin{:});
            else
                colorbarv6(varargin{:});
            end
            return;
        end
    end
    
    n = 1;   % index into varargin
    peeraxes = [];
    do_delete = false;
    pvpairs = {};
    location = 'EastOutside';
    position = [];
    
    % Get location strings long and short form. The short form is the
    % long form without any of the lower case characters.
    findclass(findpackage('scribe'),'colorbar'); % load colorbar schema and types
    locations = findtype('ColorbarLocationPreset');
    locations = locations.Strings;
    locationAbbrevs = cell(length(locations),1);
    for k=1:length(locations)
        str = locations{k};
        locationAbbrevs{k} = str(str>='A' & str<='Z');
    end
    
    % loop over inputs and process until reaching prop-value pairs
    while n <= narg && isempty(pvpairs)
        arg = args{n};
        if ischar(arg)
            if n < narg && strcmpi(arg,'peer')
                % found 'peer',axes
                peeraxes = varargin{n+1};
                n = n + 1;
                if ~ishandle(peeraxes) || ~strcmpi(get(peeraxes,'type'),'axes')
                    error(id('InvalidPeer'),'''peer'' must be followed by an axes handle.');
                end
            elseif strcmpi(arg,'off') || strcmpi(arg,'delete') || strcmpi(arg,'hide')
                % found 'delete' or 'off' or 'hide'
                do_delete = true;
            elseif (arg(1) == 'h') && (fix((narg-n)/2) == (narg-n)/2)
                % found 'horizontal'
                location = 'SouthOutside';
            elseif (arg(1) == 'v') && (fix((narg-n)/2) == (narg-n)/2)
                % found 'vertical'
                location = 'EastOutside';
    elseif (any(strcmpi(arg, locations)) || ...
          any(strcmpi(arg, locationAbbrevs))) && ...
          (fix((narg-n)/2) == (narg-n)/2)
                % found a Location in long or short form
                location = arg;
                % look up the long form location string if needed
                abbrev = find(strcmpi(arg, locationAbbrevs));
                if ~isempty(abbrev)
                    location = locations{abbrev};
                end
            else
                % assume prop-value pairs have started
                pvpairs = varargin(n:end);
      break
            end
        elseif isnumeric(arg) && length(arg)==4
            % found Position vector
            position = arg;
            location = 'manual';
        else
            error(struct('identifier',id('InvalidInput'),...
                'message','Unrecognized input or invalid parameter/value pair arguments.'));
        end
        n = n + 1;
    end
    
    if cbarIn && ~do_delete
        error(id('InvalidHandleInput'),'The colorbar handle must be followed by either ''delete'', ''hide'' or ''off''.');
    end
    
    if ~cbarIn
        if isempty(peeraxes)
            peeraxes = gca;
        end
        
        % if axes is a legend use its plotaxes
        h = handle(peeraxes);
        if isa(h,'scribe.colorbar') || isa(h,'scribe.legend');
            peeraxes = double(h.axes);
        end
    end
    
    if do_delete
        if cbarIn
            delete(colBar);
        else
            delete_all_colorbars(peeraxes);
        end
        if nargout>0
            error(id('TooManyOutputs'),'Too many outputs.');
        end
    else
        [c,msg] = make_colorbar(peeraxes,location,position,pvpairs);
        error(msg);
        if nargout>0
            cbar = c;
        end
    end
    
    % before going, be sure to reset current figure and axes
    if ~isempty(old_currfig) && ishandle(old_currfig) && ~strcmpi(get(old_currfig,'beingdeleted'),'on')
        set(0,'CurrentFigure',old_currfig);
        if ~isempty(old_currax) && ishandle(old_currax) && ~strcmpi(get(old_currax,'beingdeleted'),'on')
            set(old_currfig,'CurrentAxes',old_currax);
        end
    end
end


%----------------------------------------------------%
function [cbar,msg] = make_colorbar(peeraxes,location,position,pvpairs)

msg.identifier = '';
msg.message = '';
msg = msg([]);
% delete colorbar with same plotaxis and location if it exists
[cbar,position] = find_colorbar(peeraxes,location,position);
if ~isempty(cbar)
    delete_colorbar(cbar);
end

% check prop val args
if ~isempty(pvpairs)
    msg = check_pv_args(pvpairs);
    if ~isempty(msg), return; end
end

% create colorbar and return double
ch=scribe.colorbar(peeraxes,location,position,pvpairs{:});
cbar=double(ch);

%----------------------------------------------------%
function delete_colorbar(cbar)

if ~isempty(cbar) && ...
        ishandle(cbar) && ...
        isa(handle(cbar),'scribe.colorbar') && ...
        ~strcmpi(get(cbar,'beingdeleted'),'on')
    cbarh = handle(cbar);
    delete(cbarh);
end

%----------------------------------------------------%
function delete_all_colorbars(peeraxes)

fig = get(peeraxes,'parent');
ax = findobj(fig,'type','axes');
% vectorize
for k=1:length(ax)
    if iscolorbar(ax(k))
        hax = handle(ax(k));
        if isequal(double(hax.axes),peeraxes)
            delete_colorbar(ax(k));
        end
    end
end

%----------------------------------------------------%
function [hc,position] = find_colorbar(peeraxes,location,position)

fig = get(peeraxes,'parent');
ax = findobj(fig,'type','axes');
hc=[];
k=1;
% vectorize
while k<=length(ax) && isempty(hc)
    if iscolorbar(ax(k))
        hax = handle(ax(k));
        if isequal(double(hax.axes),peeraxes)
            if strcmp(location,hax.Location)
                hc=ax(k);
                if strcmp(location,'manual') && isempty(position)
                    position = get(hc,'Position');
                end
            end
        end
    end
    k=k+1;
end

%----------------------------------------------------%
function tf=iscolorbar(ax)

if length(ax) ~= 1 || ~ishandle(ax)
    tf=false;
else
    tf=isa(handle(ax),'scribe.colorbar');
end

%----------------------------------------------------------------------%
function msg = check_pv_args(args)

msg.identifier = '';
msg.message = '';
msg = msg([]);
n=length(args);
if mod(n,2)==0 % must be even
    for i=1:2:n
        if ~ischar(args{i})
            msg = struct('identifier',id('InvalidPropertyName'),...
                'message','Property names must be strings.');
        elseif ~isprop('scribe','colorbar',args{i})
            msg = struct('identifier',id('UnknownProperty'),...
                'message',sprintf('Unknown property ''%s''.',args{i}));
        elseif strcmpi(args{i},'Parent')
            if ~isa(handle(args{i+1}),'hg.figure') || ~isa(handle(args{i+1}),'hg.uipanel')
                msg = struct('identifier',id('InvalidParent'),...
                    'message',sprintf('A Colorbar can not be a child of an object of type %s.',get(args{i+1},'Type')));
            end
        end
    end
else
    msg = struct('identifier',id('InvalidInput'),...
        'message','Unrecognized input or invalid parameter/value pair arguments.');
end

function str = id(str)
str = ['MATLAB:colorbar:' str];
