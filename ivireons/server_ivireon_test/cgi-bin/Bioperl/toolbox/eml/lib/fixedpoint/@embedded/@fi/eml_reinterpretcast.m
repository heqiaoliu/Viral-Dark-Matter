function yfi = eml_reinterpretcast(xfi, ydt)
%REINTERPRETCAST Fixed-point reinterpretcast function for Embedded MATLAB
%
%   REINTERPRETCAST(A,T) will cast fi object A to the numerictype of T; A
%   must be of datatype fixed

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/eml_reinterpretcast.m $
% Copyright 2007-2008 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2008/05/19 22:53:02 $
% This function accepts mxArray input argument
eml_allow_mx_inputs;   

if eml_ambiguous_types
    yfi = eml_not_const(zeros(size(xfi)));
    return;
end

eml_assert(nargin == 2,'Incorrect number of inputs');

eml_assert(isfixed(xfi),'first input must be fi of data-type fixed');

eml_assert(isnumerictype(ydt),'second input must be a numerictype');

xdt = numerictype(xfi);
eml_assert((xdt.wordlength == ydt.wordlength),'The word length of the numeric type must be equal to the word length of the fi object being cast');


fx = fimath(xfi);

if (ydt.Signed == xdt.Signed)

    yfi = eml_reinterpret(xfi,ydt,fx);
    
else

    % Signedness mismatch
    % Emulated types will not be handled properly with a raw reinterpretation
    % Example
    %   Conceptual behavior
    %      x   fixdt(1,3,0)  SI bits      101   RWV =   -3.0
    %      y   fixdt(0,3,0)  SI bits      101   RWV =   +5.0
    %      
    %   Behavior when emulated inside 8 bit container with a RAW reinterp
    %
    %      x   fixdt(1,3,0)  SI bits 11111101   RWV =   -3.0
    %      y   fixdt(0,3,0)  SI bits 11111101   RWV = +253.0   Error
    %
    %   The emulation bits must be actively changed to get 
    %   the output that agrees with the conceptual behavior of 3 bit type
    %
    %      x   fixdt(1,3,0)  SI bits 11111101   RWV =   -3.0
    %      y   fixdt(0,3,0)  SI bits 00000101   RWV =   +5.0   5 emulation bits changed
    %
    xfi_stripped = eml_reinterpret(xfi);
    
    xdt_trivial_scaling = numerictype(xdt.Signed,xdt.WordLength,0);
    xfi_trivial_scaling = eml_dress(xfi_stripped,xdt_trivial_scaling,fx);

    ydt_trivial_scaling = numerictype(ydt.Signed,ydt.WordLength,0);
    %
    % Cast that will change the emulation bits as needed
    %
    yfi_trivial_scaling = fi(xfi_trivial_scaling,ydt_trivial_scaling,'OverflowMode','wrap');
    
    yfi = eml_reinterpret(yfi_trivial_scaling,ydt,fx);

end
