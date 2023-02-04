#include <raylib.h>

#include "element.h"
#include "error.h"
#include "panel.h"
#include "types.h"

int main(void)
{
    // Initialization
    const int screenWidth = 800;
    const int screenHeight = 450;
    rk_error_t error_code = RK_OK;
    struct rk_panel* const panel = rk_construct_panel(
            (struct Vector4){0, 0.5, 0, 1}, 
            (struct Vector4){10, 10, 10, 10}, &error_code);

    RK_ASSERT(error_code == RK_OK) return -1;

    SetConfigFlags(FLAG_WINDOW_RESIZABLE);
    InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window");

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Draw
        BeginDrawing();

            ClearBackground(DARKGRAY);

            rk_render_element(RK_AS_ELEMENT(panel), GetFrameTime());

        EndDrawing();
    }

    // De-Initialization
    CloseWindow();        // Close window and OpenGL context
    return 0;
}
