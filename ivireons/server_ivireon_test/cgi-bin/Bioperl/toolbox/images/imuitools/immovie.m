function mov = immovie(varargin)
%IMMOVIE Make movie from multiframe image.
%   MOV = IMMOVIE(X,MAP) returns an array of movie frame structures MOV
%   containing the images in the multiframe indexed image X with the
%   colormap MAP. X is an M-by-N-by-1-by-K array, where K is the number of
%   images. All the images in X must have the same size and must use the
%   same colormap MAP.  
%
%   To play the movie, call IMPLAY.
%
%   MOV = IMMOVIE(RGB) returns an array of movie frame structures MOV from
%   the images in the multiframe truecolor image RGB. RGB is an
%   M-by-N-by-3-by-K array, where K is the number of images. All the images
%   in RGB must have the same size.
%
%   Class Support
%   -------------
%   An indexed image can be uint8, uint16, single, double, or logical. A
%   truecolor image can be uint8, uint16, single, or double. MOV is a
%   MATLAB movie frame. For details about the movie frame structure,
%   see the reference page for GETFRAME. 
%
%   Example
%   -------
%        load mri
%        mov = immovie(D,map);
%        implay(mov)
%
%   Remark
%   ------
%   You can also make movies from images by using the MATLAB function
%   AVIFILE, which creates AVI files.  In addition, you can convert an
%   existing MATLAB movie into an AVI file by using the MOVIE2AVI function.
%
%   See also AVIFILE, GETFRAME, IMPLAY, MONTAGE, MOVIE, MOVIE2AVI.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/04/03 03:12:32 $

[X,map] = parse_inputs(varargin{:});

numframes = size(X,4);
mov = repmat(struct('cdata',[],'colormap',[]),[1 numframes]);

isIndexed = size(X,3) == 1;

for k = 1 : numframes
  if isIndexed
      mov(k).cdata = iptgate('ind2rgb8',X(:,:,:,k),map);
  else
      mov(k).cdata = X(:,:,:,k);      
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X,map] = parse_inputs(varargin)

iptchecknargin(1, 2, nargin,mfilename);

switch nargin
    case 1                      % immovie(RGB)
        X = varargin{1};
        map = [];
    case 2                      % immovie(X,map)
        X = varargin{1};
        map = varargin{2};
        % immovie(D,size) OBSOLETE
        callingObsoleteSyntax = strcmp(class(map), 'double') && ...
            isequal(size(map), [1 3]) && (prod(map) == numel(X));
        if callingObsoleteSyntax
            id = sprintf('Images:%s:obsoleteSyntax',mfilename);
            error(id, ...
                'IMMOVIE(D,size) is an obsolete syntax and is no longer supported. Use IMMOVIE(X,map) instead.');
        end
end

% Check parameter validity

if isempty(map) %RGB image
    iptcheckinput(X, {'uint8','uint16','single','double'},{},...
        'RGB', mfilename, 1);
    if size(X,3)~=3
        msgId = sprintf('Images:%s:invalidTruecolorImage', mfilename);
        error(msgId, ...
            'Truecolor RGB image has to be an M-by-N-by-3-by-K array.');
    end
    if ~isa(X,'uint8')
        X = im2uint8(X);
    end

else % indexed image
    iptcheckinput(X, {'uint8','uint16','double','single','logical'}, ...
        {},'X', mfilename, 1);
    if size(X,3) ~= 1
        msgId = sprintf('Images:%s:invalidIndexedImage', mfilename);
        error(msgId, ...
            'Indexed image has to be an M-by-N-by-1-by-K array.');
    end
    iptcheckmap(map, mfilename, 'MAP', 2);

    if ~isa(X,'uint8')
        X = im2uint8(X,'indexed');
    end
end