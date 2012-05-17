function hvars = varsinheader(structure)
%VARSINHEADER Construct a varsinheader object
%   SIGGUI.VARSINHEADER(STRUCT,NSECS) Construct a varsinheader object using
%   STRUCT as the default CurrentStructure and NSECS as the default enable
%   state of the Number of Sections edit box.  If these are not specified,
%   STRUCT is '' and NSECS is 'off'.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2005/06/16 08:46:36 $

% Instantiate the object
hvars = siggui.varsinheader;

% Set up the defaults
if nargin 
    set(hvars, 'CurrentStructure', structure);
end
set(hvars, 'Labels', defaultlabels);
set(hvars, 'VariableNames', defaultvariables);
set(hvars, 'Version', 1);


% -----------------------------------------------------------------
function lbls = defaultlabels

% Contains the label that will ideantify the variable editbox and the length
lbls.tf          = {xlate('Numerator'), xlate('Denominator')};
lbls.fir         = {xlate('Numerator'), ''};
lbls.statespace  = {xlate('SS coeffs'), ''};
lbls.lattice     = {xlate('Lattice coeffs'), ''};
lbls.latticearma = {xlate('Lattice coeffs'), xlate('Ladder coeffs')};


% -----------------------------------------------------------------
function vars = defaultvariables

% Set up the default variable names.  The default structures are 'tf' 'fir'
% 'statespace' 'lattice' 'latticearma'  Each of these contains the length
% and var fields
vars.tf.length          = {'NL', 'DL'};
vars.tf.var             = {'NUM', 'DEN'};
vars.fir.length         = {'BL', ''};
vars.fir.var            = {'B', ''};
vars.statespace.length  = {'HL', ''};
vars.statespace.var     = {'H', ''};
vars.lattice.length     = {'KL', ''};
vars.lattice.var        = {'K', ''};
vars.latticearma.length = {'KL','VL'};
vars.latticearma.var    = {'K','V'};

% [EOF]
