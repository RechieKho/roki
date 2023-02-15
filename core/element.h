#ifndef _RK_ELEMENT_H_
#define _RK_ELEMENT_H_

#include <raylib.h>

#include "error.h"
#include "types.h"
#include "list.h"

// Defines.
#define RK_ELEMENT \
    struct rk_element* parent; \
    struct rk_list* children; \
    void (*update)(struct rk_element* p_self, float p_delta); \
    void (*render)(struct rk_element* p_self, float p_delta); \
    void (*free_content)(struct rk_element* p_self); \
    struct Vector2 (*get_dimension)(); \
    struct Vector2 (*get_position)(); 

// Macros.
#define RK_AS_ELEMENT(mp_ptr) \
    ((struct rk_element*)(mp_ptr))
#define RK_INIT_ELEMENT(mp_e) \
    rk_initialize_element((struct rk_element*)(mp_e))

// Structs.
struct rk_element;

// Routines.
// Initialize an element.
rk_error_t rk_initialize_element(struct rk_element* p_e);
// Add element as child.
rk_error_t rk_add_child_as_element(struct rk_element* p_e, struct rk_element* p_child);
// Get element's dimension (width & height).
struct Vector2 rk_get_dimension_of_element(struct rk_element* p_e);
// Get element's position.
struct Vector2 rk_get_position_of_element(struct rk_element* p_e);
// Update element states.
void rk_update_element(struct rk_element* p_e, float p_delta);
// Render element to screen.
void rk_render_element(struct rk_element* p_e, float p_delta);
// Free element.
void rk_free_element(struct rk_element* p_e);

#endif //_RK_ELEMENT_H_
