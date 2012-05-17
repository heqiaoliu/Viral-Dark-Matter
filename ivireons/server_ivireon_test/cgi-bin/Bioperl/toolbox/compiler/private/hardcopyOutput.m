function cdata = hardcopyOutput(hnd)
%   hardcopyOutput takes a given figure handle and gets the CDATA for 
%       for the current view.
%
%   This is an internal function used by all deployment functions 
%       that require running hardcopy.  
%
%   This is the default output function for renderwebfigure.m
%
%     hardcopyOutput(<Figure Handle>)
%       Takes a given figure handle and gets the CDATA for the current
%       view.  
%
%   Examples:
%   
%   Convert a specific figure an array of its current views CDATA:
%       f = figure;
%       surf(peaks);
%       cdata = hardcopyOutput(f);
%
% Copyright 2007 The MathWorks, Inc.

    deploylog('finer', 'HARDCOPYOUTPUT entered');
   
    if isempty(hnd) || ~ishghandle(hnd,'figure')
        error(  'MATLAB:webfigure:NotAFigure',...
                'The handle passed in is not a valid Figure');
    end 

    % Make sure hardcopy gives back the same size as the figure window
    ppm = get(hnd,'PaperPositionMode');
    set(hnd,'PaperPositionMode','auto');

    rend = get(hnd,'renderer');

    % Hardcopy cannot give the cdata with painters as renderer if the figure is
    % invisible. We don't want the figure to flash on the screen. So, we are 
    % not going to set the visibility to on. So, we will use zbuffer if 
    % painters is used as renderer. 'None' is the renderer when a blank figure 
    % is created. The default renderer for root in MATLAB is painters. The actual
    % renderer used for plotting data depends upon the kind of data being
    % plotted. So, there's the root default and there's the data default.
    if any( strcmpi(rend,{'none','painters'}) )
        rend = 'zbuffer';
    end

    % TODO - remove call to drawnow once 398356 has been fixed
    drawnow; 

    deploylog('finer', ['HARDCOPYOUTPUT Render to be used: ' rend]);
    rendercmd = ['-d' rend];
    % do the hardcopy
    cdata = [];
    
    if feature('hgusingmatlabclasses')
        cdata = print(handle(hnd),'-RGBImage');        
    else        
        cdata = hardcopy(hnd,rendercmd,'-r0');        
    end    

    % If the render is set to anything other then zbuffer we want to check
    %   to ensure that rendering succeeded.  We have seen instances of 
    %   OpenGL rendering having issues in the past.  
    if(~any( strcmpi(rend,{'none','zbuffer'}) ))
        % Since we want new users to have a reasonable chance of getting a 
        %    valid WebFigure, we will try again with ZBuffer, which has shown 
        %    to work in a wider variety of systems.  
        % If that also fails, throw an error. 
        if(cdataInvalid(cdata))
            %Since we know that rendering has failed for some reason we should
            %  change rendering for this webfigure in the cache to be zbuffer.
            %This is an optimization for figures that are set to use OpenGL so
            %  that we don't have to keep rendering it wrong.  
            set(hnd,'renderer', 'zbuffer');

            deploylog('finer', 'HARDCOPYOUTPUT Render returned an empty array, setting renderer to be zbuffer and trying hardcopy again');
            if feature('hgusingmatlabclasses')
                cdata = print(handle(hnd),'-RGBImage');        
            else        
                cdata = hardcopy(hnd,'-dzbuffer','-r0');        
            end               

            % Check if hardcopy still failed and throw error.
            if(cdataInvalid(cdata))
                deploylog('finer', 'HARDCOPYOUTPUT Rending failed.');
                error(  'MATLAB:webfigure:RenderFailed',...
                        'Rendering the figure failed using the %s renderer', rend);
            end
        end
    end
    
    % restore old value
    set(hnd,'PaperPositionMode',ppm);

    deploylog('finer', 'leaving HARDCOPYOUTPUT');
end

% CDATA is considered invalid if it is an array of size less then 3 or an 
%   all black image (cdata all zero's) this is probably due to the 
%   renderer failing.  
% We have seen OpenGL (which is our default renderer) fail sometime, 
%   especially on Windows 2003 and Vista Machine in IIS.  
% Sometimes it fails even when WebDev succeeds. 
function invalid = cdataInvalid(cdata)
    if(length(cdata) < 3)
        invalid=true;
    elseif(isempty(find(cdata, 1)))
        invalid=true;
    else
        invalid = false; 
    end
end
