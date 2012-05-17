#include "counterbus.h"

void counterbusFcn(COUNTERBUS *u1, int32_T u2, COUNTERBUS *y1, int32_T *y2)
{
  int32_T limit;
  boolean_T inputGElower;  
  
  limit = u1->inputsignal.input + u2;

  inputGElower = (limit >= u1->limits.lower_saturation_limit);

  if((u1->limits.upper_saturation_limit >= limit) && inputGElower) {
    *y2 = limit;
  } else {

    if(inputGElower) {
      limit = u1->limits.upper_saturation_limit;
    } else {
      limit = u1->limits.lower_saturation_limit;
    }
    *y2 = limit;
  }

  y1->inputsignal.input = *y2;
  y1->limits = u1->limits;

}
