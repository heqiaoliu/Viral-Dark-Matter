function new_const = eml_type_relop_const(var, const)
%EML_TYEP_RELOP_CONST
%
%  when comparing a fi with a non-fi (which must be a const)
%  use this function to type the constant properly based on the
%  type of fi

%    Embedded MATLAB Private Function.

% Copyright 2005-2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.3 $  $Date: 2007/10/15 22:42:34 $

eml_assert(nargin == 2, 'Not enough input arguments.');

eml_assert(eml_is_const(const),'when comparing a fi with a non-fi, the non-fi must be a constant.');

tvar = eml_typeof(var);
fvar = eml_fimath(var);

% check if const could be representable in the type of var
q1 = eml_cast(fi(const, tvar, fvar), eml_typeof(const)) == const;
q = all(q1(:));

if q
    % const reprsentable in type of var
    % use vartype
    new_const = eml_cast(const, tvar, fvar);
else
    % const not representable in type of var
    % figure out const type
    new_const = get_best_prec_for_const(const, tvar, fvar);
end


function new_const = get_best_prec_for_const(const, nt_var, fm_var)

eml.extrinsic('emlGetMinWlenAndPrecisionForMxArray');
eml.extrinsic('emlGetBestPrecForMxArray');

varBias = nt_var.Bias;
const1 = const - varBias;

% get min precision numerictype for const with min wlen
nt_min = eml_const(emlGetMinWlenAndPrecisionForMxArray(const, varBias));
min_prec_const = eml_cast(const1, nt_min, fm_var);

% get best precision numerictype for const with wlen same as var
nt_best = eml_const(emlGetBestPrecForMxArray(const,nt_var));
best_prec_const = eml_cast(const, nt_best, fm_var);

q1 = eml_cast(min_prec_const, eml_typeof(const), fm_var) - const;
q2 = eml_cast(best_prec_const, eml_typeof(const), fm_var) - const;

q = q1 == q2;

if all(q(:))
    new_const = min_prec_const;
else
    new_const = best_prec_const;
end


