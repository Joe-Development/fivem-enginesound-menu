<img src="https://github.com/user-attachments/assets/cb715dfa-f670-4156-be3d-b6cb0c4c78a6" width="100" height="100"><br>

# Engine Sound Menu - FiveM
Easy to use menu to allow you to change your engine sound ingame - syncs to all clients via statebags.

If you require support or need more information, please [visit our docs](https://docs.grav.wtf/docs/enginesoundmenu/information)

## Dependencies
[ox_lib](https://github.com/overextended/ox_lib)

The default permission ace for this command is `enginesoundmenu` - you can give this to a group such as:
`add_ace group.donator enginesoundmenu allow`

If you want to edit the permissions check such as for jobs or your framework, edit the `server_config.lua`
You can configure your sounds via `client_config.lua` as well as the default keybind - leave it blank if no default keybind is wanted.

This menu also supports favourites! Quickly find the best engine sounds and shortlist them for convenience!
Toggleable option to automatically save what models you use specific sounds on that will be re-applied when you re-enter or respawn the vehicle.
