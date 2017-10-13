defmodule Confload do
  @moduledoc """
  Documentation for Confload.
  """

  use Application
  import Supervisor.Spec, warn: false
  require Logger

  def start(_type, _args) do
    children = []
    opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)
    watch? = Application.get_env(:confload, :watch)
    check_watch(watch?)
    {:ok, sup}
  end

  def config_change(changed, _new, _removed) do
    check_watch(changed[:watch])
  end

  def check_watch(true),  do: start_watcher()
  def check_watch(false), do: stop_watcher()
  def check_watch(_),     do: :ok

  defp start_watcher() do
    release_app = release_app()
    path =
      cond do
        release_app -> [release_config(release_app)]
        true        -> [Path.expand("config")]
      end
    worker = worker(FileSystem, [[name: __MODULE__.FileSystem, dirs: [path]]], id: :confload_watcher)
    Supervisor.start_child(__MODULE__.Supervisor, worker)
    Supervisor.start_child(__MODULE__.Supervisor, worker(__MODULE__.Watcher, []))
    :ok
  end

  @doc """
  Release application.
  """
  def release_app() do
    progname = System.get_env("PROGNAME")
    if is_binary(progname) && Regex.match?(~r/.*rel.*releases.*sh/, progname), do: file2app(progname)
  end

  defp file2app(path) do
    path |> Path.basename |> Path.rootname
  end

  defp release_config(release_app) do
    cond do
      path = System.get_env("CONFORM_CONF_PATH") ->
        path
      (path = Path.join(System.get_env("RELEASE_CONFIG_DIR"), "#{release_app}.conf"); File.exists?(path)) ->
        path
      true ->
        System.get_env("SRC_SYS_CONFIG_PATH")
        |> Path.dirname
        |> Path.join("#{release_app}.conf")
    end
  end

  defp stop_watcher() do
    stop_child(:confload_watcher)
    stop_child(__MODULE__.Watcher)
  end

  defp stop_child(id) do
    case Supervisor.terminate_child(__MODULE__.Supervisor, id) do
      :ok ->
        :ok = Supervisor.delete_child(__MODULE__.Supervisor, id)
      {:error, :not_found} ->
        :not_found
    end
  end

  @doc """
  Reload the configuration for all loaded applications.
  """
  def reload() do
    Application.loaded_applications |> Enum.map(&elem(&1, 0)) |> reload()
  end

  @doc """
  Reload the configuration for list of application.
  """
  def reload(applications) do
    config =
      cond do
        release_app() ->
          Logger.info("release script")
          progname = System.get_env("PROGNAME")
          release_script =
            case progname do
              "/" <> _ -> progname
              _ -> Path.join "/", progname
            end
          ## Print release info, which produce new configuration
          {_, 0} = System.cmd(release_script, ["describe"])
          Logger.info("release touch")
          sys_config = System.get_env("DEST_SYS_CONFIG_PATH")
          {:ok, [config]} = :file.consult(sys_config)
          config
        true ->
          Mix.Config.read!("config/config.exs")
    end
    reload(config, applications)
  end

  @doc """
  Reload adding new configuration for list of applications.
  """
  def reload(config, applications) do
    applications |> application_specs |> change_application_data(config)
  end

  @doc """
  Get application specifications for a list of applications.
  """
  def application_specs(applications) do
    specs = for application <- applications, do: {:application, application, make_application_spec(application)}
    incorrect_apps = for {_, application, :incorrect_spec} <- specs, do: application
    case incorrect_apps do
      [] -> specs
      _ -> {:incorrect_specs, incorrect_apps}
    end
  end

  defp make_application_spec(application) when is_atom(application) do
    {:ok, loaded_app_spec} = :application.get_all_key(application)
    loaded_app_spec
  end

  @doc """
  Change application data.
  """
  def change_application_data(specs, config) do
    old_env = :application_controller.prep_config_change
    :ok = :application_controller.change_application_data(specs, config)
    :application_controller.config_change(old_env)
  end
end
