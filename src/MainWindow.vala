errordomain ConfigError {
	INVALID
}

class MainWindow : Gtk.ApplicationWindow {

/* -----------------------------------------------------------------------------
Fields
----------------------------------------------------------------------------- */

private ConvertOpts convertopts = new ConvertOpts();

private Gtk.Overlay overlay = new Gtk.Overlay ();

private string config_dir = Environment.get_user_config_dir ();
private string prog_name = "com.github.leozqi.converter";

private string selected_from;
private string selected_to;

private FileList filelist = new FileList ();

/* -----------------------------------------------------------------------------
Constructor
----------------------------------------------------------------------------- */

internal MainWindow (App app)
{
	Object (application: app, title: "Converter");

	this.set_default_size (300, 300);
	this.border_width = 10;
	this.window_position = Gtk.WindowPosition.CENTER;
	this.destroy.connect (Gtk.main_quit);

	this.add(overlay);

	var grid = new Gtk.Grid ();
	grid.set_row_spacing (20);
	grid.set_column_spacing (10);

	/* Add a treeview */

	var view_label = new Gtk.Label ("Files to convert:");
	view_label.set_xalign (0.0f);
	// widget column row width height
	grid.attach (view_label, 0, 0, 1, 1);

	var view_button = new Gtk.Button.with_label ("Add a file");
	view_button.get_style_context ().add_class ("suggested-action");
	view_button.clicked.connect (this.open_files);
	grid.attach (view_button, 1, 0, 1, 1);

	grid.attach (filelist, 0, 1, 2, 1);

	var from_label = new Gtk.Label ("Convert:");
	from_label.set_xalign (0.0f);
	grid.attach (from_label, 0, 2, 1, 1);

	var from = new Gtk.ComboBoxText ();
	from.changed.connect (this.from_changed);
	grid.attach (from, 1, 2, 1, 1);

	var to_label = new Gtk.Label ("To:");
	to_label.set_xalign (0.0f);
	grid.attach (to_label, 0, 3, 1, 1);

	var to = new Gtk.ComboBoxText ();
	to.changed.connect (this.to_changed);
	grid.attach (to, 1, 3, 1, 1);

	var convert_button = new Gtk.Button.with_label ("Begin!");
	convert_button.get_style_context ().add_class ("suggested-action");
	convert_button.clicked.connect (this.begin_convert);
	grid.attach (convert_button, 0, 4, 1, 1);

	this.overlay.add_overlay (grid);

	if (!this.load_config (@"$(this.config_dir)/$(this.prog_name)/config.json")) {
		show_toast ("Problem with configuration!");
	} else {
		this.convertopts.load_opts (from, to);
	}
}

/* -----------------------------------------------------------------------------
Conversion dialogs and functions
----------------------------------------------------------------------------- */

void begin_convert (Gtk.Button button)
{
	if (!this.convertopts.has_converter (this.selected_from, this.selected_to)) {
		show_toast ("No compatible conversion option.");
		return;
	}
	Gtk.FileChooserDialog open_dialog = new Gtk.FileChooserDialog (
		"Add a file . . .",
		this as Gtk.ApplicationWindow,
		Gtk.FileChooserAction.SELECT_FOLDER,
		"_Cancel",
		Gtk.ResponseType.CANCEL,
		"_Open",
		Gtk.ResponseType.ACCEPT
	);

	open_dialog.local_only = true; // disallow URIs
	open_dialog.set_modal (true);
	open_dialog.response.connect (this.begin_convert_cb);
	open_dialog.show ();
}


void begin_convert_cb (Gtk.Dialog dialog, int response_id)
{
	var d = dialog as Gtk.FileChooserDialog;

	switch (response_id) {
	case Gtk.ResponseType.ACCEPT:
		this.convert (d.get_filename ());
		break;

	case Gtk.ResponseType.CANCEL:
		show_toast ("Cancelled!");
		break;
	}
	dialog.destroy ();
}


void convert (string out_path)
{
	print(@"$(out_path)\n");
	ConvertHandle? handle = this.convertopts.get_converter (
		this.selected_from,
		this.selected_to
	);

	if (handle == null) {
		this.show_toast ("No compatible converter for these two options!");
		return;
	}

	Gtk.TreeIter iter;
	this.filelist.model.get_iter_first (out iter);

	string filename = "";
	string filepath = "";
	string filetype = "";

	Value name = Value (typeof (string));
	Value path = Value (typeof (string));
	Value type = Value (typeof (string));

	bool had_error;

	while (true) {
		this.filelist.model.@get (iter, 0, out filename);
		this.filelist.model.@get (iter, 1, out filepath);
		this.filelist.model.@get (iter, 2, out filetype);

		print (@"$(filename)\n$(filepath)\n$(filetype)\n");

		if (filetype != this.selected_from) {
			continue;
		}

		had_error = !( handle.convert (
			filepath,
			out_path,
			filename
		));

		if (this.filelist.model.iter_next(ref iter) == false) {
			if (had_error) {
				show_toast ("Conversion had errors.");
				return;
			} else {
				show_toast ("Conversion finished!");
				return;
			}
		}
	}
}

/* -----------------------------------------------------------------------------
Load JSON configuration
----------------------------------------------------------------------------- */

bool load_config (string path)
{
	File f = File.new_for_path (path);
	Json.Parser parser = new Json.Parser ();

	if (f.query_exists ()) {
		try {
			parser.load_from_file (path);

			Json.Node root = parser.get_root ();

			this.convertopts.parse_config (root);

		} catch (Error e) {
			stderr.printf ("Error loading config.json '%s'\n", e.message);
			return false;
		}
	} else {
		stderr.printf ("Error loading config.json '%s'\n", path);
		return false;
	}
	return true;
}

/* -----------------------------------------------------------------------------
Combobox
----------------------------------------------------------------------------- */

void from_changed (Gtk.ComboBox from)
{
	this.selected_from = this.convertopts.get_from (from.get_active ());
	print (this.convertopts.get_from (from.get_active ()));
	print (this.selected_from);
}


void to_changed (Gtk.ComboBox to)
{
	this.selected_to = this.convertopts.get_to (to.get_active ());
	print (this.convertopts.get_to (to.get_active ()));
	print (this.selected_to);

}

/* -----------------------------------------------------------------------------
Dialog to add files into FileList
----------------------------------------------------------------------------- */

void open_files (Gtk.Button button)
{
	Gtk.FileChooserDialog d = new Gtk.FileChooserDialog (
		"Add a file . . .",
		this as Gtk.ApplicationWindow,
		Gtk.FileChooserAction.OPEN,
		"Cancel",
		Gtk.ResponseType.CANCEL,
		"Open",
		Gtk.ResponseType.ACCEPT
	);

	d.local_only = true; // disallow URIs
	d.set_select_multiple (true);
	d.set_modal (true);
	d.response.connect (this.open_files_cb);
	d.show ();
}


void open_files_cb (Gtk.Dialog dialog, int response_id)
{
	var d = dialog as Gtk.FileChooserDialog;
	bool had_error = false;

	switch (response_id) {
	case Gtk.ResponseType.ACCEPT: //open the file
		SList<File> files = d.get_files ();
		for (uint i = 0; i < files.length(); i++) {
			try {
				this.filelist.add_file (files.nth_data (i));
			} catch (Converter.PATHERROR e) {
				had_error = true;
			}
		}
		break;
	}

	if (had_error) {
		show_toast ("Some files could not be added.");
	}

	dialog.destroy ();
}

/* -----------------------------------------------------------------------------
Show a "toast" or in-app notification
----------------------------------------------------------------------------- */

void show_toast (string message) {
	var toast = new Toast (message);

	this.overlay.add_overlay (toast);
	this.overlay.show_all ();
}

/* -----------------------------------------------------------------------------
End class
----------------------------------------------------------------------------- */
}
