# Supported tags

-	`experimental`
-	`stable`
-	version number, check the tags page for details


# Starting a server

As simple as:

```console
$ docker run -dt koshatul/factorio:stable
```


# Persisting the map

To persist the map, just specify a volume mount for the /saves directory:

```console
$ mkdir saves
$ docker run -dt -v "$PWD/saves":/saves koshatul/factorio:stable
```


# Playing in experimental (where all the fun is)

```console
$ docker run -dt -v "$PWD/saves":/saves koshatul/factorio:experimental
```


# Specifying a server-settings file (volume mount for the /config/server-settings.json file or /config/ directory)

```console
$ docker run -dt -v "$PWD/saves":/saves -v "$PWD/server-settings.json":/config/server-settings.json koshatul/factorio:experimental
```


# License

Released under the [MIT License](https://raw.githubusercontent.com/Koshatul/factorio-docker/master/LICENSE).
