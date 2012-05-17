function graderr(finite_diff_deriv, analytic_deriv, gradfcn)
%GRADERR Checks gradient discrepancy in optimization routines. 
% 
% This is a helper function.

%   Copyright 1990-2010 The MathWorks, Inc. 
%   $Revision: 1.1.4.4 $  $Date: 2010/03/22 04:19:46 $

try
    if isa(gradfcn,'function_handle')
      gradfcnstr = func2str(gradfcn);
    else
      gradfcnstr = char(gradfcn);
    end
catch unusedException %#ok The exception variable is unused, but the catch code is needed
    gradfcnstr = '';
end

tol = 1e-6;   % Relative tolerance for cautionary message

relError = abs(full(analytic_deriv - finite_diff_deriv))./max(1.0,abs(analytic_deriv));

[maxErr,i,j] = findRowColIndicesOfMaxElement(relError);
fprintf('Maximum relative discrepancy between derivatives = %g\n',maxErr);
if any(any(relError > tol))
    fprintf('Caution: user-supplied and finite-difference derivatives do\n')
    fprintf(' not match within %g relative tolerance.\n',tol)
    fprintf('Maximum difference occurs in element (%i,%i):\n',i,j)

    if ~isempty(gradfcnstr)
        fprintf('  User-supplied derivative, %s:     %g\n',gradfcnstr,full(analytic_deriv(i,j)))
    else 
        fprintf('  User-supplied derivative:     %g\n',full(analytic_deriv(i,j)))
    end
    fprintf('  Finite-difference derivative:     %g\n',full(finite_diff_deriv(i,j)))

    disp('Strike any key to continue or Ctrl-C to abort')
    pause 
    disp(' ') % blank line
end

%-------------------------------------------------------------------------
function [maxVal,i,j] = findRowColIndicesOfMaxElement(A)
% Helper function that finds indices (i,j) of the maximum element of matrix A.
% It also returns the maximum element, maxVal

% Find max element by columns
[col_max_val,row_idx] = max(A,[],1);
% Find max element by rows
[maxVal,col_idx] = max(col_max_val);
i = row_idx(col_idx);
j = col_idx;
