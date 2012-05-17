classdef unitgain < idnlfun
    %UNITGAIN class definition.
    %
    %   U = UNITGAIN
    %
    %   UNITGAIN is a linear function y = F(x), where y and x are scalars.
    %   F(x) is the identity mapping F(x) = x.
    %
    %   This object has no properties. This object is used in
    %   Hammerstein-Wiener models (IDNLHW) to indicate absence of
    %   nonlinearity in the input or output channel it is applied to. For
    %   example:
    %     m = nlhw(data,orders,[saturation,unitgain],deadzone)
    %     estimates an IDNLHW model with 2 inputs and 1 output. The first
    %     input channel has a saturation nonlinearity, but the second one has
    %     none.
    %
    %   Note that if nonlinearities are absent in all input or output channels,
    %   unitgain can be replaced by the empty matrix:
    %   m = nlhw(data,orders,[],'sigmoid') defines a Wiener model.
    %
    %   See also LINEAR, NLHW, POLY1D, WAVENET, PWLINEAR, SIGMOIDNET,
    %   SATURATION, DEADZONE.
    
    % Copyright 2005-2008 The MathWorks, Inc.
    % $Revision: 1.1.8.6 $ $Date: 2008/05/19 23:09:09 $
    
    % Author(s): Qinghua Zhang
    %   Technology created in colloboration with INRIA and University Joseph
    %   Fourier of Grenoble - FRANCE
    
    methods
        %---------------------------------
        function str = getInfoString(this)
            str = 'None';
        end
        
    end
end
% FILE END
