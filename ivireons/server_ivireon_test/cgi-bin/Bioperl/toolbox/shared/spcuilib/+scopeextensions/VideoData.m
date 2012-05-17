classdef VideoData < uiscopes.CoreData
    %VideoData   Define the VideoData class.
    %
    %    VideoData methods:
    %        method1 - Example method
    %
    %    VideoData properties:
    %        Prop1 - Example property
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2010/01/25 22:46:13 $
    
    properties
        
        ColorSpace = 'intensity';
        ColorMap = [];
    end
    
    methods
        
        function this = VideoData
            %VideoData   Construct the VideoData class.
            
        end
        
        function b = isRGB(this)
            b = strcmp(this.ColorSpace, 'rgb');
        end
        
    end
    
    methods
        
        function set.ColorSpace(this, colorSpace)
            if ~any(strcmp(colorSpace, {'rgb', 'intensity'}))
                DAStudio.error('spcuilib:scopeextensions.VideoData:InvalidColorSpace');
            end
            this.ColorSpace = colorSpace;
        end
        
        function set.ColorMap(this, cmap)
            % Check for valid colormap
            
            if ~isa(cmap,'double') || issparse(cmap) || ~isreal(cmap),
                eid='scope:InvalidColormapDType';
                msg='Colormap must be real and double-precision.';
                error(eid,'%s',msg);
            end
            if isempty(cmap), return; end
            
            if (ndims(cmap)~=2) || (size(cmap,2)~=3),
                eid='scope:InvalidColormapDims';
                msg='Colormap must be an Nx3 matrix.';
                error(eid,'%s',msg);
            end
            
            this.ColorMap = cmap;
            
        end
    end
    
    methods (Static)
        
        function [A, cspace, fmt, cmap, errMsg] = checkVideoFormat(A, isSingleFrame)
            %CHECKVIDEOFORMAT Check the video format
            
            
            % DetermineMovieFormat
            %  cspace: 'intensity','rgb'
            %  fmt: 'struct','array'
            %  cmap: colormap array, [] or Mx3
            %
            % An empty movie is allowed
            %
            % 'A' is returned in case any fixups are needed
            % Defined fixups:
            %  struct:
            %      - guarantee at least one element in struct, such that
            %        we never store a 0x0 struct ... we can always retrieve
            %        A(1).cdata and A(1).colormap
            %   array:
            %      - no fixups needed
            %
            % NOTE: Do *not* do an early-return from this function
            %       An error is assumed unless the last line of each
            %       code path executes (checkArrayFormat)
            
            if nargin < 2
                isSingleFrame = false;
            end
            
            fmt    = 'array';     % default value: 'struct', 'array'
            cspace = 'intensity'; % default value: 'intensity', 'rgb'
            cmap   = [];          % No colormap by default.
            
            % Check for movie structure format
            %
            if isstruct(A)
                % movie structure input
                %   check for .colormap and .cdata present
                %   check for MxN or MxNx3 sizes in each frame
                
                % Check for required fields
                if ~isfield(A, 'colormap') || ~isfield(A, 'cdata'),
                    errMsg = 'Movie structure does not contain ".cdata" and/or ".colormap" fields.';
                    return
                end
                if isempty(A)
                    % a 0x0 struct with the proper fields has been passed
                    % we "normalize" this with a fixup to be a 1x1 struct
                    A(1).cdata    = uint8([]);
                    A(1).colormap = [];
                end
                
                % Check for empty colormap fields and movie datatypes
                %
                % How aggressively should we check the structure?
                %  - check all frames (thorough but time consuming)
                %  - check just the first frame (quick but incomplete)
                %
                iNumToCheck = 1;           % check only first frame
                % iNumToCheck = length(A)  % check each and every frame
                
                warnCmap = true;      % warn on first non-empty cmap found
                for i=1:iNumToCheck   % check all entries in structure
                    % Check colormap:
                    if ~isempty(A(i).colormap)
                        if warnCmap
                            % Allow non-empty colormap
                            
                            % Suppress warning, just use the first cmap entry
                            %
                            % eid = 'mplay:StructCmapNotEmpty';
                            %msg = sprintf(['Movie structure contains non-empty colormap entry.\n'...
                            %       ' - Using first non-empty colormap in movie structure\n' ...
                            %       ' - Overwriting user-specified colormap\n' ...
                            %       ' - Disregarding colormap changes in subsequent frames']);
                            %warndlg(msg,'MPlay Warning','modal');
                            %warning(eid,msg);
                            
                            cmap=A(i).colormap;
                            warnCmap = false;  % no more warnings
                        end
                    end
                end % loop over struct entries
                
                fmt = 'struct';
                
                % special-case call to check function
                % we know this is a movie struct, and if individual movie frames
                % are MxNx3, we know these are RGB, not 3-frame intensities
                % So pass special flag indicating "MxNx3=rgb"
                [cspace,errMsg] = checkArrayFormat(A(1).cdata, isSingleFrame, 1);
            else
                % Not struct - must be array-based data
                fmt = 'array';
                [cspace,errMsg] = checkArrayFormat(A, isSingleFrame);
            end
            
            % Do not return a colormap if we are using an RGB image.
            if strcmp(cspace, 'rgb')
                cmap = [];
            end
        end
    end
end

% -------------------------------------------------------------------------
function [cspace,errMsg] = checkArrayFormat(A, isSingleFrame, RGBif3)
% Check N-D array for proper video format
%  - MxNxT: intensity movie
%  - MxNx3xT: RGB movie
%
% A:
%   Movie sequence coming from MATLAB workspace,
%   assumed here to be an array (2/3/4-D)
%
% RGBif3:
%   Special-case override flag forcing interpretation of a
%   MxNx3 array as RGB.  In the usual situations, this is to
%   be interpreted as a 3-frame intensity video.  In exceptional
%   situations (the only one here: a MATLAB struct-format movie),
%   this is to be interpreted as a single RGB frame.  Setting this
%   flag to TRUE causes this latter interpretation.  By default,
%   it's set to FALSE (MxNx3 is a 3-frame intensity movie).

errMsg = '';

if nargin<3, RGBif3 = false; end
cspace = 'intensity';  % default

if ~isnumeric(A) && ~islogical(A)
    errMsg = 'Invalid video data - must be a numeric or logical data type.';
    return
end
if issparse(A)
    errMsg  = 'Sparse arrays are not supported for video data.';
    return
end
% Check complexity
if ~isreal(A)
    errMsg = 'Complex values are not supported for video data.';
    return
end
% Check datatypes:
switch class(A);
    case {'double','single','uint8','uint16','uint32','int8','int16','int32','logical'}
        % do nothing
    otherwise
        errMsg = sprintf('Numeric data type "%s" is not supported for video data.',class(A));
        return
end

% Check for 3-D and 4-D RGB array formats
%
% if numel(A)==0,
%     errMsg = 'Movie contains no video data.';
%     return
% end

nd = ndims(A);
% Add a dim representing the additional frames.
if isSingleFrame
    nd = nd+1;
end
sz = size(A);
if nd > 4
    errMsg = sprintf('%s\n%s', ...
        'Invalid movie format: array contains more than 4 dimensions.',  ...
        'Consider using SQUEEZE to convert to 4-D or 3-D array.');
    return
    
elseif nd==4
    switch sz(3)
        case 1
            cspace = 'intensity';
        case 3
            cspace = 'rgb';
        otherwise
            errMsg = sprintf('%s %s', ...
                'Invalid movie format: size of 3rd dimension must be 1', ...
                'for intensity or 3 for RGB.');
            return
    end
elseif nd==3
    % We could warn user that MxNx3 input is interpreted as 3 intensity
    % frames, but it's in the help so we'll keep quiet:
    %     if (sz(3)==3), warning(''); end
    %
    % However, allow flag override (RGBif3) of this interpretation,
    % because workspace structs demand MxNx3 for each frame to be
    % interpreted as RGB
    %
    if RGBif3
        cspace = 'rgb';
    else
        cspace = 'intensity';
    end
    
else  % 2-D input
    cspace = 'intensity';
end
end

% [EOF]
