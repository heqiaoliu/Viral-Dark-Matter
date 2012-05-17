function h = getTypeZeroPole(this)
%getTypeZeroPole returns struct of type poles and zeros

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 00:48:47 $


h = struct('Type', this.Type, 'Zero', this.Zero, 'Pole', this.Pole);

