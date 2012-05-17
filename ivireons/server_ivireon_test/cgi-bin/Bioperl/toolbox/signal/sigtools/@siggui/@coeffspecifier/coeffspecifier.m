function this = coeffspecifier(enabState)
%COEFFS Constructor for the coeffs object

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.15.4.10 $  $Date: 2007/12/14 15:18:13 $

error(nargchk(0,1,nargin,'struct'));

this = siggui.coeffspecifier;

% Set up the defaults.
set(this, 'Tag', 'coefficientspecifier');
set(this, 'Labels', defaultlabels);
set(this, 'Coefficients', defaultcoeffs);
set(this, 'SelectedStructure', defaultstruct);
set(this, 'AllStructures', defaultstructs);
set(this, 'Version', 1);
set(this, 'SOS', 'off');

% ---------------------------------------------------------
function coeffs = defaultcoeffs

% Set up the coefficients that will go in the edit boxes
coeffs.tf              = {'[0.028  0.053 0.071  0.053 0.028]',...
                          '[1.000 -2.026 2.148 -1.159 0.279]'};
coeffs.fir             = {'[-0.008  0.064 0.443 0.443 0.064 -0.008]'};
coeffs.sos             = {'SOS','1'};
coeffs.latticearma     = {'K','V'};
coeffs.latticeallpass  = {'K'};
coeffs.latticemamin    = {'K'};
coeffs.latticemamax    = {'K'};
coeffs.basefilter      = {'Hd'};


% -------------------------------------------------
function labels = defaultlabels

% Set up the labels for the edit boxes
labels.tf              = {'Numerator:','Denominator:'};
labels.fir             = {'Numerator:'};
labels.sos             = {'SOS Matrix:','Gain:'};
labels.latticeallpass  = {'Lattice coeff:'};
labels.latticearma     = {'Lattice coeff:','Ladder coeff:'};
labels.latticemamin    = {'Lattice coeff:'};
labels.latticemamax    = {'Lattice coeff:'};
labels.basefilter      = {'Discrete filter:'};

% ----------------------------------------------------------
function struct = defaultstruct

struct = 'Direct-Form II Transposed';


% ---------------------------------------------------
function specs = defaultstructs

% Filter Structure options 
specs.strs = {'Direct-Form I',... 
        'Direct-Form II',... 
        'Direct-Form I Transposed',... 
        'Direct-Form II Transposed',...
        'Direct-Form FIR', ...
        'Overlap-Add FIR', ...
        'Lattice Allpass',... 
        'Lattice Moving-Average (MA) For Minimum Phase',... 
        'Lattice Moving-Average (MA) For Maximum Phase',... 
        'Lattice Autoregressive Moving-Average (ARMA)',... 
        'Filter object'};

specs.short = {'dfilt.df1',...
         'dfilt.df2',...
         'dfilt.df1t',...
         'dfilt.df2t',...
         'dfilt.dffir', ...
         'dfilt.fftfir', ...
         'dfilt.latticeallpass',...
         'dfilt.latticemamin',...
         'dfilt.latticemamax',...
         'dfilt.latticearma',...
         'dfilt.basefilter'};

 specs.supportsos = [repmat(true, 4, 1); repmat(false, 8, 1)];

% [EOF]
