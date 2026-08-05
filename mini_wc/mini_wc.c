/* PROJECT_STATUS: TODO */
/* Remove the marker above only when the implementation is ready for tests. */

#include <unistd.h>

int main(int argc, char **argv)
{
    static const char message[] = "mini_wc: implementation pending\n";

    (void)argc;
    (void)argv;
    if (write(2, message, sizeof(message) - 1) == -1)
        return (1);
    return (1);
}
