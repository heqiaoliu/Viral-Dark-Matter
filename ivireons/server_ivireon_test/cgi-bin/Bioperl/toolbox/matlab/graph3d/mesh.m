function h = mesh(varargin)
%MESH   3-D mesh surface.
%   MESH(X,Y,Z,C) plots the colored parametric mesh defined by
%   four matrix arguments.  The view point is specified by VIEW.
%   The axis labels are determined by the range of X, Y and Z,
%   or by the current setting of AXIS.  The color scaling is determined
%   by the range of C, or by the current setting of CAXIS.  The scaled
%   color values are used as indices into the current COLORMAP.
%
%   MESH(X,Y,Z) uses C = Z, so color is proportional to mesh height.
%
%   MESH(x,y,Z) and MESH(x,y,Z,C), with two vector arguments replacing
%   the first two matrix arguments, must have length(x) = n and
%   length(y) = m where [m,n] = size(Z).  In this case, the vertices
%   of the mesh lines are the triples (x(j), y(i), Z(i,j)).
%   Note that x corresponds to the columns of Z and y corresponds to
%   the rows.
%
%   MESH(Z) and MESH(Z,C) use x = 1:n and y = 1:m.  In this case,
%   the height, Z, is a single-valued function, defined over a
%   geometrically rectangular grid.
%
%   MESH(...,'PropertyName',PropertyValue,...) sets the value of
%   the specified surface property.  Multiple property values can be set
%   with a single statement.
%
%   MESH(AX,...) plots into AX instead of GCA.
%
%   MESH returns a handle to a surface plot object.
%
%   AXIS, CAXIS, COLORMAP, HOLD, SHADING, HIDDEN and VIEW set figure,
%   axes, and surface properties which affect the display of the mesh.
%
%   See also SURF, MESHC, MESHZ, WATERFALL.

%-------------------------------
%   Additional details:
%
%   MESH sets the FaceColor property to background color and the EdgeColor
%   property to 'flat'.
%
%   If the NextPlot axis property is REPLACE (HOLD is off), MESH resets
%   all axis properties, except Position, to their default values
%   and deletes all axis children (line, patch, surf, image, and
%   text objects).

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 5.14.4.11 $  $Date: 2008/09/18 15:56:52 $

%   J.N. Little 1-5-92
%   Modified 2-3-92, LS.

% First we check whether Handle Graphics uses MATLAB classes
isHGUsingMATLABClasses = feature('HGUsingMATLABClasses');

% Next we check whether to use the V6 Plot API
[v6,args] = usev6plotapi(varargin{:},'-mfilename',mfilename);

if isHGUsingMATLABClasses
    hh = meshHGUsingMATLABClasses(args{:});
    if nargout == 1
        h = hh;
    end
else
    [cax,args] = axescheck(args{:});
    
    [reg, prop]=parseparams(args);
    nargs=length(reg);
    
    error(nargchk(1,4,nargs,'struct'));
    if rem(length(prop),2)~=0,
        error('MATLAB:mesh:ExpectedPropertyValuePairs', 'Property value pairs expected.')
    end
    
    % do input checking
    regdata = reg;
    if numel(reg{end}) == 2
        regdata(end) = [];
    end
    error(surfchk(regdata{:})); 
    
    user_view = 0;
    if isempty(cax) || isa(handle(cax),'hg.axes')
        cax = newplot(cax);
        parax = cax;
        hold_state = ishold(cax);
    else
        parax = cax;
        cax = ancestor(cax,'Axes');
        hold_state = true;
    end
    
    hparent = get(cax,'parent');
    fc = get(cax,'color');
    if strcmpi(fc,'none')
        if isprop(hparent,'Color')
            fc = get(hparent,'Color');
        elseif isprop(hparent,'BackgroundColor')
            fc = get(hparent,'BackgroundColor');
        end
    end
    
    if nargs == 1
        x=reg{1};
        if v6
            hh = surface(x,'FaceColor',fc,'EdgeColor','flat', ...
                'FaceLighting','none','EdgeLighting','flat','parent',cax);
        else
            hh = graph3d.surfaceplot(x,'FaceColor',fc,'EdgeColor','flat', ...
                'FaceLighting','none','EdgeLighting','flat','parent',parax);
        end
    elseif nargs == 2
        [x,y]=deal(reg{1:2});
        if ischar(y)
            error('MATLAB:mesh:InvalidArgument', 'Invalid argument.');
        end
        [my ny] = size(y);
        [mx nx] = size(x);
        if mx == my && nx == ny
            if v6
                hh = surface(x,y,'FaceColor',fc,'EdgeColor','flat', ...
                    'FaceLighting','none','EdgeLighting','flat','parent',cax);
            else
                hh = graph3d.surfaceplot(x,y,'FaceColor',fc,'EdgeColor','flat', ...
                    'FaceLighting','none','EdgeLighting','flat','parent',parax);
            end
        else
            if my*ny == 2 % must be [az el]
                if v6
                    hh = surface(x,'FaceColor',fc,'EdgeColor','flat', ...
                        'FaceLighting','none','EdgeLighting','flat','parent',cax);
                else
                    hh = graph3d.surfaceplot(x,'FaceColor',fc,'EdgeColor','flat', ...
                        'FaceLighting','none','EdgeLighting','flat','parent',parax);
                end
                set(cax,'View',y);
                user_view = 1;
            else
                error('MATLAB:mesh:InvalidInputs', 'Invalid input arguments.');
            end
        end
    elseif nargs == 3
        [x,y,z]=deal(reg{1:3});
        if ischar(y) || ischar(z)
            error('MATLAB:mesh:ArgumentInvalid', 'Invalid argument.');
        end
        if min(size(y)) == 1 && min(size(z)) == 1 % old style
            if v6
                hh = surface(x,'FaceColor',fc,'EdgeColor','flat', ...
                    'FaceLighting','none','EdgeLighting','flat','parent',cax);
            else
                hh = graph3d.surfaceplot(x,'FaceColor',fc,'EdgeColor','flat', ...
                    'FaceLighting','none','EdgeLighting','flat','parent',parax);
            end
            set(cax,'View',y);
            user_view = 1;
        else
            if v6
                hh = surface(x,y,z,'FaceColor',fc,'EdgeColor','flat', ...
                    'FaceLighting','none','EdgeLighting','flat','parent',cax);
            else
                hh = graph3d.surfaceplot(x,y,z,'FaceColor',fc,'EdgeColor','flat', ...
                    'FaceLighting','none','EdgeLighting','flat','parent',parax);
            end
        end
    elseif nargs == 4
        [x,y,z,c]=deal(reg{1:4});
        if v6
            hh = surface(x,y,z,c,'FaceColor',fc,'EdgeColor','flat', ...
                'FaceLighting','none','EdgeLighting','flat','parent',cax);
        else
            hh = graph3d.surfaceplot(x,y,z,c,'FaceColor',fc,'EdgeColor','flat', ...
                'FaceLighting','none','EdgeLighting','flat','parent',parax);
        end
    end
    if ~isempty(prop),
        set(hh,prop{:})
    end
    if ~hold_state && ~user_view
        view(cax,3); grid(cax,'on');
    end
    if nargout == 1
        h = double(hh);
    end
end

% function out=id(str)
% out = ['MATLAB:mesh:' str];
