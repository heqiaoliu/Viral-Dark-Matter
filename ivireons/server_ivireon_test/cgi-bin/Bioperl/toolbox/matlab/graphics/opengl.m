function str = opengl(mode, onoff)
%OPENGL Change automatic selection mode of OpenGL rendering.
%   The auto selection mode of OpenGL is only relevant when the
%   RendererMode of the FIGURE is AUTO.
%   OPENGL AUTOSELECT allows OpenGL to be auto selected if OpenGL
%   is available and if there is graphics hardware on the host machine.
%   OPENGL NEVERSELECT disables auto selection of OpenGL.
%   OPENGL ADVISE prints a message to the command window if OpenGL 
%   rendering is advised, but RenderMode is set to manual.
%   OPENGL, by itself, returns the current auto selection state.
%   OPENGL INFO prints information with the Version and Vendor
%   of the OpenGL on your system.  The return argument can be used
%   to programmatically determine if OpenGL is available on your
%   system.
%   OPENGL DATA returns a structure containing the same data
%   printed when OPENGL INFO is called.
%   OPENGL SOFTWARE forces MATLAB to use software OpenGL rendering
%   instead of hardware OpenGL.
%   On unix, this only works if OpenGL has not yet been used.
%   OPENGL HARDWARE reverses the SOFTWARE option.
%   If you do not have hardware acceleration, MATLAB will
%   automatically switch to software OpenGL rendering.
%   Note: Use OPENGL INFO to determine if software or hardware
%   rendering is being used.  This will load the OpenGL Library.
%   OPENGL VERBOSE display verbose messages about OpenGL
%   initialization (if not already loaded) or other runtime messages.
%   OPENGL QUIET disable verbose messages.
%   OPENGL('BUGNAME', 0)
%   OPENGL('BUGNAME', 1) BUGNAME is a string indicated as a way
%   to work around an opengl driver bug from the OPENGL INFO command.
%   Pass in 1 to enable the workaround or 0 to disable it.
%
%   Note that the auto selection state only specifies that OpenGL
%   should or not be considered for rendering, it does not
%   explicitly set the rendering to OpenGL.  This can be done by
%   setting the Renderer property of FIGURE to OpenGL,
%   e.g. set(GCF, 'Renderer','OpenGL');    

%   Copyright 1984-2009 The MathWorks, Inc.

if feature('HGUsingMATLABClasses')
    if nargin == 0
        str = 'AutoSelect';
    else
        if nargout == 0
            hgopengl(mode);
        elseif nargin == 2
            hgopengl(mode, onoff);
        else
            str = hgopengl(mode);
        end
    end
    return;
end

if (nargin == 0)
    current_setting = feature('openglmode');
    switch(current_setting),
      case 0,
        str = 'NeverSelect';
      case 1,
        str = 'Advise';
      case 2
        str = 'AutoSelect';
    end
else
    switch(lower(mode)),
      case 'neverselect',
        feature('openglmode', 0);
      case 'advise',
        feature('openglmode', 1);
      case 'autoselect',
        feature('openglmode', 2);
      case 'software',
        if strncmp(computer,'MAC',3)
            warning('MATLAB:opengl:switchToSoftwareMacNotSupported'...
                    ,['Switching to software OpenGL rendering is not supported'...
                      ' on the MAC platform']);
        elseif isunix
            if feature('OpenGLLoadStatus') == 0
                feature('UseMesaSoftwareOpenGL',1)
            else
                warning('MATLAB:opengl:switchToSoftwareUnixNotSupported'...
                        ,['Switching to software OpenGL rendering at runtime on ' ...
                          'unix is not supported.']);
            end
        else % windows
            feature('OpenGLLoadStatus',1)
            if feature('OpenGLLoadStatus') == 0
                % We failed to get OpenGL loaded.  Already lots of warnings provided.
            else
                feature('usegenericopengl',1);
            end
        end
      case 'hardware'
        if strncmp(computer,'MAC',3)
            warning('MATLAB:opengl:switchToHardwareMacNotSupported'...
                    ,['Switching to hardware OpenGL rendering is not supported'...
                      ' on the MAC platform']);
        elseif isunix
            if feature('OpenGLLoadStatus') == 0
                feature('UseMesaSoftwareOpenGL',0)
            else
                warning('MATLAB:opengl:switchToHardwareUnixNotSupported'...
                        ,['Switching to hardware OpenGL rendering at runtime on ' ...
                          'unix is not supported.']);
            end
        else % windows
            feature('OpenGLLoadStatus',1)
            if feature('OpenGLLoadStatus') == 0
                % We failed to get OpenGL loaded.  Already lots of warnings provided.
            else
                feature('usegenericopengl',0);
            end
        end
      case 'info',
        try
            feature('OpenGLLoadStatus',1)
            if feature('OpenGLLoadStatus') == 0
                % We failed to get OpenGL loaded.
                warning('MATLAB:opengl:loadStatus','OpenGL failed to load.')
                if(nargout)
                    str = 0;
                end        
            else
                if(nargout==0),
                    feature('getopenglinfo');
                else
                    str = feature('getopenglinfo');
                end
            end
        catch ex
            if(nargout==0)
                warning('MATLAB:opengl:infoQuery',...
                        'An error occurred while querying for OpenGL:')
                disp(ex.getReport('basic'));
            else
                str = 0;
            end
        end    
      case 'data'
        % If the below features fail, this is thedefault answer.
        str.Version = '';
        str.Vendor = '';
        str.Renderer = 'None';
        str.MaxTextureSize = 0;
        str.Software = 1;
        str.Extensions = {};
        try
            feature('OpenGLLoadStatus',1)
            if feature('OpenGLLoadStatus') == 0
                % We failed to get OpenGL loaded.  Already lots of warnings provided.
            else
                str = feature('getopengldata');
            end
        catch ex
            warning('MATLAB:opengl:dataQuery',...
                    'An error occurred while querying for OpenGL:')
            disp(ex.getReport('basic'));
        end
      case 'verbose'
        % A 2 means to enable the verbosity flag before and during
        % OpenGL initialization
        feature('OpenGLLoadStatus',2)
        if feature('OpenGLLoadStatus') == 0
            % We failed to get OpenGL loaded.  Already lots of warnings provided.
        else
            % If already loaded, just specify the verbosity.
            feature('OpenGLVerbose', 1);
        end
      case 'quiet'
        feature('OpenGLLoadStatus',1)
        if feature('OpenGLLoadStatus') == 0
            % We failed to get OpenGL loaded.  Already lots of warnings provided.
        else
            % If already loaded, just specify the verbosity.
            feature('OpenGLVerbose', 0);
        end
      otherwise
        if ~strncmpi(mode,'opengl',6)
            error('MATLAB:opengl:invalidInput', 'OpenGL incorrect input argument: %s',mode)
        else
            try
                feature('OpenGLLoadStatus',1)
                if nargin == 1
                    str = feature(mode);
                else
                    feature(mode,onoff);
                end
            catch
                error('MATLAB:opengl:invalidBugWorkaround','Unknown OpenGL bug workaround: %s',mode)
            end
        end
    end
end
