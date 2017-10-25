defmodule Confload.Watcher do
  @moduledoc """
  Watcher for configuration changes
  """
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    FileSystem.subscribe(Confload.FileSystem)
    {:ok, nil}
  end

  def handle_info({:file_event, _, {file, _}}, state) do
    if Path.extname(file) == ".conf" or !Confload.release_app() do
      Logger.info "configuration changes are detected, reloading"
      Confload.reload()
    end
    {:noreply, state}
  end
  def handle_info({:file_event, _, :stop}, state) do
    Logger.warn "configuration change monitor stopped"
    {:noreply, state}
  end
end
