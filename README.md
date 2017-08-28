# Confload

OTP compliant configuration reloading for distillery. Distillery has build-in
`reload_config` command, which doesn't involved the application config and doens't
notify application about changed configuration.

This configuration reloader is OTP compliant and uses application callback for
configuration changes.

Additional feature to allow config live reloading (watching the configuration file and
automaticly reload configuration on change).

Per default it is disabled, set `watch: true` to enable it.

Inspired by [exrm_reload](https://github.com/xerions/exrm_reload).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `confload` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:confload, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/confload](https://hexdocs.pm/confload).

## License

Copyright 2017

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
