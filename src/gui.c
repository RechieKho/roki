#include "gui.h"
#include "element.h"
#include "error.h"
#include "raylib.h"
#include "types.h"

// Struct.
struct rk_gui {
    RK_GUI;
};

// Routines.
// Calculate self's position.
static struct Vector2 calculate_position(struct rk_gui* p_gui) {
    // Get parent's dimension, use screen's dimension if there is no parent.
    struct Vector2 parent_dimension;
    if(p_gui->parent != NULL) parent_dimension = rk_get_dimension_of_element(p_gui->parent);
    else  parent_dimension = (Vector2){
        GetScreenWidth(),
        GetScreenHeight()
    };

    // Make sure dimension is valid.
    RK_ASSERT(parent_dimension.x > 0 || parent_dimension.y > 0) 
        return (Vector2){0, 0};

    // Get parent's position, zero vector if there is no parent.
    struct Vector2 parent_position = {0, 0};
    if(p_gui->parent != NULL) parent_position = rk_get_position_of_element(p_gui->parent);

    // Calculate self's position.
    struct Vector2 position = {
        parent_position.x + 
            parent_dimension.x * p_gui->anchor.x + p_gui->padding.x,
        parent_position.y + 
            parent_dimension.x * p_gui->anchor.z + p_gui->padding.z
    };
    
    return position;
}
// Calculate self's dimension.
static struct Vector2 calculate_dimension(struct rk_gui* p_gui) {
    // Get parent's dimension, use screen's dimension if there is no parent.
    struct Vector2 parent_dimension;
    if(p_gui->parent != NULL) parent_dimension = rk_get_dimension_of_element(p_gui->parent);
    else  parent_dimension = (Vector2){
        GetScreenWidth(),
        GetScreenHeight()
    };

    // Make sure dimension is valid.
    RK_ASSERT(parent_dimension.x > 0 || parent_dimension.y > 0) 
        return (Vector2){0, 0};

    // Calculate self's dimension;
    struct Vector2 dimension = {
        parent_dimension.x * 
            (p_gui->anchor.y - p_gui->anchor.x) -
            p_gui->padding.x - p_gui->padding.y,
        parent_dimension.y * 
            (p_gui->anchor.w - p_gui->anchor.z) -
            p_gui->padding.z - p_gui->padding.w
    };

    // Return calulation.
    return dimension;
}
// Initialize as element and assign special GUI function.
rk_error_t rk_initialize_gui_element(struct rk_gui* p_gui, struct Vector4 p_anchor, struct Vector4 p_padding) {
    // Setup.
    rk_error_t error_code = RK_OK;

    // Initialize as element.
    error_code = RK_INIT_ELEMENT(p_gui);

    // Check error.
    RK_ASSERT(error_code == RK_OK) 
        return error_code;

    // Initialize GUI members.
    p_gui->get_dimension = calculate_dimension;
    p_gui->get_position = calculate_position;
    p_gui->anchor = p_anchor;
    p_gui->padding = p_padding;

    // Return OK.
    return RK_OK;
}
