lockitron-bash
==============

Control a Lockitron unit from a Bash command line.

## Dependencies

* curl
* [jq](http://stedolan.github.io/jq/)

## Installation

1. `git clone https://github.com/zerodivide1/lockitron-bash.git`
2. `cd lockitron-bash`
3. `chmod u+x lockitron.sh`
4. Create a configuration file at `$HOME/.config` called `lockitron` with the following contents, replacing `xxxxx` with your OAuth access token for your Lockitron account (visit [Lockitron's API page](https://api.lockitron.com/) for more info):
   ```
   ACCESS_TOKEN=xxxxx
   ```
5. `./lockitron-bash.sh list` to retrieve the names of your Lockitrons.

## Command Reference

The following commands can be used:
* `list` - Retrieves the names of current Lockitron units associated with your account
* `status <unit name>` - Retrieves the current status of the given Lockitron unit
* `lock <unit name>` - Issues a lock command to the given Lockitron (will return when the operation has completed)
* `unlock <unit name>` - Issues an unlock command to the given Lockitron (will return when the operation has completed)
* `firmware <unit name>` - Issues a command to update the AVR and BLE firmware of the given Lockitron unit

## Contributors

Pull requests always welcome! You can also hit me up on Twitter [@zero_divide_1](https://twitter.com/zero_divide_1).

## License

See [LICENSE](LICENSE) for more information.
