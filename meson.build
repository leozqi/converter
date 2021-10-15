# project name and programming language
project('com.github.leozqi.converter', 'vala', 'c')

# Create a new executable, list the files we want to compile, list the dependencies we need,
sources = files(
    'src' / 'App.vala',
#    'src' / 'FileChooserDialog.vala',
    'src' / 'FileEntry.vala',
    'src' / 'MainWindow.vala',
    'src' / 'Toast.vala',
    'src' / 'ConvertHandle.vala',
    'src' / 'FileList.vala',
    'src' / 'ConvertOpts.vala'
)

executable(
    meson.project_name(),
    sources,
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('json-glib-1.0')
    ],
    install: true
)

# Install .desktop file so the Applications Menu
install_data(
    'data' / 'converter.desktop',
    install_dir: get_option('datadir') / 'applications',
    rename: meson.project_name() + '.desktop'
)

install_data(
    'data' / 'converter.appdata.xml',
    install_dir: get_option('datadir') / 'metainfo',
    rename: meson.project_name() + '.appdata.xml'
)

install_data(
    'data' / 'config.json',
    install_dir: get_option('configdir') / meson.project_name(),
    rename: 'config.json'
)
