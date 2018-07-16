defmodule PortQuitting.PortRunnerTest do
  use ExUnit.Case, async: false

  alias PortQuitting.PortRunner

  setup do
    Process.flag(:trap_exit, true)
    :ok
  end

  test "starts the process; stops the process when terminated" do
    # Start a super-long sleep that's easy to grep for
    {:ok, pid} = PortRunner.start_link(["sh", "-c", "sleep 8675309"])
    # See that it's running
    assert {_output, 0} = System.cmd("sh", ["-c", "ps x | grep [s]leep\\ 8675309"])

    # Kill our Genserver
    Process.exit(pid, :kill)

    # See that the sleep and its wrapper are gone.
    assert {"", 1} = System.cmd("sh", ["-c", "ps x | grep [s]leep\\ 8675309"])
  end

  test "stops when the process stops" do
    {:ok, pid} = PortRunner.start_link(["true"])
    assert_receive {:EXIT, ^pid, :normal}, 3000
  end
end
