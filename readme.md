# Visualizing Flutter GitHub repository activity with Flutter web

### How to run the app

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
    $ flutter packages pub run build_runner serve
    [INFO] Generating build script completed, took 331ms
    ...
    [INFO] Building new asset graph completed, took 1.4s
    ...
    [INFO] Running build completed, took 27.9s
    ...
    [INFO] Succeeded after 28.1s with 618 outputs (3233 actions)
    Serving `web` on http://localhost:8080
    ```

    Open <http://localhost:8080> in Chrome and you should see `Hello World` in
    red text in the upper-left corner.
