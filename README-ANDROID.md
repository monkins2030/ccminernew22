**How to compile on Android**

*NOTE: Tested on rooted Android 6

There are two methods (or more?), to compile `ccminer` on Android:

1. By installing a Linux distribution with help of `Termux` + `proot-distro`: https://medium.com/veruscoin/mining-veruscoin-on-smartphone-208dbb06905f
2. By compiling without the any Linux distribution, purely on the system. 

How to explains second way.

# Step 1 - Install Termux

Download and install the [Termux](https://play.google.com/store/apps/details?id=com.termux) application.
Open the Termux after install. Next steps we need to do inside it.

# Step 2 - Install dependency packages

Run following command, to install the development dependencies:

`pkg install automake build-essential curl git gnupg openssl nano`

# Step 3 - Install a GCC 

I can't build the `ccminer` with `clang` that default compiler which comes with `Termux` (and Termux makes `clang` as alias for `gcc`). 
Also, Termux deprecated a _real_ gcc compiler tools, so we need to use [Its-Pointless Termux repo](https://github.com/its-pointless/gcc_termux), to install gcc from it.

Run the following command, to set-up _Its-Pointless Termux Repo_:

`curl -s https://its-pointless.github.io/setup-pointless-repo.sh | bash`

Then we need to install gcc-6 package:

`pkg install gcc-6`

# Step 4 - Build

Clone the `ccminer` git repo (`ARM-Android` branch):

`git clone --single-branch -b ARM-Android https://github.com/shmutalov/ccminer.git`

Then change the current directory:

`cd ccminer`

To build `ccminer` from sources we need to switch the default `clang` compiler to the `gcc` we installed on step 3 by executing following commands:

`setupgcc-6`

and then (to make `configure` process happy)

`setup-patchforgcc`

Then start the build:

`./build.sh`

After successful build you can run builded `ccminer` binary file to start the mining