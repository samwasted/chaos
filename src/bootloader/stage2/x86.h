#pragma once //tells compare to include header only once, even if it tries to include multiple times
#include "stdint.h"


#ifndef _cdecl
#define _cdecl
#endif


void _cdecl x86_div64_32(uint64_t dividend, uint32_t divisor, uint64_t* quotientOut, uint32_t* remainderOut);
void _cdecl x86_Video_WriteCharTeletype(char c, uint8_t page);