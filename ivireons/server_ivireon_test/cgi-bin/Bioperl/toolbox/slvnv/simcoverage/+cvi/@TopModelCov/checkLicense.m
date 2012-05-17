function res = checkLicense(modelH)
txt =  []; 
res = true;
if ~cv('Private', 'cv_autoscale_settings', 'isForce', modelH) && ~cv('Private', 'check_cv_license')
    txt = 'Simulink Verification and Validation License check out failed.\nModel Coverage will be disabled for this simulation.';
elseif cv('Private', 'cv_autoscale_settings', 'isForce', modelH)  && ~check_license('fixpt')
    txt = 'License check out failed. Coverage will be disabled';
end
if ~isempty(txt)
    res = false;
    display(sprintf(txt));
    set_param(modelH, 'RecordCoverage', 'off');
end


%===========================
function status = check_license(licensetype)
try
    status = cv('License',licensetype);
catch MEx %#ok<NASGU>
    status = 0;
end


