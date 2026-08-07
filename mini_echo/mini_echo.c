#include <unistd.h>

int main(int argc, char **argv)
{
    int i;
    int j;

    i = 1;
    while (i < argc)
    {
        if (i > 1)
        {
            if (write(1, " ", 1) != 1)
                return (1);
        }
        j = 0;
        while (argv[i][j] != '\0')
        {
            if (write(1, &argv[i][j], 1) != 1)
                return (1);
            j++;
        }
        i++;
    }
    if (write(1, "\n", 1) != 1)
        return (1);
    return (0);
}
