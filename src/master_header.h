
/* Michael A. Park
 * Computational Modeling & Simulation Branch
 * NASA Langley Research Center
 * Phone:(757)864-6604
 * Email:m.a.park@larc.nasa.gov 
 */
  
/* $Id$ */

#ifndef MASTER_HEADER_H
#define MASTER_HEADER_H

#ifdef __cplusplus
#  define BEGIN_C_DECLORATION extern "C" {
#  define END_C_DECLORATION }
#else
#  define BEGIN_C_DECLORATION
#  define END_C_DECLORATION
#endif

BEGIN_C_DECLORATION

#define EMPTY (-1)

/* lifted defs from the SDK/MeatLib/Common.h */

#undef TRUE
#undef FALSE
 
#if defined(__cplusplus)
typedef short   bool;
#define TRUE    ((bool)true)
#define FALSE   ((bool)false)
#else
typedef short   bool;
#define TRUE    ((bool)1)
#define FALSE   ((bool)0)
#endif

END_C_DECLORATION

#endif /* MASTER_HEADER_H */
