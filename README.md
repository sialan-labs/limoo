### Limoo

Limoo is multiplatform and modern image viewer, focused on better user interface...

### How to Compile
#### Install dependencies

Install gcc, g++, libexiv2, Qt5Core, Qt5DBus, Qt5Gui, Qt5Multimedia, Qt5MultimediaQuick_p, Qt5Network, Qt5PrintSupport, Qt5Qml, Qt5Quick, Qt5Sql, Qt5Svg, and Qt5Widgets.
on Ubuntu:

    sudo apt-get install g++ gcc libexiv2-dev qtbase5-dev libqt5sql5-sqlite libqt5multimediaquick-p5 libqt5multimedia5-plugins libqt5multimedia5 libqt5qml5 libqt5qml-graphicaleffects libqt5qml-quickcontrols qtdeclarative5-dev libqt5quick5 

For other distributions search for the corresponding packages.

#### Get source code from git repository

If you want get source from git repository you should install git on your system:

    sudo apt-get install git

After git installed, get code with this command:

    git clone https://github.com/sialan-labs/limoo.git

#### Start building

Switch to source directory

    cd limoo

##### Ubuntu

    mkdir build && cd build
    qmake -r ..
    make

You can use command below after building to clean build directory on the each step.

    make clean
