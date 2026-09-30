/*
** A stand-in for write(2) that never writes more than one byte per call.
**
** The utilities are compiled a second time with -Dwrite=short_write, so every
** write() they make lands here instead. A real write() may return fewer bytes
** than it was asked for, on a pipe, a socket or a terminal, but a shell test
** cannot make that happen on demand. This makes it happen on every call, so a
** loop that takes a short write for a complete one loses bytes, and the suite
** sees them missing.
**
** The redirection happens at compile time rather than through LD_PRELOAD or
** DYLD_INSERT_LIBRARIES, so it behaves the same on Linux and on macOS, where
** System Integrity Protection strips those variables from some processes.
**
** Each shortened call appends one byte to the file named by SHORT_WRITE_LOG,
** when it is set. The suite checks that this file is not empty: a build in
** which the redirection did not happen would otherwise pass for the wrong
** reason.
*/
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

ssize_t	short_write(int fd, const void *buffer, size_t count);

static void	note_short_call(void)
{
	const char	*path;
	int			log_fd;
	ssize_t		written;

	path = getenv("SHORT_WRITE_LOG");
	if (path == NULL)
		return ;
	log_fd = open(path, O_WRONLY | O_CREAT | O_APPEND, 0644);
	if (log_fd == -1)
		return ;
	written = write(log_fd, ".", 1);
	(void)written;
	close(log_fd);
}

ssize_t	short_write(int fd, const void *buffer, size_t count)
{
	if (count > 1)
	{
		note_short_call();
		count = 1;
	}
	return (write(fd, buffer, count));
}
