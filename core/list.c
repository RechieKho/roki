#include <stdlib.h>
#include <raylib.h>

#include "element.h"
#include "list.h"
#include "error.h"
#include "types.h"

// Defines.
#define INIT_CAPACITY 10

// Struct.
struct rk_list {
    void* array;
    unsigned int count;
    unsigned int capacity;
    size_t element_size;
};

// Routine.
// Allocate memory for list structure.
struct rk_list* rk_construct_list(size_t p_element_size, rk_error_t* p_error_code) {
    // Setup. 
    *p_error_code = RK_OK;

    // Allocate memory.
    struct rk_list* const list = (struct rk_list* const) MemAlloc(sizeof(struct rk_list));

    // Check error.
    RK_ASSERT(list != NULL) {
        *p_error_code = RK_ERR_MEM_ALLOC;
        return NULL;
    }

    // Initialize member.
    list->array = NULL;
    list->capacity = 0;
    list->count = 0;
    list->element_size = p_element_size;

    // Return value.
    return list;
}
// Resize list to ensure list have at least `p_min_capacity` capacity.
enum rk_error rk_make_space_in_list(struct rk_list* p_list, unsigned int p_min_capacity, rk_error_t* p_error_code) {
    // Setup.
    *p_error_code = RK_OK;
    unsigned int new_capacity = p_list->capacity == 0 ? INIT_CAPACITY : p_list->capacity;

    // Calculate new capacity.
    while(new_capacity < p_min_capacity) new_capacity *= 2;

    // Allocate memory.
    void* array = MemRealloc(p_list->array, p_list->element_size * new_capacity);

    // Check error.
    RK_ASSERT(array != NULL) {
        *p_error_code = RK_ERR_MEM_ALLOC;
        return RK_ERR_MEM_ALLOC;
    }

    // Update list member.
    p_list->capacity = new_capacity;
    p_list->array = array;

    return *p_error_code;
}
// Free list and its array.
inline void rk_free_list(struct rk_list* p_list) {
    if(p_list->capacity) MemFree(p_list->array);
    MemFree((void*)p_list);
}
// Return pointer displace by `p_index`.
inline void *rk_get_element_of_list(struct rk_list* p_list, unsigned int p_index) {
    return (void*)((char*)p_list->array + p_index * p_list->element_size);
}
// Return count.
inline unsigned int rk_get_count_of_list(struct rk_list *p_list) {
    return p_list->count;
}
// Append element. 
enum rk_error rk_append_element_to_list(struct rk_list* p_list, void* p_element, size_t p_element_size, rk_error_t* p_error_code) {
    // Check if element size is compatible.
    RK_ASSERT(p_element_size == p_list->element_size) 
        return *p_error_code = RK_ERR_INVALID_ARGUMENT;

    // Setup. 
    *p_error_code = RK_OK;

    // Make space for the new element.
    rk_make_space_in_list(p_list, p_list->count + 1, p_error_code);

    // Check error.
    RK_ASSERT(*p_error_code == RK_OK) return *p_error_code;

    // Append new element.
    memcpy(rk_get_element_of_list(p_list, p_list->count), p_element, p_element_size);

    // Return error code.
    return *p_error_code;
}
