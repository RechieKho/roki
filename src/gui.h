#ifndef _RK_GUI_H_
#define _RK_GUI_H_

#include "element.h"
#include "raylib.h"

// Defines.
#define RK_GUI \
    RK_ELEMENT; \
    struct Vector4 anchor; \
    struct Vector4 padding;

// Macros.
#define RK_INIT_GUI(mp_gui, mp_anchor, mp_padding) \
    rk_initialize_gui_element((struct rk_gui*)(mp_gui), (struct Vector4)(mp_anchor), (struct Vector4)(mp_padding))

// Struct.
struct rk_gui;

// Routines.
// Initialize a GUI element.
rk_error_t rk_initialize_gui_element(struct rk_gui* p_gui, struct Vector4 p_anchor, struct Vector4 p_padding);

#endif //_RK_GUI_H_
