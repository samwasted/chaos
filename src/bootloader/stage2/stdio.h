#pragma once
#include "stdint.h"

#ifndef far
#define far
#endif


void putc(char c);
void puts(const char* str);
void puts_f(const char far* str);
void _cdecl printf(const char* fmt, ...); //ignore this error
void print_buffer(const char* msg, const void far* buffer, uint16_t count);
