function varargout = imsave(h)
%IMSAVE Save Image tool.
%   IMSAVE creates a Save Image tool in a separate figure that is
%   associated with the image in the current figure, called the target
%   image. The Save Image tool displays an interactive file chooser for the
%   user to select a path and filename, and saves the target image to a
%   file.  The file is saved using IMWRITE with the default options.
%
%   If an existing filename is specified or selected, a warning message is
%   displayed.  The user may select Yes to use the filename or No to return
%   to the dialog to select another filename.  If the user selects Yes, the
%   Save Image tool will attempt to overwrite the target file.
%
%   IMSAVE(H) creates a Save Image tool associated with the image specified
%   by the handle H.  H can be an image, axes, uipanel, or figure handle.
%   If H is an axes or figure handle, IMSAVE uses the first image returned
%   by FINDOBJ(H,'Type','image').
%
%   [FILENAME, USER_CANCELED] = IMSAVE(…) returns the full path to the file
%   selected in FILENAME.  If the user presses the Cancel button,
%   USER_CANCELED will be TRUE.  Otherwise, USER_CANCELED will be FALSE.
%
%   The Save Image tool is modal; it blocks the MATLAB command line until
%   the user responds.
%
%   Example
%   -------
%      imshow peppers.png
%      imsave
%
%   See also IMFORMATS, IMWRITE, IMPUTFILE, IMGETFILE.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/11/24 14:58:23 $

% Get handles
if nargin < 1
  h_fig = get(0,'CurrentFigure');
  h_ax  = get(h_fig,'CurrentAxes');
  h_im  = findobj(h_ax,'Type','image');
else
  iptcheckhandle(h,{'image','axes','figure','uipanel'},mfilename,'h',1);
  h_im = imhandles(h);
  if numel(h_im) > 1
    h_im = h_im(1);
  end
  h_fig = ancestor(h_im,'figure');
end

if isempty(h_im)
  eid = sprintf('Images:%s:noImage',mfilename);
  msg = sprintf('%s expects a current figure containing an image.',...
                upper(mfilename));
  error(eid,'%s',msg);
end

% we expect either 0, 1, or 2 output arguments
if (nargout > 2)
    error('Images:imsave:tooManyOutputs', ...
        'Less than three output arguments expected.');
end

% We need to drawnow or else imputfile can block before previous IMSHOW
% commands have completed
drawnow;

% Display Save Image dialog
[filename, ext, user_canceled] = imputfile;

if ~user_canceled
    % Validate filename and extension
    filename = iptui.validateFileExtension(filename,ext);

    % Get image data
    data_args{1} = get(h_im,'CData');

    % How many bands of data
    is_single_band = ndims(data_args{1}) == 2;

    % Check if our image is indexed
    cdata_mapping = get(h_im,'CDataMapping');
    is_indexed_image = is_single_band && strcmp(cdata_mapping,'direct');

    % Include figure colormap for indexed images
    if is_indexed_image
        data_args{2} = get(h_fig,'Colormap');
    end

    % Write the data
    imwrite(data_args{:},filename,ext);
end

% Assign optional output args if requested
if (nargout > 0)
    varargout{1} = filename;
end
if (nargout > 1)
    varargout{2} = user_canceled;
end
