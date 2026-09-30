/*
** A stand-in for read(2) that fails on demand.
**
** mini_cp is compiled a second time with -Dread=faulty_read, so every read()
** it makes lands here. Its read error path cannot be reached from a shell: a
** directory, the usual way to make read() fail, is refused before the copy
** starts. This reaches it, in the two ways that matter:
**
**   READ_FAULT=eio     the first call reads, every later one fails with EIO,
**                      so the error arrives after part of the file is copied;
**   READ_FAULT=eintr   the first call fails with EINTR, as if a signal had
**                      interrupted it, and every later one reads.
**
** Without READ_FAULT, every call is the real read(). Each faulted call appends
** one byte to the file named by READ_FAULT_LOG, when it is set, so the suite
** can tell a fault that was injected from one that never was.
*/
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

ssize_t	faulty_read(int fd, void *buffer, size_t count);

static void	note_fault(void)
{
	const char	*path;
	int			log_fd;
	ssize_t		written;

	path = getenv("READ_FAULT_LOG");
	if (path == NULL)
		return ;
	log_fd = open(path, O_WRONLY | O_CREAT | O_APPEND, 0644);
	if (log_fd == -1)
		return ;
	written = write(log_fd, ".", 1);
	(void)written;
	close(log_fd);
}

ssize_t	faulty_read(int fd, void *buffer, size_t count)
{
	static int	calls = 0;
	const char	*mode;

	calls++;
	mode = getenv("READ_FAULT");
	if (mode != NULL && strcmp(mode, "eio") == 0 && calls > 1)
	{
		note_fault();
		errno = EIO;
		return (-1);
	}
	if (mode != NULL && strcmp(mode, "eintr") == 0 && calls == 1)
	{
		note_fault();
		errno = EINTR;
		return (-1);
	}
	return (read(fd, buffer, count));
}
