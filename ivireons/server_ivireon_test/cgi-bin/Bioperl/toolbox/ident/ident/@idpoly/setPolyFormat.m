function sys = setPolyFormat(sys,Value)
%SETPOLYFORMAT Specify format for B and F polynomials of multi-input IDPOLY model.
%
%   SYS = setPolyFormat(SYS, 'cell') converts the B and F polynomials
%   of multi-input IDPOLY model SYS from double matrices to cell arrays.
%   The cell arrays contain Nu double vectors, one for each model input (Nu
%   = number of inputs).
%
%   SYS = setPolyFormat(SYS, 'double') retains the double format for values
%   of B and F polynomials and designates the model to be working in a
%   backward compatibility mode. GET(SYS) displays a message that the model
%   has been configured to work in a backward-compatibility mode.
%
%   For multi-input IDPOLY models, the B and F polynomials are stored as
%   multi-row double matrices by default. In a future release, these
%   polynomials will be stored using cell arrays. The setPolyFormat command
%   provides a way of managing this incompatibility. Using it (with either
%   'cell' or 'double' argument) suppresses the incompatibility warnings
%   and ensures that the model is compatible with future releases.
%
%   If you convert to cell array format, you must also update any code that
%   fetches the values of "b" or "f" properties and performs operations on
%   them.
%
%   Note that this command has no effect on single-output models - the B
%   and F polynomials are represented by double row vectors.
% 
%   To see the effect of incompatibility, suppose you have the following
%   code in an existing MATLAB file:
%       %----------------- START CODE --------------------------
%       m = arx(data, [3 2 2 1 1]); % 2-input ARX model estimation
%       Zeros1 = roots(m.b(1,:))
%       %------------------ END CODE ----------------------------
%   In R2010a or later releases, the second command which extracts the
%   value of the B polynomial using m.b issues an incompatibility warning.
%   However, the code executes without errors. To be compatible with the
%   future release (when the B and F polynomials will use cell arrays), you
%   must do one of the following:
%   Option 1:
%       Designate the model to continue using the double matrix by adding
%       the following command after estimating:
%       >> m = setPolyFormat(m, 'double');
%       This does not modify the data type of B and F polynomials, but
%       designates the model to continue using the double matrices even
%       after the cell arrays become the default format in a future
%       release. It also suppresses any incompatibility related warnings
%       from your code.
%   Option 2:
%       Change to using cell arrays for B and F polynomials by adding the
%       following command after estimating:
%       >> m = setPolyFormat(m, 'cell')
%       This changes the "b" property value to cell array of 2 elements.
%       Consequently, you must also update the command that calculates the
%       zeros of the polynomials to use cell-array syntax (curly braces) in
%       place of double-matrix syntax (parenthesis):
%       >> Zeros1 = roots(m.b{1});
%
%   See also IDPOLY/POLYDATA.

%       Copyright 2009 The MathWorks, Inc.
%       $Revision: 1.1.8.2 $  $Date: 2009/12/05 02:03:41 $

if ischar(Value)
    if strcmpi(Value,'cell')
        Value = 0;
    elseif strcmpi(Value, 'double')
        Value = 1;
    else
        ctrlMsgUtils.error('Ident:idmodel:setPolyFormatCheck1')
    end
else
    ctrlMsgUtils.error('Ident:idmodel:setPolyFormatCheck1')
end

sys = pvset(sys,'BFFormat',Value);

