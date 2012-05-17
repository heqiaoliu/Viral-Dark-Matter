function f = webfigure(hnd)
% WEBFIGURE  Creates a WebFigure Java object or Struct for the given figure.
% 
% WEBFIGURE(H) saves a copy of the figure identified by the handle H
% If this method is invoked from a MATLAB Builder JA compoennt a 
% Java object of type com.mathworks.toolbox.javabuilder.webfigures.WebFigure 
% is returned.  
% 
% If this method is invoked from a MATLAB Builder NE component a structure 
% is returned containing the webfigure data.  .
%
% When using this from MATLAB Builder JA this object can be attached to a 
% J2EE context scope in a Java web application for access by the WebFigures 
% client-side interface.  This interface can be embedded in a JSP or JSPX 
% page via the WebFigures tag library 
% (MATLAB/toolbox/javabuilder/webfigures/webfigures.tld) or by a Servlet using
% com.mathworks.toolbox.javabuilder.webfigures.WebFigures.getHtmlEmbedString().
%
% The use of WebFigures inside MATLAB is not supported.
% See the MATLAB Builder JA and MATLAB Builder NE documentation for more details.

%   Copyright 2008 The MathWorks, Inc.

%#function savewebfigure

    error(nargchk(1, 2, nargin, 'struct'));
    
    % NOTE: this check will need to change if we support non-figure objects 
    % via WebFigures
    if ishghandle(hnd,'figure')
        hnd = double(hnd); % Casting the figure handle to double to make 
                           % sure that it works for HG2 also. This is
                           % redundant for HG1
        currentAxes = get(hnd, 'CurrentAxes');
        if isempty(currentAxes) 
            error('MATLAB:webfigure:FigureWithoutAxes',...
                  'WEBFIGURE must be called on a figure with at least one axes');
        end

        %Use userdata that has been previously 
        %  set to determine the buidler type.  
        type = '';

        if(isempty(type))
            type = getmcruserdata('builder');
        end

        existsVal = exist('javawebfigure.m', 'file');
        if((isempty(type) || strcmp(type,'java')) && existsVal == 2)
            f = javawebfigure(hnd); 
        else
            f = structwebfigure(hnd);  
        end 
        
    else
        error('MATLAB:webfigure:InvalidFigureHandle','Invalid figure handle');
    end

    



