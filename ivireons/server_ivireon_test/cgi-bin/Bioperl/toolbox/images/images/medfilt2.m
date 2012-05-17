function b = medfilt2(varargin)
%MEDFILT2 2-D median filtering.
%   B = MEDFILT2(A,[M N]) performs median filtering of the matrix
%   A in two dimensions. Each output pixel contains the median
%   value in the M-by-N neighborhood around the corresponding
%   pixel in the input image. MEDFILT2 pads the image with zeros
%   on the edges, so the median values for the points within 
%   [M N]/2 of the edges may appear distorted.
%
%   B = MEDFILT2(A) performs median filtering of the matrix A
%   using the default 3-by-3 neighborhood.
%
%   B = MEDFILT2(...,PADOPT) controls how the matrix boundaries
%   are padded.  PADOPT may be 'zeros' (the default),
%   'symmetric', or 'indexed'. If PADOPT is 'zeros', A is padded
%   with zeros at the boundaries. If PADOPT is 'symmetric', A is
%   symmetrically extended at the boundaries. If PADOPT is
%   'indexed', A is padded with ones if it is double; otherwise
%   it is padded with zeros.
%
%   Class Support
%   -------------
%   The input image A can be logical or numeric (unless the 
%   'indexed' syntax is used, in which case A cannot be of class 
%   uint16).  The output image B is of the same class as A.
%
%   Remarks
%   -------
%   If the input image A is of integer class, all of the output
%   values are returned as integers. If the number of
%   pixels in the neighborhood (i.e., M*N) is even, some of the
%   median values may not be integers. In these cases, the
%   fractional parts are discarded. Logical input is treated
%   similarly.
%
%   Example
%   -------
%       I = imread('eight.tif');
%       J = imnoise(I,'salt & pepper',0.02);
%       K = medfilt2(J);
%       figure, imshow(J), figure, imshow(K)
%
%   See also FILTER2, ORDFILT2, WIENER2.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 5.18.4.13 $  $Date: 2009/11/09 16:24:27 $

[a, mn, padopt] = parse_inputs(varargin{:});

% switch to IPP iff
% UseIPPL preference is true .AND.
% kernel is  odd .AND.
%      input data type is single .AND. kernel size is == 3x3
% .OR. input data type is (int16 .OR. uint8 .OR. uint16) .AND. kernel size
%      is between 3x3 and 19x19 

domain = ones(mn);
if (rem(prod(mn), 2) == 1)
    tf = hUseIPPL(a, mn);
    if tf
        a = hPadImage(a,domain, padopt);
        b = medianfiltermex(a, [mn(1) mn(2)]);
    else
        order = (prod(mn)+1)/2;
        b = ordfilt2(a, order, domain, padopt);
    end
else
    order1 = prod(mn)/2;
    order2 = order1+1;
    b = ordfilt2(a, order1, domain, padopt);
    b2 = ordfilt2(a, order2, domain, padopt);
	if islogical(b)
		b = b | b2;
	else
		b =	imlincomb(0.5, b, 0.5, b2);
	end
end


%%%
%%% Function parse_inputs
%%%
function [a, mn, padopt] = parse_inputs(varargin)
iptchecknargin(1,4,nargin,mfilename);

% There are several grandfathered syntaxes we have to catch
% and parse successfully, so we're going to use a strategy
% that's a little different that usual.
%
% First, scan the input argument list for strings.  The
% string 'indexed', 'zeros', or 'symmetric' can appear basically
% anywhere after the first argument.
%
% Second, delete the strings from the argument list.
%
% The remaining argument list can be one of the following:
% MEDFILT2(A)
% MEDFILT2(A,[M N])
% MEDFILT2(A,[M N],[Mb Nb])
%
% Any syntax in which 'indexed' is followed by other arguments
% is grandfathered.  Any syntax in which [Mb Nb] appears is
% grandfathered.
%
% -sle, March 1998

a = varargin{1};
% validate that the input is a 2D, real, numeric or logical matrix.
iptcheckinput(a, {'numeric','logical'}, {'2d','real'}, mfilename, 'A', 1);

charLocation = [];
for k = 2:nargin
    if (ischar(varargin{k}))
        charLocation = [charLocation k]; %#ok<AGROW>
    end
end

if (length(charLocation) > 1)
    % More than one string in input list
    eid = 'Images:medfilt2:tooManyStringInputs';
    error(eid,'%s','Too many input string arguments.');
elseif isempty(charLocation)
    % No string specified
    padopt = 'zeros';
else
    options = {'indexed', 'zeros', 'symmetric'};

    padopt = iptcheckstrs(varargin{charLocation}, options, mfilename, ...
                          'PADOPT', charLocation);
    
    varargin(charLocation) = [];
end

if (strcmp(padopt, 'indexed'))
    if (isa(a,'double'))
        padopt = 'ones';
    else
        padopt = 'zeros';
    end
end

if length(varargin) == 1,
  mn = [3 3];% default
elseif length(varargin) >= 2  
    mn = varargin{2}(:)';
    iptcheckinput(mn,{'numeric'},{'row','nonempty','real','nonzero','integer','nonnegative'},...
        mfilename,'[M N]',2);
    iptcheckinput(mn(1),{'numeric'},{'nonzero'},mfilename,'[M N]',2);
    iptcheckinput(mn(2),{'numeric'},{'nonzero'},mfilename,'[M N]',2);
    if (size(mn,2)~=2)
        msg = 'MEDFILT2(A,[M N]): Second argument must consist of two unsigned integers.';
        eid = 'Images:medfilt2:secondArgMustConsistOfTwoUnsignedInts';
        error(eid, msg);
    end
    
    if length(varargin) > 2
        % The grandfathered [Mb Nb] argument, if present, is ignored.
        msg = ['MEDFILT2(A,[M N],[Mb Nb],...) is an obsolete syntax. [Mb Nb]' ...
                 ' argument is ignored.'];
        wid = 'Images:medfilt2:obsoleteSyntax';
        warning(wid, msg);
    end
end

% The grandfathered [Mb Nb] argument, if present, is ignored.


% ------------------------------------------------------------------------
function tf = hUseIPPL(a, mn)
% switch to IPP iff
% UseIPPL preference is true .AND.
% kernel is  odd .AND.
%      input data type is single .AND. kernel size is == 3x3
% .OR. input data type is (int16 .OR. uint8 .OR. uint16) .AND. kernel size
%      is between 3x3 and 19x19 
tf = false;

switch class(a)
    case 'single'
        if all(mn==[3 3])
            tf = true;
        end
    case {'uint16', 'int16', 'uint8'}
        if all(mn >= [3 3]) && all(mn <= [19 19])
            tf = true;
        end
end

tf = tf & iptgetpref('UseIPPL');

% -------------------------------------------------------------------------
function A = hPadImage(A, domain, padopt)
% pad the image suitably - 
domainSize = size(domain);
center = floor((domainSize + 1) / 2);
[r,c] = find(domain);
r = r - center(1);
c = c - center(2);
padSize = [max(abs(r)) max(abs(c))];
if (strcmp(padopt, 'zeros'))
    A = padarray(A, padSize, 0, 'both');
elseif (strcmp(padopt, 'symmetric'))
    A = padarray(A, padSize, 'symmetric', 'both');
else
%   This block should never be reached.
    eid = sprintf('Images:%s:hPadImage:incorrectPaddingOption', mfilename);
    msg = 'Padding option cannot be ones when using IPPL';
    error(eid,'%s',msg);
end