#include <raylib.h>

#include "element.h"
#include "error.h"
#include "list.h"
#include "types.h"

// Structs.
struct rk_element {
    RK_ELEMENT;
};

// Routines.
// Initialize an element.
rk_error_t rk_initialize_element(struct rk_element* p_e) {
    // Setup.
    rk_error_t error_code = RK_OK;

    // Initialize children list.
    p_e->children = rk_construct_list(sizeof(struct rk_element), &error_code);

    // Check error.
    RK_ASSERT(error_code == RK_OK) return error_code;

    // Initialize other members.
    p_e->free_content = NULL;
    p_e->update = NULL;
    p_e->parent = NULL;
    p_e->get_dimension = NULL;
    
    return error_code;
}
// Make space and add element as child.
rk_error_t rk_add_child_as_element(struct rk_element* p_e, struct rk_element* p_child) {
    // Setup.
    rk_error_t error_code = RK_OK; 

    // Append element to children list.
    rk_append_element_to_list(p_e->children, &p_child, sizeof(struct rk_element*), &error_code);

    // Check error.
    RK_ASSERT(error_code == RK_OK) 
        return error_code;

    // Assign self as child's parent.
    p_child->parent = p_e;

    // Return error code.
    return error_code;
}
// Get element's dimension (width & height).
struct Vector2 rk_get_dimension_of_element(struct rk_element* p_e) {
    if(p_e->get_dimension) 
        return p_e->get_dimension();
    return (Vector2){0, 0};
}
// Get element's position.
struct Vector2 rk_get_position_of_element(struct rk_element* p_e) {
    if(p_e->get_position)
        return p_e->get_position();
    return (Vector2){0, 0};
}
// Call its `update` method on itself then the children recursively, from up to
// down.
void rk_update_element(struct rk_element* p_e, float p_delta) {
    // Call `update` method on itself.
    if(p_e->update) p_e->update(p_e, p_delta);

    // Recursively call `rk_update_element` on the children.
    for(
            unsigned int i = 0;
            rk_get_count_of_list(p_e->children);
            i++
       ) rk_update_element(
           *(struct rk_element**) 
           rk_get_element_of_list(p_e->children, i),
           p_delta
           );
}
// Call its `render` method on itself then the children recursively, from up to
// down.
void rk_render_element(struct rk_element* p_e, float p_delta) {
    // Call `render` method on itself.
    if(p_e->render) p_e->render(p_e, p_delta);

    // Recursively call `rk_update_element` on the children.
    for(
            unsigned int i = 0;
            rk_get_count_of_list(p_e->children);
            i++
       ) rk_render_element(
           *(struct rk_element**) 
           rk_get_element_of_list(p_e->children, i),
           p_delta
           );
}

// Call `free_content` method and `free` on the children recursively then
// itself, from down to up.
void rk_free_element(struct rk_element* p_e) {
    // Recursively call `rk_free_element` on the children.
    for(
            unsigned int i = 0;
            rk_get_count_of_list(p_e->children);
            i++
       ) rk_free_element(
           *(struct rk_element**) 
           rk_get_element_of_list(p_e->children, i)
           );

    // Free memory.
    if(p_e->free_content) p_e->free_content(p_e);
    MemFree(p_e);
}
