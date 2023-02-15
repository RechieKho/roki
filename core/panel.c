#include <raylib.h>

#include "element.h"
#include "error.h"
#include "panel.h"
#include "gui.h"
#include "types.h"

// Struct.
struct rk_panel {
    RK_GUI;
    Color color;
};

// Routines.
// Update panel to screen.
static void rk_render_panel(struct rk_element* p_self, float p_delta) {
    struct rk_panel* const panel = (struct rk_panel* const) p_self;

    DrawRectangleV(
        rk_get_position_of_element(p_self), 
        rk_get_dimension_of_element(p_self), 
        panel->color);
}

// Construct a panel.
struct rk_panel* rk_construct_panel(struct Vector4 p_anchor, struct Vector4 p_padding, rk_error_t* p_error_code) {
    // Setup.
    *p_error_code = RK_OK;

    // Allocate memory.
    struct rk_panel* const panel = (struct rk_panel* const) MemAlloc(sizeof(struct rk_panel));

    // Check error.
    RK_ASSERT(panel != NULL) {
        *p_error_code = RK_ERR_MEM_ALLOC;
        return NULL;
    }

    // Initialize as GUI.
    *p_error_code = RK_INIT_GUI(panel, p_anchor, p_padding);

    // Check error.
    RK_ASSERT(*p_error_code == RK_OK) 
        goto clean_up_panel;

    // Initialize member.
    panel->render = rk_render_panel;
    panel->color = RAYWHITE;

    return panel;

    // Clean up.
clean_up_panel: MemFree(panel);

    return NULL;
}
