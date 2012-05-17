function cgprechecks(x, num_cgargs, cg_options)
%CGPRECHECKS  Sanity checks for the Computational Geometry commands.
% The checks are applied to DELAUNAY, VORONOI, CONVHULL


%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2007/06/14 05:11:27 $

if num_cgargs < 1
    error('MATLAB:cgprechecks:NotEnoughInputs', 'Needs at least 1 input.');
end
if ( num_cgargs > 1 && ~isempty(cg_options) )
    if ~iscellstr(cg_options)
        error('MATLAB:cgprechecks:OptsNotStringCell',...
              'OPTIONS should be a cell array of strings.');
    end
end

if ~isnumeric(x)
    error('MATLAB:cgprechecks:NonNumericInput',...
          'The specified data points are not in numeric array format.');
end    

if issparse(x)
    error('MATLAB:cgprechecks:Sparse',...
          'Data points in sparse matrix format are not supported.\nUse FULL to convert a sparse matrix to full storage format.');
end  

if ~isreal(x)
    error('MATLAB:cgprechecks:Complex',...
          'Data points in complex number format are not supported.\nUse REAL and IMAG to extract the real and imaginary components.');
end  
    
if any(isinf(x(:)) | isnan(x(:)))
  error('MATLAB:cgprechecks:CannotAcceptInfOrNaN',...
        'Data points containing Inf or NaN are not supported.');
end

if ndims(x) > 2
    error('MATLAB:cgprechecks:NonTwoDInput',...
          'Data points must be specified in a 2D array format.');
end      
    
[m,n] = size(x);

if m < n+1,
  error('MATLAB:cgprechecks:NotEnoughPts',...
        'Not enough unique points specified.');
end

