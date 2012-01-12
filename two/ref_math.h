
#ifndef REF_MATH_H
#define REF_MATH_H

#include <math.h>

#include "ref_defs.h"

BEGIN_C_DECLORATION

#define ref_math_dot(a,b) ((a)[0]*(b)[0]+(a)[1]*(b)[1]+(a)[2]*(b)[2])
#define ref_math_pi (3.14159265358979)
#define ref_math_in_degrees(radians) ((radians)*180.0/3.14159265358979)

REF_STATUS ref_math_normalize( REF_DBL *normal );

END_C_DECLORATION

#endif /* REF_MATH_H */
