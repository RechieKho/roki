#ifndef _RK_PANEL_H_
#define _RK_PANEL_H_

#include <raylib.h>

#include "types.h"
#include "error.h"
#include "element.h"

// Structs.
struct rk_panel;

// Routines.
// Construct a panel.
struct rk_panel* rk_construct_panel(struct Vector4 p_anchor, struct Vector4 p_padding, rk_error_t* p_error_code);

#endif //_RK_PANEL_H_
