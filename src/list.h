#ifndef _RK_LIST_H_
#define _RK_LIST_H_

#include <raylib.h>

#include "types.h"
#include "error.h"

// Struct.
struct rk_list;

// Routine.
// Construct a new list.
struct rk_list* rk_construct_list(size_t p_element_size, rk_error_t* p_error_code);
// Resize list to ensure list have at least `p_min_capacity` capacity.
enum rk_error rk_make_space_in_list(struct rk_list* p_list, unsigned int p_min_capacity, rk_error_t* p_error_code);
// Free list and its array.
void rk_free_list(struct rk_list* p_list);
// Retrieve pointer that points to value by index.
void *rk_get_element_of_list(struct rk_list* p_list, unsigned int p_index);
// Retrieve count.
unsigned int rk_get_count_of_list(struct rk_list* p_list);
// Append element. 
enum rk_error rk_append_element_to_list(struct rk_list* p_list, void* p_element, size_t p_element_size, rk_error_t* p_error_code);

#endif //_RK_LIST_H_
