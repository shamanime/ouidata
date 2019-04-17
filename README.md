Ouidata
======

Ouidata. A lookup tool for the [Wireshark OUI](https://www.wireshark.org/tools/oui-lookup.html) database in Elixir.

Heavily inspired by the [Tzdata](https://github.com/lau/tzdata) library.

As of version 0.1.0 the current shipped database version is 20190416.

When a new release is out, it will be automatically downloaded at runtime.

The release version in use can be verified with the following function:

```elixir
iex> Ouidata.ouidata_version
"20190416"
```

## Getting started

To use the Ouidata library with Elixir 1.8, add it to the dependencies in your mix file:

```elixir
defp deps do
  [  {:ouidata, "~> 0.1.0"},  ]
end
```

That's it!

Now you're able to search for OUI vendors and comments:

```elixir
iex> Ouidata.get_vendor("00:00:69:AB:AB:AB")
"ConcordC"
```

```elixir
iex> Ouidata.get_comment("00:00:69:AB:AB:AB")
"Concord Communications Inc"
```


## Data directory and releases

The library uses a file directory to store data. By default this directory
is `priv`. In some cases you might want to use a different directory. For
instance when using releases this is recommended. If so, create the directory and
make sure Elixir can read and write to it. Then use elixir config files like this
to tell Ouidata to use that directory:

```elixir
config :ouidata, :data_dir, "/etc/elixir_ouidata_data"
```

Add the `release_ets` directory from `priv` to that directory
containing the `2019-xx-xx.ets` file that ships with this library.

For instance with this config: `config :ouidata, :data_dir, "/etc/elixir_ouidata_data"`
an `.ets` file such as `/etc/elixir_ouidata_data/release_ets/2019-04-15.ets` should be present.

## Automatic data updates

By default Ouidata will poll for OUI database updates every day.
In case new data is available, Ouidata will download it and use it.

This feature can be disabled with the following configuration:

```elixir
config :ouidata, :autoupdate, :disabled
```

If the autoupdate setting is set to disabled, one has to manually put updated .ets files
in the release_ets sub-dir of the "data_dir" (see the "Data directory and releases" section above).
When Wireshark releases new versions of the time zone data, this Ouidata library can be used to generate
a new .ets file containing the new data.

## Documentation

Documentation can be found at http://hexdocs.pm/ouidata/

## When new OUI data is released

Wireshark releases new versions of the [OUI database](https://www.wireshark.org/tools/oui-lookup.html) frequently.

The new database will automatically
be downloaded, parsed, saved and used in place of the old data.

## License

The ouidata Elixir library is released under the MIT license. See the LICENSE file.

The OUI database file is released by Wireshark.
