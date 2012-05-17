function [cout,lut] = bwmorph(a,op,n)
%BWMORPH Morphological operations on binary image.
%   BW2 = BWMORPH(BW1,OPERATION) applies a specific
%   morphological operation to the binary image BW1.  
%
%   BW2 = BWMORPH(BW1,OPERATION,N) applies the operation N
%   times.  N can be Inf, in which case the operation is repeated
%   until the image no longer changes.
%
%   OPERATION is a string that can have one of these values:
%      'bothat'       Subtract the input image from its closing
%      'branchpoints' Find branch points of skeleton
%      'bridge'       Bridge previously unconnected pixels
%      'clean'        Remove isolated pixels (1's surrounded by 0's)
%      'close'        Perform binary closure (dilation followed by
%                       erosion)  
%      'diag'         Diagonal fill to eliminate 8-connectivity of
%                       background
%      'dilate'       Perform dilation using the structuring element
%                       ones(3) 
%      'endpoints'    Find end points of skeleton
%      'erode'        Perform erosion using the structuring element
%                       ones(3) 
%      'fill'         Fill isolated interior pixels (0's surrounded by
%                       1's)
%      'hbreak'       Remove H-connected pixels
%      'majority'     Set a pixel to 1 if five or more pixels in its
%                       3-by-3 neighborhood are 1's
%      'open'         Perform binary opening (erosion followed by
%                       dilation) 
%      'remove'       Set a pixel to 0 if its 4-connected neighbors
%                       are all 1's, thus leaving only boundary
%                       pixels
%      'shrink'       With N = Inf, shrink objects to points; shrink
%                       objects with holes to connected rings
%      'skel'         With N = Inf, remove pixels on the boundaries
%                       of objects without allowing objects to break
%                       apart
%      'spur'         Remove end points of lines without removing
%                       small objects completely
%      'thicken'      With N = Inf, thicken objects by adding pixels
%                       to the exterior of objects without connected
%                       previously unconnected objects
%      'thin'         With N = Inf, remove pixels so that an object
%                       without holes shrinks to a minimally
%                       connected stroke, and an object with holes
%                       shrinks to a ring halfway between the hold
%                       and outer boundary
%      'tophat'       Subtract the opening from the input image
%
%   Class Support
%   -------------
%   The input image BW1 can be numeric or logical.
%   It must be 2-D, real and nonsparse.  The output image 
%   BW2 is logical.
%
%   Examples
%   --------
%       BW1 = imread('circles.png');
%       figure, imshow(BW1)
%       BW2 = bwmorph(BW1,'remove');
%       BW3 = bwmorph(BW1,'skel',Inf);
%       figure, imshow(BW2)
%       figure, imshow(BW3)
%
%   See also ERODE, DILATE, BWEULER, BWPERIM.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 5.28.4.10 $  $Date: 2009/07/27 20:15:23 $

% The second output argument, LUT, is intentionally undocumented. In the 
% initial release of the Image Processing Toolbox, all the operations 
% supported by bwmorph used a single look-up table, which was returned as 
% the second output argument.  In subsequent releases, however, bug fixes 
% and enhancements resulted in some operations no longer using a single 
% look-up table. As a result, the second output argument no longer served 
% the purpose envisioned in the original design of the bwmorph syntax. To 
% reduce compatibility problems, the second output argument was retained 
% in the code, but it has been removed from the documentation.  For 
% operations which do not use a single look-up table, the second output 
% argument is returned as [].

%
% Input argument parsing
%
error(nargchk(2,3,nargin,'struct'));
if (nargin < 3)
    n = 1;
end

iptcheckinput(a,{'numeric' 'logical'},{'real' 'nonsparse' '2d'}, ...
              mfilename, 'BW', 1);
if ~islogical(a)
    a = a ~= 0;
end

if ischar(op),
    % BWMORPH(A, 'op', n)
    
    %
    % Find out what operation has been requested
    %
    opString = lower(op);
    matchStrings = [ ...
            'bothat      ' 
            'branchpoints'
            'bridge      '
            'clean       '
            'close       '
            'diag        '
            'dilate      '
	        'endpoints   '
            'erode       '
            'fatten      '
            'fill        '
            'hbreak      '
            'majority    '
            'perim4      '
            'perim8      '
            'open        '
            'remove      '
            'shrink      '
            'skeleton    '
            'spur        '
            'thicken     '
            'thin        '
            'tophat      '];
    functionStrings = [
            'bothat      '
            'branchpoints'
            'bridge      '
            'clean       '
            'close       '
            'diag_       '
            'dilate      '
	        'endpoints   '
            'erode       '
            'fatten      '
            'fill_       '
            'hbreak      '
            'majority    '
            'perim4      '
            'perim8      '
            'open        '
            'remove      '
            'shrink      '
            'skel        '
            'spur        '
            'thicken     '
            'thin        '
            'tophat      '];
    idx = strmatch(opString, matchStrings);
    if (isempty(idx))
        eid = 'Images:bwmorph:unknownOperation';
        message = sprintf('Unknown operation "%s"', opString);
        error(eid, '%s', message);
    elseif (length(idx) > 1)
        eid = 'Images:bwmorph:ambiguousMatch';
        message = sprintf('Input string "%s" matches multiple operations', ...
                opString);
        error(eid, '%s', message);
    end
   
    %
    % Call the appropriate subfunction
    %
    fcn = deblank(functionStrings(idx,:));
    c = a;
    iter = 1;
    done = n == 0;
    while (~done)
        lastc = c;
        [c,lut] = feval(fcn, c);
        done = ((iter >= n) | isequal(lastc, c));
        iter = iter + 1;
    end
    
else
    % BWMORPH(A, lut, n)

    %
    % Pass on the call to applylut
    %
    lut = op;
    if (isempty(lut))
        eid = 'Images:bwmorph:emptyLUT';
        error(eid, '%s', 'LUT can''t be empty');
    end
    c = a;
    done = n == 0;
    iter = 1;
    while (~done)
        lastc = c;
        c = applylut(c, lut);
        done = ((iter >= n) | isequal(lastc, c));
        iter = iter + 1;
    end
    
end

if (nargout == 0)
    imshow(c);
else
    cout = c;
end
if ((nargout == 2) && isempty(lut))
    wid = 'Images:bwmorph:lutOutput';
    message = ['LUT output argument is no longer supported', ...
                ' for the "', deblank(matchStrings(idx,:)), '" operation'];
    warning(wid, '%s', message);
end

%
% Function BOTHAT
%
function [c,lut] = bothat(a)

lut = [];
c = bwmorph(bwmorph(a, 'dilate'), 'erode') & ~a;

%
% Function BRANCHPOINTS
%
function [c, lut] = branchpoints(a)

lut = [];

% Initial branch point candidates
C = applylut(a, lutbranchpoints);

% Background 4-Connected Object Count (Vp)
B = applylut(a, lutbackcount4);

% End Points (Vp = 1)
E = (B == 1);

% Final branch point candidates
FC = ~E .* C;

% Generate mask that defines pixels for which Vp = 2 and no
% foreground neighbor q for which Vq > 2 

% Vp = 2 Mask
Vp = ((B == 2) & ~E);

% Vq > 2 Mask
Vq = ((B > 2) & ~E);

% Dilate Vq
D = bwmorph(Vq, 'dilate', 1);

% Intersection between dilated Vq and final candidates w/ Vp = 2
M = (FC & Vp) & D;

% Final Branch Points
c =  FC & ~M;

%
% Function BRIDGE
%
function [c,lut] = bridge(a)

lut = lutbridge;
c = applylut(a, lut);

%
% Function CLEAN
%
function [c,lut] = clean(a)

lut = lutclean;
c = applylut(a, lut);

%
% Function CLOSE
%
function [c, lut] = close(a)

lut = [];
c = bwmorph(bwmorph(a, 'dilate'), 'erode');


%
% Function FILL_
%
function [c,lut] = fill_(a)

lut = lutfill;
c = applylut(a, lut);


%
% Function DIAG_
%
function [c,lut] = diag_(a)

lut = lutdiag;
c = applylut(a, lut);


%
% Function DILATE
%
function [c,lut] = dilate(a)

lut = lutdilate;
c = applylut(a, lut);

%
% Function ENDPOINTS
%
function [c,lut] = endpoints(a)

lut = lutendpoints;
c = applylut(a, lut);

%
% Function ERODE
%
function [c,lut] = erode(a)

lut = luterode;
c = applylut(a, lut);


%
% Function FATTEN
%
function [c,lut] = fatten(a)

lut = lutfatten;
c = applylut(a, lut);


%
% Function FILL
%
function [c,lut] = fill(a)

lut = lutfill;
c = applylut(a, lut);

%
% Function HBREAK
%
function [c,lut] = hbreak(a)

lut = luthbreak;
c = applylut(a, lut);

%
% Function MAJORITY
%
function [c,lut] = majority(a)

lut = lutmajority;
c = applylut(a, lut);

%
% Function OPEN
%
function [c, lut] = open(a)

lut = [];
c = bwmorph(bwmorph(a, 'erode'), 'dilate');


%
% Function PERIM4
%
function [c,lut] = perim4(a)

lut = lutper4;
c = applylut(a, lut);

%
% Function PERIM8
%
function [c,lut] = perim8(a)

lut = lutper8;
c = applylut(a, lut);

%
% Function REMOVE
%
function [c,lut] = remove(a)

lut = lutremove;
c = applylut(a, lut);

%
% Function SHRINK
%
function [c,lut] = shrink(a)

lut = [];
table = uint8(lutshrink);
c = a;

% First subiteration
m = applylut(c, table);
sub = c & ~m;
c(1:2:end,1:2:end) = sub(1:2:end,1:2:end);

% Second subiteration
m = applylut(c, table);
sub = c & ~m;
c(2:2:end,2:2:end) = sub(2:2:end,2:2:end);

% Third subiteration
m = applylut(c, table);
sub = c & ~m;
c(1:2:end,2:2:end) = sub(1:2:end,2:2:end);

% Fourth subiteration
m = applylut(c, table);
sub = c & ~m;
c(2:2:end,1:2:end) = sub(2:2:end,1:2:end);

%
% Function SKEL
%
function [c,lut] = skel(a)

lut = [];
c = a;
for i = 1:8
    c = applylut(c, lutskel(i));
end


%
% Function SPUR
%
function [c,lut] = spur(a)
%SPUR Remove parasitic spurs.
%   [C,LUT] = spur(A, numIterations) removes parasitic spurs from
%   the binary image A that are shorter than numIterations.

lut = lutspur;

% Start by complementing the image.  The lookup table is designed
% to remove endpoints in a complemented image, where 0-valued
% pixels are considered to be foreground pixels.  That way,
% because applylut assumes that pixels outside the image are 0,
% spur removal takes place as if the image were completely
% surrounded by foreground pixels.  That way, lines that
% intersect the edge of the image aren't pruned at the edge.
c = ~a;
    
% Identify all end points.  These form the entire set of
% pixels that can be removed in this iteration.  However,
% some of these points may not be removed.
endPoints = applylut(c, lutspur);
    
% Remove end points in the first field.
c(1:2:end, 1:2:end) = xor(c(1:2:end, 1:2:end), ...
        endPoints(1:2:end, 1:2:end));
    
% In the second field, remove any of the original end points
% that are still end points.
newEndPoints = endPoints & applylut(c, lut);
c(1:2:end, 2:2:end) = xor(c(1:2:end, 2:2:end), ...
        newEndPoints(1:2:end, 2:2:end));
    
% In the third field, remove any of the original end points
% that are still end points.
newEndPoints = endPoints & applylut(c, lut);
c(2:2:end, 1:2:end) = xor(c(2:2:end, 1:2:end), ...
        newEndPoints(2:2:end, 1:2:end));
    
% In the fourth field, remove any of the original end points
% that are still end points.
newEndPoints = endPoints & applylut(c, lut);
c(2:2:end, 2:2:end) = xor(c(2:2:end, 2:2:end), ...
        newEndPoints(2:2:end, 2:2:end));

% Now that we're finished, we need to complement the image once
% more.
c = ~c;
    
%
% Function THIN
%
function [c,lut] = thin(a)
  
% Louisa Lam, Seong-Whan Lee, and Ching Y. Wuen, "Thinning Methodologies-A
% Comprehensive Survey," IEEE TrPAMI, vol. 14, no. 9, pp. 869-885, 1992.  The
% algorithm is described at the bottom of the first column and the top of the
% second column on page 879.

lut = [];
if (isempty(a))
    c = zeros(size(a));
    return;
end

lut1 = lutthin1;
image_iter1 = applylut(a, lut1);

lut2 = lutthin2;
c = applylut(image_iter1, lut2);
    
%
% Function TOPHAT
%
function [c,lut] = tophat(a)

lut = [];
c = a & ~bwmorph(bwmorph(a, 'erode'), 'dilate');


%
% Function THICKEN
%
function [c,lut] = thicken(a)

lut = [];

% Isolated pixels are going to need a "jump-start" to get
% them going; otherwise, they won't "thicken".
% First, identify the isolated pixels.
isolut = lutiso;
iso = applylut(a, isolut);
if (any(iso(:)))
    % Identify possible pixels to maybe change to one.
    growMaybe = bwmorph(iso,'dilate');
    % Identify pixel locations in the original image
    % with only one on pixel in the 3-by-3 neighborhood.
    singlelut = lutsingle;
    oneNeighbor = applylut(a, singlelut);
    % If a pixel is adjacent to an isolated pixel, *and* it
    % doesn't also have another neighbor, set it to one.
    a = a | (oneNeighbor & growMaybe);
end

% Preallocate a uint8 1's matrix.
c = uint8(1);
[m,n] = size(a);
m = m+4;
n = n+4;
c(m,n) = 0;
c(1:end,1:end) = 1;
[P,Q] = size(c);

c(3:(P-2),3:(Q-2)) = ~a;

cc = bwmorph(c, 'thin');
d = bwmorph(cc, 'diag');
c = (c & ~cc & d) | cc; 
c(1:P,1:2) = 1;
c(1:P,(Q-1):Q) = 1;
c(1:2,1:Q) = 1;
c((P-1):P,1:Q) = 1;
    
c = ~c(3:(P-2),3:(Q-2));



