function h = surf(varargin)
%SURF   3-D colored surface.
%   SURF(X,Y,Z,C) plots the colored parametric surface defined by
%   four matrix arguments.  The view point is specified by VIEW.
%   The axis labels are determined by the range of X, Y and Z,
%   or by the current setting of AXIS.  The color scaling is determined
%   by the range of C, or by the current setting of CAXIS.  The scaled
%   color values are used as indices into the current COLORMAP.
%   The shading model is set by SHADING.
%
%   SURF(X,Y,Z) uses C = Z, so color is proportional to surface height.
%
%   SURF(x,y,Z) and SURF(x,y,Z,C), with two vector arguments replacing
%   the first two matrix arguments, must have length(x) = n and
%   length(y) = m where [m,n] = size(Z).  In this case, the vertices
%   of the surface patches are the triples (x(j), y(i), Z(i,j)).
%   Note that x corresponds to the columns of Z and y corresponds to
%   the rows.
%
%   SURF(Z) and SURF(Z,C) use x = 1:n and y = 1:m.  In this case,
%   the height, Z, is a single-valued function, defined over a
%   geometrically rectangular grid.
%
%   SURF(...,'PropertyName',PropertyValue,...) sets the value of the
%   specified surface property.  Multiple property values can be set
%   with a single statement.
%
%   SURF(AX,...) plots into AX instead of GCA.
%
%   SURF returns a handle to a surface plot object.
%
%   AXIS, CAXIS, COLORMAP, HOLD, SHADING and VIEW set figure, axes, and
%   surface properties which affect the display of the surface.
%
%   See also SURFC, SURFL, MESH, SHADING.

%-------------------------------
%   Additional details:
%
%   If the NextPlot axis property is REPLACE (HOLD is off), SURF resets
%   all axis properties, except Position, to their default values
%   and deletes all axis children (line, patch, surf, image, and
%   text objects).

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 5.14.4.15 $  $Date: 2008/09/18 15:56:55 $

%   J.N. Little 1-5-92

error(nargchk(1,inf,nargin,'struct'))

% First we check whether Handle Graphics uses MATLAB classes
isHGUsingMATLABClasses = feature('HGUsingMATLABClasses');

% Next we check whether to use the V6 Plot API
[v6,args] = usev6plotapi(varargin{:},'-mfilename',mfilename);

if isHGUsingMATLABClasses
    hh = surfHGUsingMATLABClasses(args{:});
else
    [cax,args,nargs] = axescheck(args{:});
    
    hadParentAsPVPair = false;
    if nargs > 1
        % try to fetch axes handle from input args,
        % and allow it to override the possible input "cax"
        for i = 1:length(args)
            if ischar(args{i}) && strncmpi(args{i}, 'parent', length(args{i})) && nargs > i
                cax = args{i+1};
                hadParentAsPVPair = true;
                break;
            end
        end
    end
    
    % do input checking
    dataargs = parseparams(args);
    error(surfchk(dataargs{:})); 
    
    % use nextplot unless user specified an axes handle in pv pairs
    % required for backwards compatibility
    if isempty(cax) || ~hadParentAsPVPair
        if ~isempty(cax) && ~isa(handle(cax),'hg.axes')
            parax = cax;
            cax = ancestor(cax,'Axes');
            hold_state = true;
        else
            cax = newplot(cax);
            parax = cax;
            hold_state = ishold(cax);
        end
    else
        cax = newplot(cax);
        parax = cax;
        hold_state = ishold(cax);
    end
    
    if v6
        hh = surface(args{:},'parent',cax);
    else
        hh = double(graph3d.surfaceplot(args{:},'parent',parax));
    end
    
    if ~hold_state
        view(cax,3);
        grid(cax,'on');
    end
end

if nargout == 1
    h = hh;
end

% function out=id(str)
% out = ['MATLAB:surf:' str];
