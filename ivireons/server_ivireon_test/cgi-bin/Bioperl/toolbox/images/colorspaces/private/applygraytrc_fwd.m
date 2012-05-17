function out = applygraytrc_fwd(in, GrayTRC, ConnectionSpace)
%APPLYGRAYTRC_FWD converts from monochrome device space to ICC PCS.
%   OUT = APPLYGRAYTRC_FWD(IN, GRAYTRC, CONNECTIONSPACE) converts 
%   data from a single-channel device space ('gray') to an ICC 
%   Profile Connection Space, using a Tone Reproduction Curve (TRC).  
%   The outputs from the TRC mapping are used to multiply the PCS 
%   coordinates of the D50 white point.  GRAYTRC is a substructure 
%   of a MATLAB representation of an ICC profile (see ICCREAD). 
%   CONNECTIONSPACE can be either 'Lab' or 'XYZ'.  IN is an n x 1 
%   vector, and OUT is an n x 3 vector, of class 'double'.  

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/03 03:10:09 $ Poe
%   Original author:  Robert Poe 08/16/05

% Check input arguments
iptchecknargin(3, 3, nargin, 'applygraytrc_fwd');
iptcheckinput(in, {'double'}, {'real', '2d', 'nonsparse', 'finite'}, ...
              'applygraytrc_fwd', 'IN', 1);
if size(in, 2) ~= 1
    eid = 'Images:applygraytrc_fwd:invalidInputData';
    error(eid, 'Incorrect number of columns in IN.');
end

% Check the GrayTRC
iptcheckinput(GrayTRC, {'uint16', 'struct'}, {'nonempty'}, ...
              'applygraytrc_fwd', 'GRAYTRC', 2);
if size(GrayTRC, 2) ~= 1
    eid = 'Images:applygraytrc_fwd:invalidInputData';
    error(eid, 'Incorrect number of columns in GRAYTRC.');
end
iptcheckinput(ConnectionSpace, {'char'}, {'nonempty'}, ...
              'applygraytrc_fwd', 'CONNECTIONSPACE', 3);

% Remap input data through TRC
gray = applycurve(in, GrayTRC, 0, 'spline');

% Construct output PCS array (3 columns):
if strcmp(ConnectionSpace, 'XYZ')
    white = whitepoint;       % XYZ of D50
else  % 'Lab'
    white = [100.0 0.0 0.0];  % L*a*b* of D50
end
out = gray * white;