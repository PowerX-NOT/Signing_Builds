# Signing_Builds

1. Export your infos (replace with [your infos](https://github.com/PowerX-NOT/Signing_Builds/blob/main/generate.sh#L3))

```
C: Country shortform
ST: Country longform
L: Location
O, OU, CN: Your Name
emailAddress: Your email
```

2. Then, run these commands
```
chmod +x ./setup.sh
./setup.sh
```
This will automatically generate and set up the RSA private key.

3. Now, copy `build.sh` to your ROM source directory and replace [rom build cmd accordingly](https://github.com/PowerX-NOT/Signing_Builds/blob/main/build.sh#L3) with your ROM build command
```
chmod +x ./build.sh
./build.sh
```

## References and Credits

* [Lineage-signing-builds.md](https://gist.github.com/A2L5E0X1/54cb1b3a49030a9ebf8608b4e68073f5)
* [chiteroman](https://xdaforums.com/t/module-play-integrity-fix-safetynet-fix.4607985/post-89527857)
