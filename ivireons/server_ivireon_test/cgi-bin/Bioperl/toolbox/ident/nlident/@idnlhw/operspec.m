function op = operspec(nlsys)
%OPERSPEC Create an operating point specification object for
%Hammerstein-Wiener model. 
%
% SPEC = OPERSPEC(NLSYS) creates an operating point specification object
% for Hammerstein-Wiener (IDNLHW) model NLSYS. The object encapsulates
% constraints on input and output signal values for the model. These
% specifications are used for determination of an operating point of the
% IDNLHW model using the FINDOP command.
%
% OPERSPEC consists of two properties: Input and Output. Each property is a
% struct with fields 'Value', 'Min', 'Max' and  'Known'. These fields
% should be set as follows:
%       'Value': Value represents initial guess or fixed levels for the
%                values of the input signals and target values for output
%                signals. Value should be a vector of length equal to
%                number of model inputs or outputs. Default: a vector of 
%                zeros.
%         'Min': Specify the minimum value constraint on values of
%                input/output signals for the model. Default: -Inf for all
%                channels. 
%         'Max': Specify the maximum value constraint on values of
%                input/output signals for the model. Default: Inf for all
%                channels. 
%       'Known': Indicate if the specified signal value is known or not.
%                For input signals, this field determines if the
%                corresponding input signal's steady-state value should be
%                estimated (if FALSE) or not (if TRUE). For outputs, this
%                field determines which output signals have to be used as
%                target values (if TRUE) and which have to be only kept
%                within constraints (if FALSE). Defaults: TRUE for input
%                signals and FALSE for output signals. 
%
% Note: 
% 1. If input is completely known ('Known' field is set to TRUE for all
%    input channels), then model's initial state values are determined
%    using input values only. In this case, FINDOP ignores the output
%    signal specifications.
% 2. If input values are not completely known, FINDOP uses the output
%    signal specifications to achieve the following objectives: 
%    (a) Match target values of known output signals (output channels with
%        Known = TRUE). 
%    (b) Keep the free output signals (output channels with Known = FALSE)
%        within the specified MIN/MAX bounds.
%
% See also IDNLHW/FINDOP, IDNLHW/LINEARIZE, IDNLARX/OPERSPEC.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 06:14:46 $

op = idutils.idnlhwopspec(nlsys);
