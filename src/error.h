#ifndef _RK_ERROR_H_
#define _RK_ERROR_H_

#include <stdint.h>

#include "types.h"

// Types.
typedef unsigned int rk_error_t;

// Enums.
enum rk_error {
    RK_OK,
    RK_ERR_MEM_ALLOC,
    RK_ERR_INVALID_ARGUMENT,
};

#endif //_RK_ERROR_H_
