Welcome to our Data Visualization demo for Flutter Web. This was part of the initial set of demos for Flutter Web when it was announced at Google I/O 2019. This project uses activity data from the [main Flutter github repository](https://github.com/flutter/flutter) over the four year lifespan of the project, then plots it in an animated layered chart.

More details are available on the [project page on our website](https://www.larvalabs.com/project/github-dataviz-flutter-web).

### How to run the app

Generally just follow the instructions at https://github.com/flutter/flutter_web, but the following steps are usually enough:

1. Install the flutter_web build tools:
    ```
    $ flutter pub global activate webdev
    ```

1. Update packages.

    ```console
    $ flutter packages upgrade
    ! flutter_web 0.0.0 from path ../../flutter_web
    ! flutter_web_ui 0.0.0 from path ../../flutter_web_ui
    Running "flutter packages upgrade" in hello_world...                5.0s
    ```

    If that succeeds, you're ready to run it!

1. Build and serve the example locally.

    ```console
    $ webdev serve
    [INFO] Generating build script completed, took 331ms
    ...
    [INFO] Building new asset graph completed, took 1.4s
    ...
    [INFO] Running build completed, took 27.9s
    ...
    [INFO] Succeeded after 28.1s with 618 outputs (3233 actions)
    Serving `web` on http://localhost:8080
    ```

    Open <http://localhost:8080> in Chrome to see the visualization.

