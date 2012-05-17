function insert_dsp_includes(file)

fprintf(file,'#ifdef __cplusplus\n');
fprintf(file,'extern "C" {\n');
fprintf(file,'#endif\n');
fprintf(file,'#include "template_support_fcn_list.h"\n');
fprintf(file,'#ifdef __cplusplus\n');
fprintf(file,'}\n');
fprintf(file,'#endif\n');

