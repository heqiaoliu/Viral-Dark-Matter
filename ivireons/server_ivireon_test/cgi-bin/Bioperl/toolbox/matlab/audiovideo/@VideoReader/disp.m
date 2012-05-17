function disp(obj)
%DISP Display method for VideoReader objects.
%
%    DISP(OBJ) displays information pertaining to the VideoReader object.
%
%    See also VIDEOREADER/GET.

%    JCS
%    Copyright 2004-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2010/05/10 17:23:01 $

if length(obj) > 1
    disp@hgsetget(obj);
    return;
end

% Determine if we want a compact or loose display.
isloose = strcmp(get(0,'FormatSpacing'),'loose');
if isloose,
   newline=sprintf('\n');
else
   newline=sprintf('');
end

% =========================================================================
% OBJECT PROPERTY VARIABLES:
% =========================================================================
objprops = {'Name', ...
            'BitsPerPixel', ...
            'FrameRate', ...
            'Height', ...
            'Width',...
            'NumberOfFrames'};

ObjVals = get(obj,objprops);

[Name, BitsPerPixel, FrameRate, Height, Width, NumberOfFrames] = ...
    deal(ObjVals{:});

% =========================================================================
% DYNAMIC DISPLAY BEGINS HERE...
% =========================================================================
% Display header:

st = sprintf('%sSummary of Multimedia Reader Object for ''%s''.\n', ...
    newline, Name);
st=[st sprintf(newline)];
st=[st sprintf('  Video Parameters:  ')];

FrameString = '';
if (FrameRate > 0.0)
    FrameString = sprintf('%0.2f frames per second, ', FrameRate);
end

FormatString = 'RGB24'; % TODO: For now, always RGB24
st = [st sprintf('%s%s %dx%d.\n', FrameString, FormatString, ...
    Width, Height)];
st=[st sprintf('                     ')]; % Indent to align with previous row.

if (isempty(NumberOfFrames))
    st = [st sprintf('Unable to determine video frames available.\n')];
else
    st = [st sprintf('%0d total video frames available.\n', NumberOfFrames)];
end
st=[st  sprintf(newline)];

% File identifier...fid=1 outputs to the screen.
fid=1;
fprintf(fid,'%s', st);

    