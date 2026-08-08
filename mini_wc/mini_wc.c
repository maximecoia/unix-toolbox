#include <errno.h>
#include <fcntl.h>
#include <unistd.h>

#define BUFFER_SIZE 1024

static int	ft_strlen(char *str)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
		i++;
	return (i);
}

static int	is_space(char c)
{
	return (c == ' ' || c == '\t' || c == '\n'
		|| c == '\v' || c == '\f' || c == '\r');
}

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

static int	putnbr(long n)
{
	char	c;

	if (n >= 10 && putnbr(n / 10) == -1)
		return (-1);
	c = (n % 10) + '0';
	return (write_all(1, &c, 1));
}

static int	print_result(long lines, long words, long bytes, char *filename)
{
	if (putnbr(lines) == -1 || write_all(1, " ", 1) == -1
		|| putnbr(words) == -1 || write_all(1, " ", 1) == -1
		|| putnbr(bytes) == -1 || write_all(1, " ", 1) == -1
		|| write_all(1, filename, ft_strlen(filename)) == -1
		|| write_all(1, "\n", 1) == -1)
		return (-1);
	return (0);
}

int	main(int argc, char **argv)
{
	int		fd;
	char		buffer[BUFFER_SIZE];
	ssize_t		bytes_read;
	ssize_t		i;
	long		lines;
	long		words;
	long		bytes;
	int		in_word;

	if (argc != 2)
		return (1);
	fd = open(argv[1], O_RDONLY);
	if (fd == -1)
		return (1);
	lines = 0;
	words = 0;
	bytes = 0;
	in_word = 0;
	bytes_read = read(fd, buffer, BUFFER_SIZE);
	while (bytes_read > 0)
	{
		bytes += bytes_read;
		i = 0;
		while (i < bytes_read)
		{
			if (buffer[i] == '\n')
				lines++;
			if (is_space(buffer[i]))
				in_word = 0;
			else if (!in_word)
			{
				words++;
				in_word = 1;
			}
			i++;
		}
		bytes_read = read(fd, buffer, BUFFER_SIZE);
	}
	if (bytes_read == -1)
	{
		close(fd);
		return (1);
	}
	close(fd);
	if (print_result(lines, words, bytes, argv[1]) == -1)
		return (1);
	return (0);
}
