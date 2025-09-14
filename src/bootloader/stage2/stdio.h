#pragma once

#ifndef far
#define far
#endif

void putc(char c);
void puts(const char* str);
void puts_f(const char far* str);
void _cdecl printf(const char* fmt, ...); // ignore this error squiggle, we are overriding our own printf
