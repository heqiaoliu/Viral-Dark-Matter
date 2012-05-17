function out = applymattrc_fwd(in, MatTRC)
%APPLYMATTRC_FWD converts from device space to ICC profile connection space
%   OUT = APPLYMATTRC_FWD(IN, MATTRC) converts from device space to ICC
%   profile space, i.e., A to B, using the Matrix-based model.  The only
%   Profile Connection Space supported by this model type is 16-bit XYZ.
%   MATTRC is a substructure of a MATLAB representation of an ICC profile
%   (see ICCREAD). Both IN and OUT are n x 3 vectors.  IN can be either
%   uint8 or uint16.  OUT is a uint16 encoding of ICC CIEXYZ.

%   Copyright 2002-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/03 03:10:12 $
%   Original author:  Scott Gregory 10/20/02

% Check input arguments
iptchecknargin(2,2,nargin,'applymattrc_fwd');
iptcheckinput(in,{'double'},{'real','2d','nonsparse','finite'},...
              'applymattrc_fwd','IN',1);
if size(in,2) ~= 3
    eid = 'Images:applymattrc_fwd:invalidInputData';
    msg = 'Incorrect number of columns in IN.';
    error(eid,'%s',msg');
end

% Check the MatTRC
iptcheckinput(MatTRC,{'struct'},{'nonempty'},'applymattrc_fwd','MATTRC',2);

% linearize RGB
TRC = cell(1, 3);
TRC{1} = MatTRC.RedTRC;
TRC{2} = MatTRC.GreenTRC;
TRC{3} = MatTRC.BlueTRC;
for i = 1 : 3
    rgb(:, i) = applycurve(in(:, i), TRC{i}, 0, 'spline');
end

% construct matrix and evaluate
mat = [MatTRC.RedColorant;
       MatTRC.GreenColorant;
       MatTRC.BlueColorant];
out = rgb * mat;
