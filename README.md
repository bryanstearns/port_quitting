# PortQuitting

I'm working on an app that uses [Hound](https://github.com/HashNuke/hound) to scrape a website;
it needs to have a PhantomJS process running.

I tried to use a port to run `phantomjs -wd`, but found that it didn't exit when I ctrl-C'd in
development. That send me down a rathole of Googling for solutions:

In the [Elixir documentation for Port](https://hexdocs.pm/elixir/Port.html#module-zombie-processes),
I found a wrapper script that almost worked fine - it nicely killed PhantomJS when I ctrl-C'd the
app in development, but then the wrapper wouldn't exit if PhantomJS exited (which meant that the
port wouldn't close).

More experimentation (and finding several StackOverflow answers) led to this implementation:

- It uses a modified version of the wrapper script, which traps the CHLD signal. Since I'm using
bash, I found I have to enable job control for this to work. (ksh doesn't need that, but I don't
have ksh on my production boxes now).

- To still be able to see the output from PhantomJS in development, I'm using port's `:nouse_stdio`
flag to shift the communication file descriptors from 1 & 2 to 3 & 4 (hence the `-u 3` in the
blocking `read` in the wrapper script).

- The location of the wrapper script is a configuration value, because I expect its location to
change in deployment using releases. (In my real project, it's not at the project root.)

- There are tests for both the important exit conditions. Don't bother running the app - just
run `mix test`.
