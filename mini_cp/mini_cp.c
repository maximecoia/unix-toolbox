#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>

static int	write_all(int fd, const char *buffer, ssize_t count)
{
	ssize_t	total_written;
	ssize_t	bytes_written;

	total_written = 0;
	while (total_written < count)
	{
		bytes_written = write(fd, buffer + total_written,
				count - total_written);
		if (bytes_written == -1)
		{
			if (errno == EINTR)
				continue ;
			return (-1);
		}
		if (bytes_written == 0)
			return (-1);
		total_written += bytes_written;
	}
	return (0);
}

int	main(int argc, char **argv)
{
	int			src_fd;
	int			dst_fd;
	char		buffer[1024];
	ssize_t		bytes_read;
	struct stat	src_stat;
	struct stat	dst_stat;

	if (argc != 3)
	{
		fprintf(stderr, "usage: %s source destination\n", argv[0]);
		return (1);
	}
	src_fd = open(argv[1], O_RDONLY);
	if (src_fd == -1)
	{
		perror(argv[1]);
		return (1);
	}
	if (fstat(src_fd, &src_stat) == -1)
	{
		perror("fstat");
		close(src_fd);
		return (1);
	}
	if (stat(argv[2], &dst_stat) == 0)
	{
		if (src_stat.st_dev == dst_stat.st_dev
			&& src_stat.st_ino == dst_stat.st_ino)
		{
			fprintf(stderr, "mini_cp: '%s' and '%s' are the same file\n",
				argv[1], argv[2]);
			close(src_fd);
			return (1);
		}
	}
	else if (errno != ENOENT)
	{
		perror(argv[2]);
		close(src_fd);
		return (1);
	}
	dst_fd = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);
	if (dst_fd == -1)
	{
		perror(argv[2]);
		close(src_fd);
		return (1);
	}
	while (1)
	{
		bytes_read = read(src_fd, buffer, sizeof(buffer));
		if (bytes_read == 0)
			break ;
		if (bytes_read == -1)
		{
			if (errno == EINTR)
				continue ;
			perror("read");
			close(src_fd);
			close(dst_fd);
			return (1);
		}
		if (write_all(dst_fd, buffer, bytes_read) == -1)
		{
			perror("write");
			close(src_fd);
			close(dst_fd);
			return (1);
		}
	}
	close(src_fd);
	close(dst_fd);
	return (0);
}
