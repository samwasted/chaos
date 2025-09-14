#include "stdint.h"
#include "stdio.h"

// for definitions
#ifndef _cdecl
#define _cdecl
#endif


void _cdecl cstart_(uint16_t bootDrive)
{
    puts("Hello world from C!\r\n");
    for (;;);
}