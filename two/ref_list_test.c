#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "ref_list.h"
#include "ref_sort.h"
#include "ref_mpi.h"



int main( int argc, char *argv[] )
{
  REF_LIST ref_list;

  RSS( ref_mpi_start( argc, argv ), "start" );

  {
    REIS(REF_NULL,ref_list_free(NULL),"dont free NULL");
    RSS(ref_list_create(&ref_list),"create");
    REIS(0,ref_list_n(ref_list),"init zero");
    RSS(ref_list_free(ref_list),"free");
  }

  { /* store one */
    REF_INT item;
    RSS(ref_list_create(&ref_list),"create");
    item = 27;
    RSS(ref_list_add(ref_list,item),"add");
    REIS(1,ref_list_n(ref_list),"has one");
    RSS(ref_list_free(ref_list),"free");
  }

  { /* remove */
    REF_INT item, last;
    RSS(ref_list_create(&ref_list),"create");

    REIS(REF_FAILURE,ref_list_pop(ref_list,&last),"rm");

    item = 27;
    RSS(ref_list_add(ref_list,item),"add");
    RSS(ref_list_pop(ref_list,&last),"rm");
    REIS(0,ref_list_n(ref_list),"has none");

    RSS(ref_list_free(ref_list),"free");
  }

  { /* store lots */
    REF_INT item, max;
    RSS(ref_list_create(&ref_list),"create");
    max = ref_list_max(ref_list);
    for (item=0; item <= max; item++)
      {
	RSS(ref_list_add(ref_list,item),"store");
      }
    RAS(ref_list_max(ref_list)>max, "more?");
    RSS(ref_list_free(ref_list),"free");
  }

  { /* shift */
    REF_INT last;
    RSS(ref_list_create(&ref_list),"create");
    RSS(ref_list_add(ref_list,20),"store");
    RSS(ref_list_add(ref_list,10),"store");
    RSS(ref_list_shift(ref_list,15,27),"shift");

    RSS(ref_list_pop(ref_list,&last),"rm");
    REIS(10,last,"has none");

    RSS(ref_list_pop(ref_list,&last),"rm");
    REIS(47,last,"has none");

    RSS(ref_list_free(ref_list),"free");
  }

  { /* sort */
    REF_INT last;
    RSS(ref_list_create(&ref_list),"create");
    RSS(ref_list_add(ref_list,20),"store");
    RSS(ref_list_add(ref_list,10),"store");
    RSS(ref_list_sort(ref_list),"sort");

    RSS(ref_list_pop(ref_list,&last),"rm");
    REIS(20,last,"has none");
    RSS(ref_list_pop(ref_list,&last),"rm");
    REIS(10,last,"has none");

    RSS(ref_list_free(ref_list),"free");
  }

  { /* erase */
    RSS(ref_list_create(&ref_list),"create");
    RSS(ref_list_add(ref_list,20),"store");
    RSS(ref_list_add(ref_list,10),"store");
    RSS(ref_list_sort(ref_list),"sort");

    RSS(ref_list_erase(ref_list),"rm -rf");

    REIS(0,ref_list_n(ref_list),"has none");

    RSS(ref_list_free(ref_list),"free");
  }

  { /* allgather */
    RSS(ref_list_create(&ref_list),"create");

    RSS(ref_list_add(ref_list,ref_mpi_id),"store");

    RSS(ref_list_allgather(ref_list),"gather");

    REIS(ref_mpi_n,ref_list_n(ref_list),"one from each");

    RSS(ref_list_free(ref_list),"free");
  }

  { /* contains */
    REF_INT item;
    REF_BOOL contains;
    RSS(ref_list_create(&ref_list),"create");
    item = 27;
    RSS(ref_list_add(ref_list,item),"add");
    RSS(ref_list_contains(ref_list, item, &contains), "have");
    REIS(REF_TRUE,contains,"does have");
    RSS(ref_list_contains(ref_list, 5, &contains), "have");
    REIS(REF_FALSE,contains,"does have");
    RSS(ref_list_free(ref_list),"free");
  }

  { /* delete first */
    REF_INT item;
    RSS(ref_list_create(&ref_list),"create");

    item = 5;
    REIS(REF_NOT_FOUND,ref_list_delete(ref_list,item),"rm");

    item = 21;RSS(ref_list_add(ref_list,item),"add");
    item = 22;RSS(ref_list_add(ref_list,item),"add");
    item = 23;RSS(ref_list_add(ref_list,item),"add");
    REIS(3,ref_list_n(ref_list),"has 3");

    item = 21;RSS(ref_list_delete(ref_list, item), "have");
    REIS(2,ref_list_n(ref_list),"has 2");

    item = 23;RSS(ref_list_delete(ref_list, item), "have");
    REIS(1,ref_list_n(ref_list),"has 1");

    item = 22;RSS(ref_list_delete(ref_list, item), "have");
    REIS(0,ref_list_n(ref_list),"has 0");

    RSS(ref_list_free(ref_list),"free");
  }

  RSS( ref_mpi_stop( ), "stop" );

  return 0;
}
