function op = operspec(nlsys)
%OPERSPEC Create an operating point specification object for Nonlinear ARX
%model. 
%
% SPEC = OPERSPEC(NLSYS) creates an operating point specification object
% for Nonlinear ARX (IDNLARX) model NLSYS. The object encapsulates
% constraints on input and output signal values for the model. These
% specifications are used for determination of an operating point of the
% IDNLARX model using the FINDOP command.
%
% OPERSPEC consists of two properties: Input and Output. Each property is a
% struct with fields as described below:
%   Input: a struct with fields:
%       'Value': Specify initial guess for the values of the input signals.
%                It should be a vector of length equal to number of model
%                inputs. Default: a vector of zeros. 
%         'Min': Specify the minimum value constraint on values of input
%                signals for the model. Default: -Inf for all channels.
%         'Max': Specify the maximum value constraint on values of input
%                signals for the model. Default: Inf for all channels.
%       'Known': Indicate if the specified 'Value' is known (fixed) or just
%                an initial guess. Use a logical vector to denote which
%                signals are known (value = TRUE) and which have to be
%                estimated using FINDOP (value = FALSE). By default, all
%                input signals are assumed to be known. 
%   Output: a struct with fields:
%       'Value': Specify initial guess for the values of the output
%                signals. Default: a vector of zeros. 
%         'Min': Specify the minimum value constraint on values of output
%                signals for the model. Default: -Inf.
%         'Max': Specify the maximum value constraint on values of output
%                signals for the model. Default: Inf.
%   Note that output values represent initial values that FINDOP starts
%   with for search of steady-state values. The 'Known' specification does
%   not apply to output signals. 
%
% See also IDNLARX/FINDOP, IDNLARX/LINEARIZE, IDNLHW/OPERSPEC.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 06:14:28 $

op = idutils.idnlarxopspec(nlsys);
