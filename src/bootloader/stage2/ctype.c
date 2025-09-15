#include "ctype.h"
#include "stdint.h"

#undef islower
#undef toupper

bool islower(char chr)
{
    return chr >= 'a' && chr <= 'z';
}

char toupper(char chr)
{
    return islower(chr) ? (chr - 'a' + 'A') : chr;
}
