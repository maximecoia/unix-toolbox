#include <fcntl.h>
#include <unistd.h>

int	main(int argc, char **argv)
{
	int fd;
	char buffer[4];
	ssize_t bytes_read;
	ssize_t bytes_written;
	ssize_t total_written;

	if (argc != 2)
		return (1);
	fd = open(argv[1], O_RDONLY);
	if (fd == -1)
		return (1);
	bytes_read = read(fd, buffer, sizeof(buffer));
	while (bytes_read > 0)
	{
		total_written = 0;
		while (total_written < bytes_read)
		{
			bytes_written = write(1, buffer + total_written, bytes_read
					- total_written);
			if (bytes_written <= 0)
			{
				close(fd);
				return (1);
			}
			total_written += bytes_written;
		}
		bytes_read = read(fd, buffer, sizeof(buffer));
	}
	if (bytes_read == -1)
	{
		close(fd);
		return (1);
	}
	close(fd);
	return (0);
}