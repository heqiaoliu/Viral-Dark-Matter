function varargout = bwdist(varargin)
%BWDIST Distance transform of binary image.
%   D = BWDIST(BW) computes the Euclidean distance transform of the
%   binary image BW. For each pixel in BW, the distance transform assigns
%   a number that is the distance between that pixel and the nearest
%   nonzero pixel of BW. BWDIST uses the Euclidean distance metric by
%   default.  BW can have any dimension.  D is the same size as BW.
%
%   [D,L] = BWDIST(BW) also computes the nearest-neighbor transform and
%   returns it as a label matrix, L.  L has the same size as BW and D.
%   Each element of L contains the linear index of the nearest nonzero
%   pixel of BW.
%
%   [D,L] = BWDIST(BW,METHOD) lets you compute an alternate distance
%   transform, depending on the value of METHOD.  METHOD can be
%   'cityblock', 'chessboard', 'quasi-euclidean', or 'euclidean'.  METHOD
%   defaults to 'euclidean' if not specified.  METHOD may be
%   abbreviated.
%
%   The different methods correspond to different distance metrics.  In
%   2-D, the cityblock distance between (x1,y1) and (x2,y2) is abs(x1-x2)
%   + abs(y1-y2).  The chessboard distance is max(abs(x1-x2),
%   abs(y1-y2)).  The quasi-Euclidean distance is:
%
%       abs(x1-x2) + (sqrt(2)-1)*abs(y1-y2),  if abs(x1-x2) > abs(y1-y2)
%       (sqrt(2)-1)*abs(x1-x2) + abs(y1-y2),  otherwise
%
%   The Euclidean distance is sqrt((x1-x2)^2 + (y1-y2)^2).
%
%   Notes
%   -----
%   BWDIST uses a fast algorithm to compute the true Euclidean distance
%   transform.  The other methods are provided primarily for pedagogical
%   reasons.
%
%   The function BWDIST changed in version 6.4 (R2009b). Previous versions
%   of the Image Processing Toolbox used different algorithms for
%   computing the Euclidean distance transform and the associated label
%   matrix. If you need the same results produced by the previous 
%   implementation, use the function BWDIST_OLD.
%
%   Class support
%   -------------
%   BW can be numeric or logical, and it must be nonsparse.  D and L are
%   single matrices with the same size as BW.
%
%   Examples
%   --------
%   Here is a simple example of the Euclidean distance transform:
%
%       bw = zeros(5,5); bw(2,2) = 1; bw(4,4) = 1;
%       [D,L] = bwdist(bw)
%
%   This example compares 2-D distance transforms for the four methods:
%
%       bw = zeros(200,200); bw(50,50) = 1; bw(50,150) = 1;
%       bw(150,100) = 1;
%       D1 = bwdist(bw,'euclidean');
%       D2 = bwdist(bw,'cityblock');
%       D3 = bwdist(bw,'chessboard');
%       D4 = bwdist(bw,'quasi-euclidean');
%       figure
%       subplot(2,2,1), subimage(mat2gray(D1)), title('Euclidean')
%       hold on, imcontour(D1)
%       subplot(2,2,2), subimage(mat2gray(D2)), title('City block')
%       hold on, imcontour(D2)
%       subplot(2,2,3), subimage(mat2gray(D3)), title('Chessboard')
%       hold on, imcontour(D3)
%       subplot(2,2,4), subimage(mat2gray(D4)), title('Quasi-Euclidean')
%       hold on, imcontour(D4)
%
%   This example compares isosurface plots for the distance transforms of
%   a 3-D image containing a single nonzero pixel in the center:
%
%       bw = zeros(50,50,50); bw(25,25,25) = 1;
%       D1 = bwdist(bw);
%       D2 = bwdist(bw,'cityblock');
%       D3 = bwdist(bw,'chessboard');
%       D4 = bwdist(bw,'quasi-euclidean');
%       figure
%       subplot(2,2,1), isosurface(D1,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Euclidean')
%       subplot(2,2,2), isosurface(D2,15), axis equal, view(3)
%       camlight, lighting gouraud, title('City block')
%       subplot(2,2,3), isosurface(D3,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Chessboard')
%       subplot(2,2,4), isosurface(D4,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Quasi-Euclidean')
%
%   See also BWDIST_OLD, BWULTERODE, WATERSHED.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.7.4.8 $  $Date: 2010/03/22 03:49:10 $

[BW,method] = parse_inputs(varargin{:});

% Computing the nearest-neighbor transform is expensive in memory, so we
% only want to call the lower-level function ddist with two output
% arguments if we have been called with two output arguments. Also, for the
% Euclidean case, bwdistComputeEDTFT will be called instead of
% bwdistComputeEDT, when there are two output arguments.
if nargout <= 1
    varargout = cell(1,1);
else
    varargout = cell(1,2);
end

iptcheckinput(BW,{'logical'},{'nonsparse'},mfilename,'BW',1);

if strcmp(method,'euclidean')
    % Use really fast methods for multidimensional Euclidean distance
    % transforms and Euclidean closest feature transforms.
    if (nargout == 2)
        s = size(BW);
        Idx = reshape(single(1:numel(BW)), s);
        [D, L] = bwdistComputeEDTFT(BW, Idx);
        varargout{1} = sqrt(D);
        varargout{2} = L;
    else
        D = bwdistComputeEDT(BW);
        varargout{1} = sqrt(D);      
    end    
else
    % All methods other than Euclidean use the same algorithm,
    % implemented in private/ddist.  The only difference is in the
    % connectivity and weights used.
    switch method
      case 'cityblock'
        conn = conndef(ndims(BW),'minimal');
        weights = ones(size(conn));
        
      case 'chessboard'
        conn = conndef(ndims(BW),'maximal');
        weights = ones(size(conn));
        
      case 'quasi-euclidean'
        conn = conndef(ndims(BW),'maximal');
        
        % For quasi-Euclidean, form a weights array whose values are the
        % distances between the corresponding elements and the center
        % element.
        kk = cell(1,ndims(BW));
        [kk{:}] = ndgrid(-1:1);
        weights = zeros(size(conn));
        for p = 1:ndims(BW)
            % Although the Euclidean distance formula certainly involves
            % squaring each term, all terms here are either 0, 1, or -1,
            % so that's why the abs() term isn't squared below.
            weights = weights + abs(kk{p});
        end
        weights = sqrt(weights);
        
      otherwise
        eid = 'Images:bwdist:unrecognizedMethodString';
        error(eid, 'Internal problem - unrecognized method string: %s', method);
    end
    
    % check if conn is valid
    try
      iptcheckconn(conn,mfilename,'conn',5);  %bogus argument position
    catch %#ok<CTCH>
      displayInternalError('conn');
    end
    
    % Postprocess the weights to make sure the center weight is
    % zero, and to keep only values corresponding to nonzero
    % connectivity values.
    weights = weights(:);
    weights((end+1)/2) = 0.0;
    weights(~conn) = [];
    if ( ~isa(weights,'double') || ~isreal(weights) || issparse(weights) || ...
          any(isnan(weights(:))) )
      displayInternalError('weights');
    end
    
    % Call the dual-scan neighborhood based algorithm.
    [varargout{:}] = ddist(BW,single(conn),single(weights));
end

%--------------------------------------------------

function [BW,method] = parse_inputs(varargin)

iptchecknargin(1,2,nargin,mfilename);
iptcheckinput(varargin{1}, {'logical','numeric'}, {'nonsparse', 'real'}, ...
              mfilename, 'BW', 1);
BW = varargin{1} ~= 0;

if nargin < 2
    method = 'euclidean';
else
    valid_methods = {'euclidean','cityblock','chessboard','quasi-euclidean'};
    method = iptcheckstrs(varargin{2}, valid_methods, ...
                          mfilename, 'METHOD', 2);
end

%----------------------------------------------------
function displayInternalError(string)

eid = sprintf('Images:%s:internalError',mfilename);
msg = sprintf('Internal error: %s is not valid.',upper(string));
error(eid,'%s',msg);

