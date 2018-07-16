defmodule PortQuitting.PortRunner do
  use GenServer
  require Logger

  @path_to_port_wrapper Application.get_env(:port_quitting, :port_wrapper_path)

  def start_link(cmd_and_args) do
    GenServer.start_link(__MODULE__, cmd_and_args)
  end

  # ----

  def init(cmd_and_args) do
    port =
      Port.open({:spawn_executable, @path_to_port_wrapper}, [
        :binary,
        :exit_status,
        :hide,
        :nouse_stdio,
        args: cmd_and_args
      ])

    {:ok, port}
  end

  def handle_info({port, {:exit_status, _status}}, port) do
    {:stop, :normal, port}
  end
end
